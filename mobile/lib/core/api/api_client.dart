import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Production server URL. Dev үшін override:
//   flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://ortax.online/api',
);

const _apiBaseUrl = apiBaseUrl;

/// Статикалық файлдарға арналған base URL (`/uploads/...` префиксі осы host-та
/// тұрады). Әдетте `apiBaseUrl`-дан `/api` суффиксі кесіп алынады.
/// Dev үшін override:
///   flutter run --dart-define=STATIC_BASE_URL=http://localhost:3000
String get staticBaseUrl {
  const explicit = String.fromEnvironment('STATIC_BASE_URL');
  if (explicit.isNotEmpty) return explicit;
  if (apiBaseUrl.endsWith('/api')) {
    return apiBaseUrl.substring(0, apiBaseUrl.length - 4);
  }
  return apiBaseUrl;
}

/// Бэкенд қайтаратын асет жолын толық URL-ге айналдырады.
/// - `null`/бос → `null`
/// - `http://` немесе `https://` → сол күйінде
/// - `/uploads/...` → `${staticBaseUrl}/uploads/...`
String? fullAssetUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final normalized = path.startsWith('/') ? path : '/$path';
  return '$staticBaseUrl$normalized';
}

/// LiveAvatar `index.html` орналасу URL-ы. Әдетте бэкендтің `public/`
/// папкасында. Dev үшін:
///   flutter run --dart-define=LIVE_AVATAR_HOST_URL=http://localhost:3000/live-avatar/index.html
const liveAvatarHostUrl = String.fromEnvironment(
  'LIVE_AVATAR_HOST_URL',
  defaultValue: 'https://ortax.online/live-avatar/index.html',
);

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  return dio;
});
