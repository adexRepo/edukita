import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class LocaleStorage {
  LocaleStorage({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _localeKey = 'edukita.locale';

  final SharedPreferences? _preferences;

  Future<Locale?> getSavedLocale() async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_localeKey);
    if (languageCode == null || languageCode.trim().isEmpty) return null;
    return Locale(languageCode);
  }

  Future<void> saveLocale(Locale locale) async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    await preferences.setString(_localeKey, locale.languageCode);
  }
}
