import 'package:flutter/material.dart';

class POSKeypad extends StatefulWidget {
  final Function(String) onNumberPressed;
  final VoidCallback? onClearPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onEnterPressed;

  const POSKeypad({
    Key? key,
    required this.onNumberPressed,
    this.onClearPressed,
    this.onDeletePressed,
    this.onEnterPressed,
  }) : super(key: key);

  @override
  State<POSKeypad> createState() => _POSKeypadState();
}

class _POSKeypadState extends State<POSKeypad> with TickerProviderStateMixin {
  String? pressedButton;
  late Map<String, AnimationController> _controllers;
  late Map<String, Animation<double>> _animations;

  final List<String> buttons = ['1', '2', '3', '⌫', '4', '5', '6', 'C', '7', '8', '9', '0', '00', '000', 'ENTER'];

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _animations = {};
    
    for (String button in buttons) {
      _controllers[button] = AnimationController(
        duration: Duration(milliseconds: 150),
        vsync: this,
      );
      _animations[button] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[button]!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onButtonPress(String button) {
    setState(() {
      pressedButton = button;
    });
    
    _controllers[button]?.forward().then((_) {
      _controllers[button]?.reverse();
      setState(() {
        pressedButton = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A5F).withOpacity(0.3),
            Color(0xFF0B1426).withOpacity(0.5),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First row: 1, 2, 3, Delete
          Row(
            children: [
              _buildKeypadButton('1'),
              const SizedBox(width: 8),
              _buildKeypadButton('2'),
              const SizedBox(width: 8),
              _buildKeypadButton('3'),
              const SizedBox(width: 8),
              _buildActionButton('⌫', Color(0xFFE74C3C), widget.onDeletePressed),
            ],
          ),
          const SizedBox(height: 8),
          
          // Second row: 4, 5, 6, Clear
          Row(
            children: [
              _buildKeypadButton('4'),
              const SizedBox(width: 8),
              _buildKeypadButton('5'),
              const SizedBox(width: 8),
              _buildKeypadButton('6'),
              const SizedBox(width: 8),
              _buildActionButton('C', Color(0xFFFF6B35), widget.onClearPressed),
            ],
          ),
          const SizedBox(height: 8),
          
          // Rows 3 & 4 combined with tall ENTER button
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left 3 columns for numbers
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Row 3: 7, 8, 9
                      Row(
                        children: [
                          _buildKeypadButton('7'),
                          const SizedBox(width: 8),
                          _buildKeypadButton('8'),
                          const SizedBox(width: 8),
                          _buildKeypadButton('9'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row 4: 0, 00, 000
                      Row(
                        children: [
                          _buildKeypadButton('0'),
                          const SizedBox(width: 8),
                          _buildKeypadButton('00'),
                          const SizedBox(width: 8),
                          _buildKeypadButton('000'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right column: Tall ENTER button
                Expanded(
                  child: _buildTallEnterButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String text) {
    bool isPressed = pressedButton == text;
    
    return Expanded(
      child: AnimatedBuilder(
        animation: _animations[text]!,
        builder: (context, child) {
          double animationValue = _animations[text]!.value;
          
          return Transform.scale(
            scale: 1.0 - (animationValue * 0.05),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPressed ? [
                    Color(0xFF0B1426),
                    Color(0xFF1E3A5F),
                  ] : [
                    Color(0xFF2D5AA0),
                    Color(0xFF1E3A5F),
                    Color(0xFF0B1426),
                  ],
                ),
                boxShadow: isPressed ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Color(0xFF4A7BC8).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
                border: Border.all(
                  color: isPressed 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    _onButtonPress(text);
                    widget.onNumberPressed(text);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: text == '000' ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTallEnterButton() {
    bool isPressed = pressedButton == 'ENTER';
    
    return AnimatedBuilder(
      animation: _animations['ENTER'] ?? AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        double animationValue = _animations['ENTER']?.value ?? 0.0;
        
        return Transform.scale(
          scale: 1.0 - (animationValue * 0.05),
          child: GestureDetector(
            onTapDown: (_) => _onButtonPress('ENTER'),
            onTap: () {
              widget.onEnterPressed?.call();
            },
            child: Container(
              height: 148, // Height of 2 buttons + spacing (70 + 8 + 70)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPressed ? [
                    Color(0xFF27AE60).withOpacity(0.6),
                    Color(0xFF27AE60).withOpacity(0.8),
                  ] : [
                    Color(0xFF27AE60),
                    Color(0xFF27AE60).withOpacity(0.8),
                    Color(0xFF27AE60).withOpacity(0.6),
                  ],
                ),
                boxShadow: isPressed ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Color(0xFF27AE60).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_return,
                    color: Colors.white,
                    size: 60,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback? onPressed, {int flex = 1}) {
    bool isPressed = pressedButton == text;
    
    return Expanded(
      flex: flex,
      child: AnimatedBuilder(
        animation: _animations[text] ?? AlwaysStoppedAnimation(0.0),
        builder: (context, child) {
          double animationValue = _animations[text]?.value ?? 0.0;
          
          return Transform.scale(
            scale: 1.0 - (animationValue * 0.05),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPressed ? [
                    color.withOpacity(0.6),
                    color.withOpacity(0.8),
                  ] : [
                    color,
                    color.withOpacity(0.8),
                    color.withOpacity(0.6),
                  ],
                ),
                boxShadow: isPressed ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    _onButtonPress(text);
                    onPressed?.call();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: text == 'E' ? 32 : 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}