import 'dart:async';

import 'package:edukita/core/localization/app_language_cubit.dart';
import 'package:edukita/core/localization/app_language_state.dart';
import 'package:edukita/core/localization/locale_storage.dart';
import 'package:edukita/core/router/app_router.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 120;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 24 << 20;
  await dotenv.load(fileName: ".env");
  await windowManager.ensureInitialized();

  const initialSize = Size(800, 600);
  const windowOptions = WindowOptions(
    size: initialSize,
    minimumSize: initialSize,
    center: true,
    title: "Edukita",
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    skipTaskbar: false,
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    }),
  );

  runApp(const EdukitaApp());
}

class EdukitaApp extends StatefulWidget {
  const EdukitaApp({super.key});

  @override
  State<EdukitaApp> createState() => _EdukitaAppState();
}

class _EdukitaAppState extends State<EdukitaApp> {
  @override
  void initState() {
    super.initState();
    setupLocator();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppLanguageCubit(LocaleStorage())..loadSavedLanguage(),
      child: BlocBuilder<AppLanguageCubit, AppLanguageState>(
        builder: (context, languageState) {
          return MaterialApp.router(
            scrollBehavior: ScrollBehavior(),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            locale: languageState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: appRouter,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(AppTypography.appTextScale),
                ),
                child: AppToastHost(child: child ?? const SizedBox.shrink()),
              );
            },
          );
        },
      ),
    );
  }
}
