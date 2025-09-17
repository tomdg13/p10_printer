import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'printdemo.dart'; // Import the PrintDemo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P10 Printer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'P10 Printer Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.example/printerState');
  bool _isPrinting = false;

  void _navigateToPrintDemo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrintDemo()),
    );
  }

  void _quickPrint() async {
    setState(() {
      _isPrinting = true;
    });

    try {
      await platform.invokeMethod('onPrint');
      _showSnackBar('Receipt printed successfully!');
    } on PlatformException catch (e) {
      _showSnackBar('Print failed: ${e.message}');
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.print,
              size: 80,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 20),
            Text(
              'P10 Printer Integration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Test your P10 printer connection and functionality',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Print Demo Button
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: _navigateToPrintDemo,
                icon: const Icon(Icons.settings),
                label: const Text('Open Print Demo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Print Button
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: _isPrinting ? null : _quickPrint,
                icon: _isPrinting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.print),
                label: Text(_isPrinting ? 'Printing...' : 'Quick Print'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}