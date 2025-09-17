import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/pos_keypad.dart';
import '../printreceipt.dart';

class POSScreen extends StatefulWidget {
  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> with TickerProviderStateMixin {
  static const platform = MethodChannel('com.example/printerState');
  
  String displayValue = '0';
  String currentInput = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _animatePress() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  String _formatCurrency(String value) {
    if (value.isEmpty || value == '0') return '0';
    
    String cleanValue = value.replaceAll(',', '');
    
    try {
      double amount = double.parse(cleanValue);
      return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return value;
    }
  }

  Future<void> _printSaleReceipt(String amount) async {
    try {
      String receiptText = PrintReceipt.generateReceipt(amount);
      
      await platform.invokeMethod('printCustomText', {
        'text': receiptText
      });
      
      print('Receipt printed successfully');
    } on PlatformException catch (e) {
      print('Print failed: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Print failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onNumberPressed(String number) {
    _animatePress();
    setState(() {
      if (currentInput == '0' && number != '.') {
        currentInput = number;
      } else {
        if (currentInput.length < 12) {
          if (number == '000') {
            currentInput += '000';
          } else if (number == '00') {
            currentInput += '00';
          } else {
            currentInput += number;
          }
        }
      }
      displayValue = currentInput.isEmpty ? '0' : currentInput;
    });
  }

  void _onClearPressed() {
    _animatePress();
    setState(() {
      currentInput = '';
      displayValue = '0';
    });
  }

  void _onDeletePressed() {
    _animatePress();
    setState(() {
      if (currentInput.isNotEmpty) {
        currentInput = currentInput.substring(0, currentInput.length - 1);
        displayValue = currentInput.isEmpty ? '0' : currentInput;
      }
    });
  }

  void _onEnterPressed() {
    if (displayValue == '0' || displayValue.isEmpty) return;
    
    _animatePress();
    print('Processing sale: ₭${_formatCurrency(displayValue)}');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B1426),
                Color(0xFF1E3A5F),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.greenAccent,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'ການຂາຍສຳເລັດ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sale Completed',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'LAK ${_formatCurrency(displayValue)}',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _printSaleReceipt(displayValue);
                        _onClearPressed();
                      },
                      icon: Icon(Icons.print, size: 20),
                      label: Text('Print Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _onClearPressed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Color(0xFF0B1426),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'ຕົກລົງ / OK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1426),
              Color(0xFF1E3A5F),
              Color(0xFF2D5AA0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.point_of_sale_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'P10 POS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'ລະບົບຂາຍໜ້າຮ້ານ + ປິ້ນເຕີ້',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.greenAccent, width: 1),
                        ),
                        child: Text(
                          'LAK',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Color(0xFF0A0E1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.greenAccent.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'ຈຳນວນເງິນ',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'LAK ${_formatCurrency(displayValue)}',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.greenAccent.withOpacity(0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 32),
                
                Expanded(
                  child: POSKeypad(
                    onNumberPressed: _onNumberPressed,
                    onClearPressed: _onClearPressed,
                    onDeletePressed: _onDeletePressed,
                    onEnterPressed: _onEnterPressed,
                  ),
                ),
                
                SizedBox(height: 16),
                
                Text(
                  'P10 POS System with Integrated Printer',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
  }
}