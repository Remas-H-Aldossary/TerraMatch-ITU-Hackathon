import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terramatch/core/network/api_client.dart';
import 'package:terramatch/features/soil_analysis/data/models/soil_input_model.dart';

part 'npk_repository.g.dart';

class NpkRepository {
  final Dio _dio;

  NpkRepository(this._dio);

  Future<String> predictCrop(SoilInputModel input) async {
    try {
      final response = await _dio.post(
        'predict', 
        data: input.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['recommended_crop'] ?? 'Unknown Crop';
      } else {
        throw Exception('Failed to get crop recommendation');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? e.message ?? 'Network error occurred';
      throw Exception(errorMessage);
    }
  }
}

@riverpod
NpkRepository npkRepository(NpkRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return NpkRepository(dio);
}