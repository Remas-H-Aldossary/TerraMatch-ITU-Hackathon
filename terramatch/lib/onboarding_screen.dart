import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terramatch/features/Auth/presentation/screens/auth_screen.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // --- Logo Container ---
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25), 
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 40),

              // --- Title ---
              const Text(
                'Welcome to TerraMatch',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // --- Subtitle ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Analyze your soil with AI precision and get the best recommendations for your crops.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(),

              // --- Get Started Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('is_onboarding_seen', true);

                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}