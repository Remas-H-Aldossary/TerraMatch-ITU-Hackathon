import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CropResultScreen extends StatelessWidget {
  final dynamic cropName;

  const CropResultScreen({super.key, required this.cropName});

  @override
  Widget build(BuildContext context) {
    String recommendedCrop = 'TOMATO';
    double confidencePercentage = 83.0;
    List<String> unsuitableCrops = ['Soybean', 'Potato'];
    String modelUsed = 'TerraMatch';

    final String rawString = cropName.toString();

    // 1. Parsing Logic
    if (cropName is Map) {
      final mapData = cropName as Map;
      modelUsed = mapData['model_used']?.toString() ?? modelUsed;
      final resultMap = mapData['result'] is Map
          ? mapData['result'] as Map
          : mapData;

      recommendedCrop =
          resultMap['recommended_crop']?.toString() ?? recommendedCrop;
      confidencePercentage =
          double.tryParse(
            resultMap['confidence_percentage']?.toString() ?? '',
          ) ??
          confidencePercentage;
      if (resultMap['unsuitable_crops'] is List) {
        unsuitableCrops = List<String>.from(
          (resultMap['unsuitable_crops'] as List).map((x) => x.toString()),
        );
      }
    } else {
      try {
        final Map<String, dynamic> parsedData = jsonDecode(rawString);
        modelUsed = parsedData['model_used']?.toString() ?? modelUsed;
        final resultMap = parsedData['result'] is Map<String, dynamic>
            ? parsedData['result'] as Map<String, dynamic>
            : parsedData;

        recommendedCrop =
            resultMap['recommended_crop']?.toString() ?? rawString;
        confidencePercentage =
            double.tryParse(
              resultMap['confidence_percentage']?.toString() ?? '',
            ) ??
            confidencePercentage;
        if (resultMap['unsuitable_crops'] is List) {
          unsuitableCrops = List<String>.from(
            (resultMap['unsuitable_crops'] as List).map((x) => x.toString()),
          );
        }
      } catch (_) {
        final cropMatch = RegExp(
          r'recommended_crop:\s*([a-zA-Z0-9_\s]+)',
          caseSensitive: false,
        ).firstMatch(rawString);
        if (cropMatch != null)
          recommendedCrop =
              cropMatch.group(1)?.split(',').first.trim() ?? rawString;

        final confMatch = RegExp(
          r'confidence_percentage:\s*([0-9.]+)',
          caseSensitive: false,
        ).firstMatch(rawString);
        if (confMatch != null)
          confidencePercentage =
              double.tryParse(confMatch.group(1) ?? '') ?? confidencePercentage;

        final unsuitableMatch = RegExp(
          r'unsuitable_crops:\s*\[(.*?)\]',
          caseSensitive: false,
        ).firstMatch(rawString);
        if (unsuitableMatch != null) {
          final items = unsuitableMatch.group(1)?.split(',') ?? [];
          unsuitableCrops = items
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }

        final modelMatch = RegExp(
          r'model_used:\s*([a-zA-Z0-9_\s]+)',
          caseSensitive: false,
        ).firstMatch(rawString);
        if (modelMatch != null)
          modelUsed = modelMatch.group(1)?.split(',').first.trim() ?? modelUsed;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text(
          'Analysis Result',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B),
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    // Badge: AI Model Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.psychology_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI Engine: $modelUsed',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main Hero Card (Recommended Crop)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              size: 54,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'RECOMMENDED CROP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recommendedCrop.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Confidence Bar Inside Hero Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Match Confidence',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${confidencePercentage.toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: confidencePercentage / 100,
                                    minHeight: 8,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.2,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.insights_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Based on your NPK and pH levels, this crop is optimal for maximum yield.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Unsuitable Crops Section Card
                    if (unsuitableCrops.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade50.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Unsuitable Crops',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: unsuitableCrops.map((crop) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: Colors.red.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        crop,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Action Button
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text(
                    'Analyze Another Sample',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
