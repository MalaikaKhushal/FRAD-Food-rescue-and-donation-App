import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'models/food_model.dart';

import 'screens/splashscreen.dart';
import 'screens/landingpage.dart';
import 'screens/loginscreen.dart';
import 'screens/signupscreen.dart';
import 'screens/customerdashboard.dart';
import 'screens/providerdashboard.dart';
import 'screens/add_food_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/food_detail_screen.dart';

import 'screens/orders_screen.dart';

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
        '/customer': (context) => const CustomerDashboard(),

        "/orders": (context) => const OrdersScreen(),

        "/myListings": (context) => const MyListingsScreen(),
        '/addFood': (context) => const AddFoodScreen(),

        // ✅ FIXED: Food Detail Screen Route with Arguments
        '/foodDetails': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is FoodModel) {
            return FoodDetailScreen(food: args);
          }
          // Agar data na mile to fallback (safety check)
          return Scaffold(
            body: const Center(child: Text("Food data not found!")),
          );
        },

        // ✅ FIXED: Edit Food Route
        "/editFood": (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is FoodModel) {
            return AddFoodScreen(food: args);
          }
          return const AddFoodScreen();
        },
      },
    );
  }
}
