import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SolarApp());
}

class SolarApp extends StatelessWidget {
  const SolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solar M7',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: false,
      ),
      home: const SplashScreen(), // App starts here
    );
  }
}
