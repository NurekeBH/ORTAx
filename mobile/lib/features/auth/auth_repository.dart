import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<String> login({required String phone, required String password}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
    final token = res.data?['accessToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token not received');
    }
    return token;
  }

  Future<void> requestRegister({required String phone, required String password}) async {
    await _dio.post<Map<String, dynamic>>(
      '/auth/register/request',
      data: {'phone': phone, 'password': password},
    );
  }

  Future<String> verifyRegister({required String phone, required String otp}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/register/verify',
      data: {'phone': phone, 'otp': otp},
    );
    final token = res.data?['accessToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token not received');
    }
    return token;
  }

  Future<void> requestReset({required String phone}) async {
    await _dio.post<Map<String, dynamic>>(
      '/auth/reset/request',
      data: {'phone': phone},
    );
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/auth/reset/confirm',
      data: {'phone': phone, 'otp': otp, 'newPassword': newPassword},
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});
