import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frad/screens/signupscreen.dart';

import 'firebase_options.dart';

import 'screens/splashscreen.dart';
import 'screens/landingpage.dart';
import 'screens/loginscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FRADApp());
}

class FRADApp extends StatelessWidget {
  const FRADApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FRAD',

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/landing': (context) => const LandingPage(),
        '/signin': (context) => const LoginScreen(),
        '/createaccount': (context) => const SignupScreen(),
      },
    );
  }
}
