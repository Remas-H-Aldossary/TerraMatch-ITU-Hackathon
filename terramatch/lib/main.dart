import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terramatch/features/Auth/presentation/screens/auth_screen.dart';
import 'package:terramatch/home_screen.dart';
import 'package:terramatch/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final bool isOnboardingSeen = prefs.getBool('is_onboarding_seen') ?? false;
  final bool isLoggedInOrGuest = (prefs.getBool('is_logged_in') ?? false) || (prefs.getBool('is_guest') ?? false);

  Widget initialScreen;
  if (!isOnboardingSeen) {
    initialScreen = const OnboardingScreen();
  } else if (!isLoggedInOrGuest) {
    initialScreen = const AuthScreen();
  } else {
    initialScreen = const HomeScreen();
  }

  runApp(
    ProviderScope(
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TerraMatch',
      home: initialScreen,
    );
  }
}