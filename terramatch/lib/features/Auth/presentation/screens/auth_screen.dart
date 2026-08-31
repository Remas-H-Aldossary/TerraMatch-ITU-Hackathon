import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terramatch/home_screen.dart';
import '../../../../core/constants/app_colors.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  Future<void> _continueAsGuest(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', true);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.eco_rounded, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Welcome to TerraMatch',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to sync your soil data across devices',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                },
                child: const Text('Sign In', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                },
                child: const Text('Create Account', style: TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => _continueAsGuest(context),
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}