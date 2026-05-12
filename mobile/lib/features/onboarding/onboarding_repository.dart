import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'onboarding_models.dart';

class OnboardingRepository {
  final Dio _dio;
  OnboardingRepository(this._dio);

  Future<List<OnboardingSlideDto>> fetchSlides() async {
    final res = await _dio.get<List<dynamic>>('/onboarding');
    final raw = res.data ?? const [];
    final slides = raw
        .whereType<Map<String, dynamic>>()
        .map(OnboardingSlideDto.fromJson)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return slides;
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(apiClientProvider));
});

final onboardingSlidesProvider = FutureProvider<List<OnboardingSlideDto>>((ref) async {
  final repo = ref.watch(onboardingRepositoryProvider);
  return repo.fetchSlides();
});
