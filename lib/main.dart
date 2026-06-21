import 'package:flutter/material.dart';
import 'screens/splashscreen.dart';
import 'screens/landingpage.dart';

void main() {
  runApp(const FRADApp());
}

class FRADApp extends StatelessWidget {
  const FRADApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FRAD',
      home: const LandingScreen(),
    );
  }
}
