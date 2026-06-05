import 'dart:ui';

import 'package:edukita/core/localization/app_language_state.dart';
import 'package:edukita/core/localization/locale_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLanguageCubit extends Cubit<AppLanguageState> {
  AppLanguageCubit(this._storage)
    : super(const AppLanguageState(locale: Locale('en'), isLoading: true));

  static const supportedLocales = <Locale>[Locale('en'), Locale('id')];

  final LocaleStorage _storage;

  Future<void> loadSavedLanguage() async {
    emit(state.copyWith(isLoading: true));
    final savedLocale = await _storage.getSavedLocale();
    final locale = _supportedOrDefault(savedLocale ?? _systemLocale());
    emit(AppLanguageState(locale: locale));
  }

  Future<void> changeLanguage(Locale locale) async {
    final nextLocale = _supportedOrDefault(locale);
    await _storage.saveLocale(nextLocale);
    emit(AppLanguageState(locale: nextLocale));
  }

  Locale _systemLocale() {
    return PlatformDispatcher.instance.locale;
  }

  Locale _supportedOrDefault(Locale locale) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    return const Locale('en');
  }
}
