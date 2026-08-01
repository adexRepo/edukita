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
import 'package:shadcn_ui/shadcn_ui.dart';
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
              return ShadApp.custom(
                appBuilder: (context) {
                  return MaterialApp.router(
                    scrollBehavior: const ScrollBehavior(),
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.theme,
                    locale: languageState.locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    routerConfig: appRouter,
                    builder: (context, child) {
                      final mediaQuery = MediaQuery.of(context);
                      return ShadAppBuilder(
                        child: MediaQuery(
                          data: mediaQuery.copyWith(
                            textScaler:
                                TextScaler.linear(AppTypography.appTextScale),
                          ),
                          child: AppToastHost(
                            child: child ?? const SizedBox.shrink(),
                          ),
                        ),
                      );
                    },
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
    final hasError = error != null;
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          buildTitleBar(-1, context),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: 440,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/images/logo.webp',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.school_outlined,
                                color: AppColors.primaryDark,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edukita',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Foundation Education System',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(height: 1, color: AppColors.border),
                      const SizedBox(height: 18),
                      Text(
                        hasError
                            ? context.l10n.startupFailed
                            : context.l10n.startupPreparingWorkspace,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: hasError
                              ? AppColors.errorDark
                              : AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!hasError)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: AppColors.surfaceMuted,
                            color: AppColors.primary,
                          ),
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.32),
                            ),
                          ),
                          child: Text(
                            error.toString().replaceFirst('Exception: ', ''),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.errorDark,
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 42,
                          child: FilledButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh_outlined),
                            label: Text(context.l10n.retry),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
