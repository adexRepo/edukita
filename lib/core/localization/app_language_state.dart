import 'dart:ui';

class AppLanguageState {
  const AppLanguageState({required this.locale, this.isLoading = false});

  final Locale locale;
  final bool isLoading;

  AppLanguageState copyWith({Locale? locale, bool? isLoading}) {
    return AppLanguageState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
