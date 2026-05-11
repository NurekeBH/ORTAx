import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'app.locale';
const supportedLocales = [Locale('kk'), Locale('ru'), Locale('en')];
const defaultLocale = Locale('kk');

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    _load();
    return defaultLocale;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && supportedLocales.any((l) => l.languageCode == saved)) {
      state = Locale(saved);
    }
  }

  Future<void> set(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
