import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'app.textScale';

class TextScaleOption {
  final String id;
  final String label;
  final double scale;
  const TextScaleOption({required this.id, required this.label, required this.scale});
}

const textScaleOptions = <TextScaleOption>[
  TextScaleOption(id: 'small', label: 'S', scale: 0.88),
  TextScaleOption(id: 'medium', label: 'M', scale: 1.0),
  TextScaleOption(id: 'large', label: 'L', scale: 1.14),
  TextScaleOption(id: 'xlarge', label: 'XL', scale: 1.3),
];

TextScaleOption _byId(String id) =>
    textScaleOptions.firstWhere((o) => o.id == id, orElse: () => textScaleOptions[1]);

class TextScaleController extends Notifier<TextScaleOption> {
  @override
  TextScaleOption build() {
    _load();
    return textScaleOptions[1];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) state = _byId(saved);
  }

  Future<void> set(TextScaleOption opt) async {
    state = opt;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, opt.id);
  }
}

final textScaleProvider =
    NotifierProvider<TextScaleController, TextScaleOption>(TextScaleController.new);
