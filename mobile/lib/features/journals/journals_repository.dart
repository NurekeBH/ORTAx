import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'journal_api_models.dart';

/// Backend-тің `/api/journals*` endpoint-теріне кіруге арналған repository.
/// JWT header автоматты түрде `AuthController._wireDioInterceptor`-да тіркеледі.
class JournalsRepository {
  final Dio _dio;
  JournalsRepository(this._dio);

  /// `GET /api/journals/categories` — sortOrder ASC.
  Future<List<JournalCategory>> fetchCategories() async {
    final res = await _dio.get<dynamic>('/journals/categories');
    return _mapList(res.data, JournalCategory.fromJson);
  }

  /// `GET /api/journals` — published journals.
  Future<List<ApiJournal>> fetchJournals({
    String? categorySlug,
    String? gradeLevel,
    String? language,
    bool? featured,
    String? search,
  }) async {
    final query = <String, dynamic>{};
    if (categorySlug != null && categorySlug.isNotEmpty) {
      query['category'] = categorySlug;
    }
    if (gradeLevel != null && gradeLevel.isNotEmpty) {
      query['gradeLevel'] = gradeLevel;
    }
    if (language != null && language.isNotEmpty) {
      query['language'] = language;
    }
    if (featured != null) query['featured'] = featured;
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    final res = await _dio.get<dynamic>(
      '/journals',
      queryParameters: query.isEmpty ? null : query,
    );
    return _mapList(res.data, ApiJournal.fromJson);
  }

  /// `GET /api/journals/:id` — pages + arAssets кіреді. View counter auto-инкремент.
  Future<ApiJournalDetail> fetchJournal(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/journals/$id');
    final data = res.data;
    if (data == null) {
      throw StateError('Empty journal response');
    }
    return ApiJournalDetail.fromJson(data);
  }

  /// `GET /api/journals/slug/:slug`.
  Future<ApiJournalDetail> fetchJournalBySlug(String slug) async {
    final res = await _dio.get<Map<String, dynamic>>('/journals/slug/$slug');
    final data = res.data;
    if (data == null) {
      throw StateError('Empty journal response');
    }
    return ApiJournalDetail.fromJson(data);
  }

  /// `POST /api/journals/:id/view` — view counter metric.
  Future<void> markJournalView(String id) async {
    try {
      await _dio.post<void>('/journals/$id/view');
    } catch (_) {
      // View count жіберілмесе UX-қа әсер етпеуі керек.
    }
  }

  List<T> _mapList<T>(dynamic raw, T Function(Map<String, dynamic>) build) {
    if (raw is List) {
      return [
        for (final item in raw)
          if (item is Map<String, dynamic>) build(item),
      ];
    }
    return const [];
  }
}

final journalsRepositoryProvider = Provider<JournalsRepository>((ref) {
  return JournalsRepository(ref.watch(apiClientProvider));
});

/// Категориялар тізімі.
final categoriesProvider = FutureProvider<List<JournalCategory>>((ref) async {
  return ref.watch(journalsRepositoryProvider).fetchCategories();
});

/// Журналдар тізімінің сүзгі (filter) параметрі.
class JournalsQuery {
  final String? categorySlug;
  final String? gradeLevel;
  final String? language;
  final bool? featured;
  final String? search;

  const JournalsQuery({
    this.categorySlug,
    this.gradeLevel,
    this.language,
    this.featured,
    this.search,
  });

  JournalsQuery copyWith({
    String? categorySlug,
    String? gradeLevel,
    String? language,
    bool? featured,
    String? search,
    bool clearCategory = false,
    bool clearSearch = false,
  }) {
    return JournalsQuery(
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      gradeLevel: gradeLevel ?? this.gradeLevel,
      language: language ?? this.language,
      featured: featured ?? this.featured,
      search: clearSearch ? null : (search ?? this.search),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JournalsQuery &&
        other.categorySlug == categorySlug &&
        other.gradeLevel == gradeLevel &&
        other.language == language &&
        other.featured == featured &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(
        categorySlug,
        gradeLevel,
        language,
        featured,
        search,
      );
}

class JournalsQueryNotifier extends Notifier<JournalsQuery> {
  @override
  JournalsQuery build() => const JournalsQuery();

  void setCategory(String? slug) {
    state = state.copyWith(
      categorySlug: slug,
      clearCategory: slug == null,
    );
  }

  void setSearch(String? q) {
    state = state.copyWith(
      search: q,
      clearSearch: q == null || q.isEmpty,
    );
  }

  void setGradeLevel(String? grade) =>
      state = state.copyWith(gradeLevel: grade);
  void setLanguage(String? lang) => state = state.copyWith(language: lang);
  void setFeatured(bool? featured) =>
      state = state.copyWith(featured: featured);
}

final journalsQueryProvider =
    NotifierProvider<JournalsQueryNotifier, JournalsQuery>(
  JournalsQueryNotifier.new,
);

/// Журналдар тізімі — query өзгерсе автоматты re-fetch.
final journalsProvider = FutureProvider<List<ApiJournal>>((ref) async {
  final q = ref.watch(journalsQueryProvider);
  return ref.watch(journalsRepositoryProvider).fetchJournals(
        categorySlug: q.categorySlug,
        gradeLevel: q.gradeLevel,
        language: q.language,
        featured: q.featured,
        search: q.search,
      );
});

/// Бір журналдың толық деректері (pages + arAssets).
final journalDetailProvider =
    FutureProvider.family<ApiJournalDetail, String>((ref, id) async {
  final repo = ref.watch(journalsRepositoryProvider);
  final detail = await repo.fetchJournal(id);
  // View metric — fire and forget.
  repo.markJournalView(id);
  return detail;
});
