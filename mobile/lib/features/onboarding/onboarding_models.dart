class OnboardingSlideDto {
  final String id;
  final int position;
  final String? iconSvg;
  final String titleKk;
  final String? titleRu;
  final String? titleEn;
  final String descriptionKk;
  final String? descriptionRu;
  final String? descriptionEn;

  const OnboardingSlideDto({
    required this.id,
    required this.position,
    this.iconSvg,
    required this.titleKk,
    this.titleRu,
    this.titleEn,
    required this.descriptionKk,
    this.descriptionRu,
    this.descriptionEn,
  });

  factory OnboardingSlideDto.fromJson(Map<String, dynamic> json) {
    return OnboardingSlideDto(
      id: json['id'] as String? ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      iconSvg: json['iconSvg'] as String?,
      titleKk: json['titleKk'] as String? ?? '',
      titleRu: json['titleRu'] as String?,
      titleEn: json['titleEn'] as String?,
      descriptionKk: json['descriptionKk'] as String? ?? '',
      descriptionRu: json['descriptionRu'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
    );
  }

  String title(String locale) {
    return switch (locale) {
      'ru' => (titleRu?.isNotEmpty ?? false) ? titleRu! : titleKk,
      'en' => (titleEn?.isNotEmpty ?? false) ? titleEn! : titleKk,
      _ => titleKk,
    };
  }

  String description(String locale) {
    return switch (locale) {
      'ru' => (descriptionRu?.isNotEmpty ?? false) ? descriptionRu! : descriptionKk,
      'en' => (descriptionEn?.isNotEmpty ?? false) ? descriptionEn! : descriptionKk,
      _ => descriptionKk,
    };
  }
}
