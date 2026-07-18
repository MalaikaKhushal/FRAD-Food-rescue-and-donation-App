import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frad/models/food_model.dart';

import 'screens/add_food_screen.dart';
import 'package:frad/screens/providerdashboard.dart';
import 'package:frad/screens/signupscreen.dart';
import 'package:frad/screens/my_listings_screen.dart';
import 'package:frad/screens/reservations_screen.dart';

import 'firebase_options.dart';

import 'screens/splashscreen.dart';
import 'screens/landingpage.dart';
import 'screens/loginscreen.dart';
import 'screens/customerdashboard.dart';

// import 'screens/food_details_screen.dart';
// import 'screens/reservation_screen.dart';

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
        "/myListings": (context) => const MyListingsScreen(),

        //         '/foodDetails': (context) => const FoodDetailsScreen(),
        '/Reservations': (context) => const ReservationsScreen(),
        '/providerReservations': (context) => const ReservationsScreen(),
        '/addFood': (context) => const AddFoodScreen(),
        "/editFood": (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is FoodModel) {
            return AddFoodScreen(food: args);
          }
          return const AddFoodScreen();
        },

        // '/editFood': (_) => const EditFoodScreen(),

        // '/myListings': (_) => const MyListingsScreen(),

        // '/providerReservations': (_) =>
        //     const ProviderReservationsScreen(),

        // '/donations': (_) =>
        //     const ProviderDonationScreen(),
      },
    );
  }
}
