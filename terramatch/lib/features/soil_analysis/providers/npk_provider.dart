import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:terramatch/features/soil_analysis/data/models/soil_input_model.dart';
import 'package:terramatch/features/soil_analysis/data/repositories/npk_repository.dart';

part 'npk_provider.g.dart';

@riverpod
class NpkFormNotifier extends _$NpkFormNotifier {
  @override
  SoilInputModel build() => const SoilInputModel();

  void updateN(String v) => state = state.copyWith(n: double.tryParse(v));
  void updateP(String v) => state = state.copyWith(p: double.tryParse(v));
  void updateK(String v) => state = state.copyWith(k: double.tryParse(v));
  void updatePh(String v) => state = state.copyWith(ph: double.tryParse(v));
  void updateTemp(String v) => state = state.copyWith(temperature: double.tryParse(v));
  void updateHumidity(String v) => state = state.copyWith(humidity: double.tryParse(v));
  void updateRainfall(String v) => state = state.copyWith(rainfall: double.tryParse(v));

  Future<String> submitAnalysis() async {
    final repository = ref.read(npkRepositoryProvider);
    return await repository.predictCrop(state);
  }

  void reset() => state = const SoilInputModel();
}