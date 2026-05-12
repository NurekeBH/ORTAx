import '../../core/api/api_client.dart';

/// Backend Category entity DTO.
class JournalCategory {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final String? coverImage;
  final int sortOrder;

  const JournalCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.coverImage,
    this.sortOrder = 0,
  });

  String? get coverImageUrl => fullAssetUrl(coverImage);

  factory JournalCategory.fromJson(Map<String, dynamic> json) {
    return JournalCategory(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      coverImage: json['coverImage'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Listing-кезіндегі Journal DTO.
class ApiJournal {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final String? pdfUrl;
  final String? trailerVideoUrl;
  final String? subject;
  final String? gradeLevel;
  final String? slug;
  final String? author;
  final String language;
  final List<String> tags;
  final bool featured;
  final bool published;
  final DateTime? publishedAt;
  final int viewsCount;
  final String? categoryId;
  final JournalCategory? category;
  final DateTime? createdAt;

  const ApiJournal({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    this.pdfUrl,
    this.trailerVideoUrl,
    this.subject,
    this.gradeLevel,
    this.slug,
    this.author,
    this.language = 'kk',
    this.tags = const [],
    this.featured = false,
    this.published = true,
    this.publishedAt,
    this.viewsCount = 0,
    this.categoryId,
    this.category,
    this.createdAt,
  });

  String? get coverImageUrl => fullAssetUrl(coverImage);
  String? get pdfFullUrl => fullAssetUrl(pdfUrl);
  String? get trailerVideoFullUrl => fullAssetUrl(trailerVideoUrl);

  factory ApiJournal.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final tags = <String>[];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t is String) tags.add(t);
      }
    }
    final cat = json['category'];
    return ApiJournal(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      coverImage: json['coverImage'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      trailerVideoUrl: json['trailerVideoUrl'] as String?,
      subject: json['subject'] as String?,
      gradeLevel: json['gradeLevel']?.toString(),
      slug: json['slug'] as String?,
      author: json['author'] as String?,
      language: (json['language'] as String?) ?? 'kk',
      tags: tags,
      featured: json['featured'] as bool? ?? false,
      published: json['published'] as bool? ?? true,
      publishedAt: _parseDate(json['publishedAt']),
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      categoryId: json['categoryId'] as String?,
      category: cat is Map<String, dynamic>
          ? JournalCategory.fromJson(cat)
          : null,
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

/// AR asset (page-ге байланған 3D/audio контент).
class ArAsset {
  final String id;
  final String triggerMarker;
  final String? modelUrl;
  final String? audioUrl;
  final String? animationSet;

  const ArAsset({
    required this.id,
    required this.triggerMarker,
    this.modelUrl,
    this.audioUrl,
    this.animationSet,
  });

  String? get modelFullUrl => fullAssetUrl(modelUrl);
  String? get audioFullUrl => fullAssetUrl(audioUrl);

  factory ArAsset.fromJson(Map<String, dynamic> json) {
    return ArAsset(
      id: json['id'] as String,
      triggerMarker: (json['triggerMarker'] as String?) ?? '',
      modelUrl: json['modelUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      animationSet: json['animationSet'] as String?,
    );
  }
}

class ApiJournalPage {
  final String id;
  final int pageNumber;
  final String? title;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;
  final String? text;
  final List<ArAsset> arAssets;

  const ApiJournalPage({
    required this.id,
    required this.pageNumber,
    this.title,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.text,
    this.arAssets = const [],
  });

  String? get imageFullUrl => fullAssetUrl(imageUrl);
  String? get audioFullUrl => fullAssetUrl(audioUrl);
  String? get videoFullUrl => fullAssetUrl(videoUrl);

  factory ApiJournalPage.fromJson(Map<String, dynamic> json) {
    final raw = json['arAssets'];
    final assets = <ArAsset>[];
    if (raw is List) {
      for (final a in raw) {
        if (a is Map<String, dynamic>) {
          assets.add(ArAsset.fromJson(a));
        }
      }
    }
    return ApiJournalPage(
      id: json['id'] as String,
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 0,
      title: json['title'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      text: json['text'] as String?,
      arAssets: assets,
    );
  }
}

class ApiJournalDetail extends ApiJournal {
  final List<ApiJournalPage> pages;

  const ApiJournalDetail({
    required super.id,
    required super.title,
    required super.description,
    super.coverImage,
    super.pdfUrl,
    super.trailerVideoUrl,
    super.subject,
    super.gradeLevel,
    super.slug,
    super.author,
    super.language,
    super.tags,
    super.featured,
    super.published,
    super.publishedAt,
    super.viewsCount,
    super.categoryId,
    super.category,
    super.createdAt,
    this.pages = const [],
  });

  bool get hasAr => pages.any((p) => p.arAssets.isNotEmpty);

  factory ApiJournalDetail.fromJson(Map<String, dynamic> json) {
    final raw = json['pages'];
    final pages = <ApiJournalPage>[];
    if (raw is List) {
      for (final p in raw) {
        if (p is Map<String, dynamic>) {
          pages.add(ApiJournalPage.fromJson(p));
        }
      }
    }
    pages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

    final base = ApiJournal.fromJson(json);
    return ApiJournalDetail(
      id: base.id,
      title: base.title,
      description: base.description,
      coverImage: base.coverImage,
      pdfUrl: base.pdfUrl,
      trailerVideoUrl: base.trailerVideoUrl,
      subject: base.subject,
      gradeLevel: base.gradeLevel,
      slug: base.slug,
      author: base.author,
      language: base.language,
      tags: base.tags,
      featured: base.featured,
      published: base.published,
      publishedAt: base.publishedAt,
      viewsCount: base.viewsCount,
      categoryId: base.categoryId,
      category: base.category,
      createdAt: base.createdAt,
      pages: pages,
    );
  }
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  if (raw is String && raw.isNotEmpty) {
    return DateTime.tryParse(raw);
  }
  return null;
}
