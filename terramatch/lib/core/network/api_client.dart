import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio dio(DioRef ref) {
  const String baseUrl = 'https://gondola-movable-refuse.ngrok-free.dev';

  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true', 
    },
  );

  final dio = Dio(options);

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('🌐 [DIO]: $obj'),
      ),
    );
  }

  return dio;
}