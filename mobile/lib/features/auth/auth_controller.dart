import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/api_client.dart';
import 'auth_repository.dart';

const _tokenKey = 'auth.token';
const _phoneKey = 'auth.phone';

class AuthState {
  final String? token;
  final String? phone;
  final bool loading;
  final String? error;
  const AuthState({this.token, this.phone, this.loading = false, this.error});

  bool get isAuthenticated => (token ?? '').isNotEmpty;

  AuthState copyWith({
    String? token,
    String? phone,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      token: token ?? this.token,
      phone: phone ?? this.phone,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _load();
    _wireDioInterceptor();
    return const AuthState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final phone = prefs.getString(_phoneKey);
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(token: token, phone: phone);
    }
  }

  void _wireDioInterceptor() {
    final dio = ref.read(apiClientProvider);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = state.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<void> _persist(String token, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_phoneKey, phone);
  }

  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final token = await repo.login(phone: phone, password: password);
      await _persist(token, phone);
      state = state.copyWith(token: token, phone: phone, loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _humanError(e));
      return false;
    }
  }

  Future<bool> requestRegister({required String phone, required String password}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.requestRegister(phone: phone, password: password);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _humanError(e));
      return false;
    }
  }

  Future<bool> verifyRegister({required String phone, required String otp}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final token = await repo.verifyRegister(phone: phone, otp: otp);
      await _persist(token, phone);
      state = state.copyWith(token: token, phone: phone, loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _humanError(e));
      return false;
    }
  }

  Future<bool> requestReset({required String phone}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.requestReset(phone: phone);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _humanError(e));
      return false;
    }
  }

  Future<bool> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(phone: phone, otp: otp, newPassword: newPassword);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _humanError(e));
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_phoneKey);
    state = const AuthState();
  }

  String _humanError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        if (msg is List) return msg.join(', ');
        return msg.toString();
      }
      final status = e.response?.statusCode;
      if (status == 401) return 'Телефон не құпиясөз дұрыс емес';
      if (status == 409) return 'Бұл нөмір тіркелген';
      if (status == 400) return 'Деректер дұрыс емес';
      return 'Желі қатесі';
    }
    return e.toString();
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
