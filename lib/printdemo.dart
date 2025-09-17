import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrintDemo extends StatefulWidget {
  const PrintDemo({super.key});

  @override
  State<PrintDemo> createState() => _PrintDemoState();
}

class _PrintDemoState extends State<PrintDemo> {
  static const platform = MethodChannel('com.example/printerState');
  
  String _printerStatus = 'Ready';
  String _lastPrintResult = 'No prints yet';
  bool _isPrinting = false;
  final TextEditingController _textController = TextEditingController(text: 'abcdefghIJKLMNOPQR');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _printReceipt() async {
    setState(() {
      _isPrinting = true;
      _lastPrintResult = 'Printing receipt...';
    });

    try {
      await platform.invokeMethod('onPrint');
      setState(() {
        _lastPrintResult = 'Receipt printed successfully';
        _isPrinting = false;
      });
      _showSnackBar('Receipt printed successfully!');
    } on PlatformException catch (e) {
      setState(() {
        _lastPrintResult = 'Print failed: ${e.message}';
        _isPrinting = false;
      });
      _showSnackBar('Print failed: ${e.message}');
    }
  }

  Future<void> _printCustomText() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('Please enter text to print');
      return;
    }

    setState(() {
      _isPrinting = true;
      _lastPrintResult = 'Printing custom text...';
    });

    try {
      await platform.invokeMethod('printCustomText', {
        'text': _textController.text
      });
      setState(() {
        _lastPrintResult = 'Custom text "${_textController.text}" printed successfully';
        _isPrinting = false;
      });
      _showSnackBar('Custom text printed successfully!');
    } on PlatformException catch (e) {
      setState(() {
        _lastPrintResult = 'Custom text print failed: ${e.message}';
        _isPrinting = false;
      });
      _showSnackBar('Custom text print failed: ${e.message}');
    }
  }

  Future<void> _printPresetMessage(String message, String displayName) async {
    setState(() {
      _isPrinting = true;
      _lastPrintResult = 'Printing $displayName...';
    });

    try {
      await platform.invokeMethod('printCustomText', {
        'text': message
      });
      setState(() {
        _lastPrintResult = '$displayName printed successfully';
        _isPrinting = false;
      });
      _showSnackBar('$displayName printed successfully!');
    } on PlatformException catch (e) {
      setState(() {
        _lastPrintResult = '$displayName print failed: ${e.message}';
        _isPrinting = false;
      });
      _showSnackBar('$displayName print failed: ${e.message}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Printer Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.print,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _printerStatus,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Result: $_lastPrintResult',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Custom Text Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Custom Text Print',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Enter text to print',
                        border: OutlineInputBorder(),
                        hintText: 'Type your message here...',
                      ),
                      maxLines: 2,
                      maxLength: 100,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isPrinting ? null : _printCustomText,
                        icon: _isPrinting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.print),
                        label: Text(_isPrinting ? 'Printing...' : 'Print Custom Text'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Preset Messages
            const Text(
              'Quick Print Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Print Receipt Button
            ElevatedButton.icon(
              onPressed: _isPrinting ? null : _printReceipt,
              icon: _isPrinting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.receipt_long),
              label: Text(_isPrinting ? 'Printing...' : 'Print Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Preset message buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPrinting ? null : () => _printPresetMessage('abcdefghIJKLMNOPQR', 'Alphabet'),
                    child: const Text('Alphabet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade50,
                      foregroundColor: Colors.purple.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPrinting ? null : () => _printPresetMessage('Hello World!', 'Hello World'),
                    child: const Text('Hello World'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      foregroundColor: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPrinting ? null : () => _printPresetMessage('Testing 123', 'Test 123'),
                    child: const Text('Test 123'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade50,
                      foregroundColor: Colors.teal.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPrinting ? null : () => _printPresetMessage('0123456789', 'Numbers'),
                    child: const Text('Numbers'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade50,
                      foregroundColor: Colors.pink.shade700,
                    ),
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Info Card
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Print Information',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Custom text shows multiple formats and character breakdown',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Receipt shows formatted invoice with items and totals',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}