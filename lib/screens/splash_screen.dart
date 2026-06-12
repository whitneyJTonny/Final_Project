import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  bool _showBackground = false;

  @override
  void initState() {
    super.initState();

    // ── Bounce animation (UNCHANGED)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: -18.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _bounceController.repeat(reverse: true);

    // ── Stage switch
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showBackground = true);
    });

    // ── Navigate
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── BACKGROUND ──
          AnimatedOpacity(
            opacity: _showBackground ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1000),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/demo3.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black),
                ),
                Container(color: Colors.black.withOpacity(0.55)),
              ],
            ),
          ),

          // ── CENTER CONTENT ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── BOUNCING CARD ──
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bounceAnimation.value),
                      child: child,
                    );
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 900),
                    width: 165,
                    height: 165,
                    decoration: BoxDecoration(
                      // 🔥 CLEAN PREMIUM BLACK TONE
                      color: _showBackground
                          ? Colors.black.withOpacity(0.45)
                          : const Color(0xFF120D00),

                      // 🔥 MATCHES YOUR IMAGE (MORE ROUNDED)
                      borderRadius: BorderRadius.circular(26),

                      // 🔥 SOFT GOLD BORDER
                      border: Border.all(
                        color: _showBackground
                            ? Colors.transparent
                            : const Color(0xFFFFB300).withOpacity(0.55),
                        width: 1.2,
                      ),

                      // 🔥 SUBTLE GLOW (REAL APP LOOK)
                      boxShadow: _showBackground
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFB300,
                                ).withOpacity(0.10),
                                blurRadius: 25,
                                spreadRadius: 1,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFB300,
                                ).withOpacity(0.28),
                                blurRadius: 35,
                                spreadRadius: 2,
                              ),
                            ],
                    ),

                    child: const Center(
                      child: Text(
                        'SOLAR M7',
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── TAGLINE ──
                AnimatedOpacity(
                  opacity: _showBackground ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: const Text(
                    'LET THERE BE LIGHT',
                    style: TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 5,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ── LOADING SPINNER ──
                AnimatedOpacity(
                  opacity: _showBackground ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF9800),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
