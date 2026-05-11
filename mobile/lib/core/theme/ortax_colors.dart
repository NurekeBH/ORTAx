import 'package:flutter/material.dart';

@immutable
class OrtaxColors extends ThemeExtension<OrtaxColors> {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color accentSoft;

  const OrtaxColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.accentSoft,
  });

  static const light = OrtaxColors(
    background: Color(0xFFF7F4ED),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF0EBE0),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF555555),
    border: Color(0xFFE0DACB),
    accentSoft: Color(0xFFE8C766),
  );

  static const dark = OrtaxColors(
    background: Color(0xFF0F1218),
    surface: Color(0xFF1A1F28),
    surfaceMuted: Color(0xFF232934),
    textPrimary: Color(0xFFF1F2F4),
    textSecondary: Color(0xFFA0A8B5),
    border: Color(0xFF2B3340),
    accentSoft: Color(0xFFB58A2E),
  );

  static OrtaxColors of(BuildContext context) {
    return Theme.of(context).extension<OrtaxColors>() ?? light;
  }

  @override
  OrtaxColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? accentSoft,
  }) {
    return OrtaxColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      accentSoft: accentSoft ?? this.accentSoft,
    );
  }

  @override
  OrtaxColors lerp(ThemeExtension<OrtaxColors>? other, double t) {
    if (other is! OrtaxColors) return this;
    return OrtaxColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
    );
  }
}

extension OrtaxColorsContext on BuildContext {
  OrtaxColors get colors => OrtaxColors.of(this);
}
