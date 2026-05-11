import 'package:flutter/services.dart' show rootBundle;

class ArMarkerAsset {
  final String imagePath;
  final String? modelPath;
  final String title;
  final String subtitle;

  const ArMarkerAsset({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.modelPath,
  });
}

const Map<String, ArMarkerAsset> arMarkerAssets = {
  'khwarizmi-marker-1': ArMarkerAsset(
    imagePath: 'assets/journal/png/1.png',
    modelPath: 'assets/journal/models/khwarizmi.glb',
    title: 'Әл-Хорезми',
    subtitle: 'Бағдат, Даналық үйі · IX ғ.',
  ),
  'khwarizmi-marker-2': ArMarkerAsset(
    imagePath: 'assets/journal/png/2.png',
    modelPath: 'assets/journal/models/khwarizmi.glb',
    title: 'Әл-Хорезми',
    subtitle: 'Әл-джабр кітабын жазу үстінде',
  ),
  'farabi-marker-1': ArMarkerAsset(
    imagePath: 'assets/journal/png/6.png',
    modelPath: 'assets/journal/models/solarsystem.glb',
    title: 'Күн жүйесі',
    subtitle: 'Әл-Фарабидің аспан денелері туралы трактаты',
  ),
  'abai-marker-1': ArMarkerAsset(
    imagePath: 'assets/journal/png/8.png',
    modelPath: 'assets/journal/models/abai.glb',
    title: 'Абай Құнанбайұлы',
    subtitle: 'Қазақ ағартушысы · XIX ғ.',
  ),
  'shoqan-marker-1': ArMarkerAsset(
    imagePath: 'assets/journal/png/10.png',
    modelPath: 'assets/journal/models/shoqan.glb',
    title: 'Шоқан Уәлиханов',
    subtitle: 'Географ, саяхатшы · XIX ғ.',
  ),
};

/// Models are optional. Probe the bundle at runtime — falls back to PNG
/// billboard if the GLB file is not actually present.
Future<bool> hasBundledModel(String? path) async {
  if (path == null) return false;
  try {
    await rootBundle.load(path);
    return true;
  } catch (_) {
    return false;
  }
}
