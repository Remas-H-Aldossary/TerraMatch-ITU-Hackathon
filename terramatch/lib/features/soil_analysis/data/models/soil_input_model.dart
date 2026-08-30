import 'package:flutter/foundation.dart';

@immutable
class SoilInputModel {
  final double? n;
  final double? p;
  final double? k;
  final double? ph;

  const SoilInputModel({
    this.n,
    this.p,
    this.k,
    this.ph,
  });

  bool get isValid =>
      n != null &&
      p != null &&
      k != null &&
      ph != null;

  SoilInputModel copyWith({
    Object? n = _sentinel,
    Object? p = _sentinel,
    Object? k = _sentinel,
    Object? ph = _sentinel,
  }) {
    return SoilInputModel(
      n: n == _sentinel ? this.n : n as double?,
      p: p == _sentinel ? this.p : p as double?,
      k: k == _sentinel ? this.k : k as double?,
      ph: ph == _sentinel ? this.ph : ph as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'n': n,
      'p': p,
      'k': k,
      'ph': ph,
    };
  }

  factory SoilInputModel.fromJson(Map<String, dynamic> json) {
    return SoilInputModel(
      n: (json['n'] as num?)?.toDouble(),
      p: (json['p'] as num?)?.toDouble(),
      k: (json['k'] as num?)?.toDouble(),
      ph: (json['ph'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoilInputModel &&
        other.n == n &&
        other.p == p &&
        other.k == k &&
        other.ph == ph;
  }

  @override
  int get hashCode {
    return Object.hash(
      n,
      p,
      k,
      ph,
    );
  }
}

const Object _sentinel = Object();