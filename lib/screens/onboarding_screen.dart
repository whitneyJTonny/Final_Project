import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  late AnimationController _textAnimController;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Power Your Home\nAnywhere',
      'description':
          'Complete solar kit with panel, lights and control system — built for rural Africa.',
      'image': 'assets/demo1.jpg',
      'icon': Icons.solar_power_rounded,
      'accent': const Color(0xFFFF9800),
    },
    {
      'title': 'Smart Energy\nControl',
      'description':
          'Monitor and manage your power usage in real-time with ease.',
      'image': 'assets/demo2.jpg',
      'icon': Icons.bolt_rounded,
      'accent': const Color(0xFFFF9800),
    },
    {
      'title': 'Reliable Light,\nEvery Night',
      'description':
          'Bright, efficient lighting powered by the sun — no grid needed.',
      'image': 'assets/demo3.jpg',
      'icon': Icons.light_mode_rounded,
      'accent': const Color(0xFFFF9800),
    },
  ];

  @override
  void initState() {
    super.initState();

    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _textAnimController, curve: Curves.easeOut));
    _textFade = CurvedAnimation(
        parent: _textAnimController, curve: Curves.easeOut);
    _textAnimController.forward();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _pages.length - 1) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        _textAnimController.forward(from: 0);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _textAnimController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    _timer.cancel();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          _textAnimController.forward(from: 0);
        },
        itemBuilder: (context, index) {
          final page = _pages[index];
          final isLast = index == _pages.length - 1;
          final accent = page['accent'] as Color;

          return Stack(
            children: [
              // ── Background image ──
              Positioned.fill(
                child: Image.asset(
                  page['image'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF1A1A1A)),
                ),
              ),

              // ── Gradient (bottom heavy) ──
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x33000000),
                        Color(0x55000000),
                        Color(0xEE000000),
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Skip button ──
              Positioned(
                top: 0,
                right: 16,
                child: SafeArea(
                  child: TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.dmSans(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom content ──
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon badge
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: accent.withValues(alpha: 0.4)),
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            color: accent,
                            size: 24,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Title
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textFade,
                            child: Text(
                              page['title'] as String,
                              style: GoogleFonts.archivo(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Description
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textFade,
                            child: Text(
                              page['description'] as String,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: Colors.white60,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Dots + button row
                        Row(
                          children: [
                            // Dot indicators
                            Row(
                              children: List.generate(_pages.length, (i) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 6),
                                  width: _currentPage == i ? 24 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: _currentPage == i
                                        ? accent
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              }),
                            ),

                            const Spacer(),

                            // Next / Get Started button
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: isLast
                                  ? ElevatedButton(
                                      key: const ValueKey('get_started'),
                                      onPressed: _goToLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        'GET STARTED',
                                        style: GoogleFonts.archivo(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      key: const ValueKey('next'),
                                      onTap: () {
                                        _timer.cancel();
                                        if (_currentPage < _pages.length - 1) {
                                          _currentPage++;
                                          _pageController.animateToPage(
                                            _currentPage,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                          _textAnimController.forward(from: 0);
                                          setState(() {});
                                        }
                                      },
                                      child: Container(
                                        width: 54,
                                        height: 54,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: accent,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}