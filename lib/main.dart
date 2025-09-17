import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/pos_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Make the app full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  // Set preferred orientations to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P10 POS & Printer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: POSScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}