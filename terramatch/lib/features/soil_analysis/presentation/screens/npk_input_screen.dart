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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Soil Nutrient Test',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Subtitle ---
              const Text(
                'Enter Field Parameters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Provide the soil chemistry and climate measurements to generate AI recommendations.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),

              // --- Soil Chemistry Section ---
              const SectionTitle(title: 'Soil Chemistry (NPK & pH)'),
              const SizedBox(height: 12),
              CustomInputField(
                label: 'Nitrogen (N)',
                hint: 'e.g. 90',
                icon: Icons.science_outlined,
                onChanged: notifier.updateN,
              ),
              CustomInputField(
                label: 'Phosphorus (P)',
                hint: 'e.g. 42',
                icon: Icons.science_outlined,
                onChanged: notifier.updateP,
              ),
              CustomInputField(
                label: 'Potassium (K)',
                hint: 'e.g. 43',
                icon: Icons.science_outlined,
                onChanged: notifier.updateK,
              ),
              CustomInputField(
                label: 'pH Level (0-14)',
                hint: 'e.g. 6.5',
                icon: Icons.speed_rounded,
                onChanged: notifier.updatePh,
              ),

              const SizedBox(height: 16),

              // --- Climate Data Section ---
              const SectionTitle(title: 'Climate Measurements'),
              const SizedBox(height: 12),
              CustomInputField(
                label: 'Temperature (°C)',
                hint: 'e.g. 25.5',
                icon: Icons.thermostat_rounded,
                onChanged: notifier.updateTemp,
              ),
              CustomInputField(
                label: 'Humidity (%)',
                hint: 'e.g. 80.0',
                icon: Icons.water_drop_outlined,
                onChanged: notifier.updateHumidity,
              ),
              CustomInputField(
                label: 'Rainfall (mm)',
                hint: 'e.g. 200.0',
                icon: Icons.cloudy_snowing,
                onChanged: notifier.updateRainfall,
              ),

              const SizedBox(height: 28),

              // --- Action Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
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
                                  backgroundColor: Colors.red,
                                  content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text(
                    'Analyze Soil Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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