import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _floatingController;

  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 700), () {
      _textController.forward();
    });

    _floatingController.repeat(reverse: true);

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/landing');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [Color(0xffC75B12), Color(0xffF59E0B), Color(0xffFFD89B)],
          ),
        ),

        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    AnimatedBuilder(
                      animation: _floatingAnimation,

                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),

                          child: child,
                        );
                      },

                      child: ScaleTransition(
                        scale: _logoScale,

                        child: Container(
                          height: 140,
                          width: 140,

                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.white, Color(0xffFFF8F0)],
                            ),

                            borderRadius: BorderRadius.circular(35),

                            border: Border.all(color: Colors.white54, width: 2),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,

                                blurRadius: 30,

                                spreadRadius: 5,

                                offset: Offset(0, 15),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.food_bank,

                            size: 80,

                            color: Color(0xffE67E22),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    FadeTransition(
                      opacity: _textOpacity,

                      child: const Text(
                        "FRAD",

                        style: TextStyle(
                          fontSize: 48,

                          fontWeight: FontWeight.bold,

                          color: Colors.white,

                          letterSpacing: 3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      height: 4,

                      width: 70,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 15),

                    FadeTransition(
                      opacity: _textOpacity,

                      child: const Text(
                        "FRAD • Food Rescue & Donation",

                        style: TextStyle(
                          color: Colors.white,

                          fontSize: 20,

                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Together We Can End Food Waste",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white70,

                        fontSize: 14,

                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 150),

                    const Text(
                      "Save Food • Share Kindness • Reduce Waste",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Powered by FRAD",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
