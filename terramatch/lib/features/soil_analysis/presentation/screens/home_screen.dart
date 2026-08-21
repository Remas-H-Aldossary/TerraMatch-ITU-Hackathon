import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:terramatch/features/moisture_scan/presentation/screens/image_analysis_screen.dart';
import 'package:terramatch/features/recommendation/presentation/screens/ai_chat_screen.dart';
import 'package:terramatch/features/soil_analysis/presentation/widgets/service_card.dart';
import 'npk_input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2EADF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'TerraMatch',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // --- Greeting ---
              const Text(
                'Hello, Farmer 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a soil analysis method to get AI recommendations.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textMuted,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 28),

              // --- Section Title ---
              const Text(
                'Analysis Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // --- Card 1: Soil Nutrient Test ---
              ServiceCard(
                badgeText: 'Chemical Test',
                badgeBg: const Color(0xFFD8EFE0),
                badgeTextColor: const Color(0xFF1B431D),
                icon: Icons.science_outlined,
                title: 'Soil Nutrient Test',
                subtitle:
                    'Input NPK & pH parameters to find optimal crop matches',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NpkInputScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- Card 2: Moisture AI Scan ---
              ServiceCard(
                badgeText: 'Image AI',
                badgeBg: const Color(0xFFE0EAFD),
                badgeTextColor: const Color(0xFF1E40AF),
                icon: Icons.camera_alt_outlined,
                title: 'Moisture AI Scan',
                subtitle:
                    'Capture or upload a soil photo for instant moisture analysis',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImageAnalysisScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- Card 3: AI Agronomist (Featured) ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiChatScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F3E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.smart_toy_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Agronomist',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ask AI for instant guidance on soil health and crop care.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
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