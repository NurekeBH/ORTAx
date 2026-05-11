import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _defaultBaseUrl() {
  if (kIsWeb) return 'http://localhost:3000/api';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
  return 'http://localhost:3000/api';
}

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _defaultBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  return dio;
});
