import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'app.font';

class AppFont {
  final String id;
  final String label;
  final String? family;

  const AppFont({required this.id, required this.label, this.family});
}

const availableFonts = <AppFont>[
  AppFont(id: 'default', label: 'Жүйелік / System'),
  AppFont(id: 'aronsiki', label: 'Aronsiki', family: 'Aronsiki'),
  AppFont(id: 'handone', label: 'Handone', family: 'Handone'),
  AppFont(id: 'leotaro', label: 'Leotaro', family: 'Leotaro'),
  AppFont(id: 'rowvaticano', label: 'RowVaticano', family: 'RowVaticano'),
  AppFont(id: 'thankslab', label: 'Thanks Lab', family: 'ThanksLab'),
];

AppFont _findById(String id) =>
    availableFonts.firstWhere((f) => f.id == id, orElse: () => availableFonts.first);

class FontController extends Notifier<AppFont> {
  @override
  AppFont build() {
    _load();
    return availableFonts.first;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      state = _findById(saved);
    }
  }

  Future<void> set(AppFont font) async {
    state = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, font.id);
  }
}

final fontProvider = NotifierProvider<FontController, AppFont>(FontController.new);
