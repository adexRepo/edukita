import 'dart:async';

import 'package:edukita/core/localization/app_language_cubit.dart';
import 'package:edukita/core/localization/app_language_state.dart';
import 'package:edukita/core/localization/locale_storage.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/router/app_router.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/common/title_bar.dart';
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
  late Future<void> _startupFuture;
  bool _locatorReady = false;

  @override
  void initState() {
    super.initState();
    _startupFuture = _initialize();
  }

  Future<void> _initialize() async {
    if (!_locatorReady) {
      await setupLocator();
      _locatorReady = true;
    }
    await DatabaseProvider.instance.database;
  }

  void _retryStartup() {
    setState(() => _startupFuture = _initialize());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppLanguageCubit(LocaleStorage())..loadSavedLanguage(),
      child: BlocBuilder<AppLanguageCubit, AppLanguageState>(
        builder: (context, languageState) {
          return FutureBuilder<void>(
            future: _startupFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.hasError) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.theme,
                  locale: languageState.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  home: _StartupPage(
                    error: snapshot.error,
                    onRetry: _retryStartup,
                  ),
                );
              }
              return MaterialApp.router(
                scrollBehavior: const ScrollBehavior(),
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
          );
        },
      ),
    );
  }
}

class _StartupPage extends StatelessWidget {
  const _StartupPage({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          buildTitleBar(-1, context),
          Expanded(
            child: Center(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: AppColors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Edukita',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      error == null
                          ? context.l10n.startupPreparingWorkspace
                          : context.l10n.startupFailed,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (error == null)
                      const SizedBox(
                        width: 180,
                        child: LinearProgressIndicator(minHeight: 3),
                      )
                    else
                      FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_outlined),
                        label: Text(context.l10n.retry),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
