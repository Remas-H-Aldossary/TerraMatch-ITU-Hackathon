import 'package:flutter/material.dart';
import 'package:terramatch/features/soil_analysis/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _leafSwayController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _leafRotation;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // Controller for the initial entry animations (logo scale and text fade)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeInOut,
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Controller for the continuous leaf swaying animation
    _leafSwayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _leafRotation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(
        parent: _leafSwayController,
        curve: Curves.easeInOut,
      ),
    );

    // Start entry animation first, then repeat leaf sway
    _entryController.forward().then((_) {
      _leafSwayController.repeat(reverse: true);
    });

    // Navigate to OnboardingScreen after splash delay
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _leafSwayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Green Container Matching Logo Design ---
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF285327), // Matching brand green
                  borderRadius: BorderRadius.circular(42),
                ),
                child: Center(
                  // --- Swaying Leaf Icon Animation ---
                  child: AnimatedBuilder(
                    animation: _leafRotation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _leafRotation.value,
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // --- TerraMatch Animated Title ---
            FadeTransition(
              opacity: _textFade,
              child: const Text(
                'TerraMatch',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}