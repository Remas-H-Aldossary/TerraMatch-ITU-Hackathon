import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terramatch/features/splash/presentation/screens/splash_screen.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TerraMatchApp(),
    ),
  );
}

class TerraMatchApp extends StatelessWidget {
  const TerraMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerraMatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background, 
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,               
          primary: AppColors.primary,                 
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}