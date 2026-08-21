import 'package:flutter/foundation.dart';

@immutable
class SoilInputModel {
  final double? n;
  final double? p;
  final double? k;
  final double? ph;
  final double? temperature;
  final double? humidity;
  final double? rainfall;

  const SoilInputModel({
    this.n,
    this.p,
    this.k,
    this.ph,
    this.temperature,
    this.humidity,
    this.rainfall,
  });

  bool get isValid =>
      n != null &&
      p != null &&
      k != null &&
      ph != null &&
      temperature != null &&
      humidity != null &&
      rainfall != null;

  SoilInputModel copyWith({
    Object? n = _sentinel,
    Object? p = _sentinel,
    Object? k = _sentinel,
    Object? ph = _sentinel,
    Object? temperature = _sentinel,
    Object? humidity = _sentinel,
    Object? rainfall = _sentinel,
  }) {
    return SoilInputModel(
      n: n == _sentinel ? this.n : n as double?,
      p: p == _sentinel ? this.p : p as double?,
      k: k == _sentinel ? this.k : k as double?,
      ph: ph == _sentinel ? this.ph : ph as double?,
      temperature: temperature == _sentinel ? this.temperature : temperature as double?,
      humidity: humidity == _sentinel ? this.humidity : humidity as double?,
      rainfall: rainfall == _sentinel ? this.rainfall : rainfall as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'N': n,
      'P': p,
      'K': k,
      'ph': ph,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
    };
  }

  factory SoilInputModel.fromJson(Map<String, dynamic> json) {
    return SoilInputModel(
      n: (json['N'] as num?)?.toDouble(),
      p: (json['P'] as num?)?.toDouble(),
      k: (json['K'] as num?)?.toDouble(),
      ph: (json['ph'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      rainfall: (json['rainfall'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoilInputModel &&
        other.n == n &&
        other.p == p &&
        other.k == k &&
        other.ph == ph &&
        other.temperature == temperature &&
        other.humidity == humidity &&
        other.rainfall == rainfall;
  }

  @override
  int get hashCode {
    return Object.hash(
      n,
      p,
      k,
      ph,
      temperature,
      humidity,
      rainfall,
    );
  }
}

// كائن وهمي للتمييز بين عدم إرسال المعامل وإرسال قيمة null صريحة
const Object _sentinel = Object();