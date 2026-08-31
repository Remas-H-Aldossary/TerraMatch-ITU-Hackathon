import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terramatch/features/soil_analysis/presentation/widgets/custom_input_field.dart';
import 'package:terramatch/features/soil_analysis/presentation/widgets/section_title.dart';
import 'package:terramatch/features/soil_analysis/providers/npk_provider.dart';
import '../../../../core/constants/app_colors.dart';
import 'crop_result_screen.dart';

class NpkInputScreen extends ConsumerWidget {
  const NpkInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilData = ref.watch(npkFormNotifierProvider);
    final notifier = ref.read(npkFormNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Soil Nutrient Test',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Card ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.science_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Field Parameters',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Enter NPK ratios and pH level to get precise AI crop recommendations.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Form Section Title ---
                    const SectionTitle(title: 'Soil Chemistry Parameters'),
                    const SizedBox(height: 14),

                    // --- Form Card (Spacious Vertical Fields) ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomInputField(
                            label: 'Nitrogen (N)',
                            hint: 'e.g. 90 mg/kg',
                            icon: Icons.grass_rounded,
                            onChanged: notifier.updateN,
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            label: 'Phosphorus (P)',
                            hint: 'e.g. 42 mg/kg',
                            icon: Icons.bubble_chart_rounded,
                            onChanged: notifier.updateP,
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            label: 'Potassium (K)',
                            hint: 'e.g. 43 mg/kg',
                            icon: Icons.grain_rounded,
                            onChanged: notifier.updateK,
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            label: 'pH Level (0 - 14)',
                            hint: 'e.g. 6.5',
                            icon: Icons.thermostat_rounded,
                            onChanged: notifier.updatePh,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // --- Fixed Bottom Action Button ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: soilData.isValid
                      ? () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );

                          try {
                            final result = await notifier.submitAnalysis();

                            if (context.mounted) {
                              Navigator.pop(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CropResultScreen(cropName: result),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  content: Text(
                                    'Error: ${e.toString().replaceAll('Exception: ', '')}',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Analyze Soil Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}