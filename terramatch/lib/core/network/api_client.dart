import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio dio(DioRef ref) {
  String baseUrl = 'http://10.0.2.2:8000/api/'; 
  
  if (kIsWeb) {
    baseUrl = 'http://localhost:8000/api/';
  } else if (Platform.isIOS) {
    baseUrl = 'http://127.0.0.1:8000/api/';
  }

  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
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