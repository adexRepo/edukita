import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _loading = false;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreCachedSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _usernameFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _restoreCachedSession() async {
    try {
      final session = await AuthSessionCache.instance.read();
      if (session == null) {
        if (mounted) setState(() => _checkingSession = false);
        return;
      }

      final user = await DatabaseProvider.instance.getUserById(session.userId);
      if (!mounted) return;
      if (user != null) {
        clearAppMemoryCaches();
        await AuthSessionCache.instance.save(
          userId: user['id']?.toString() ?? '',
          username: user['username']?.toString() ?? '',
          role: user['role']?.toString() ?? 'user',
          fullName: user['full_name']?.toString(),
          nickName: user['nick_name']?.toString(),
          teacherId: user['teacher_id']?.toString(),
          mustChangePassword:
              (user['must_change_password'] as num?)?.toInt() != 0,
        );
        if (!mounted) return;
        if ((user['must_change_password'] as num?)?.toInt() != 0) {
          if (mounted) context.go('/change-password');
        } else {
          widget.onAuthenticated();
        }
        return;
      }

      await AuthSessionCache.instance.clear();
    } catch (_) {
      await AuthSessionCache.instance.clear();
    } finally {
      if (mounted) setState(() => _checkingSession = false);
    }
  }

  Future<void> _login() async {
    if (_loading || _checkingSession || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final user = await DatabaseProvider.instance.getUserByUsernameAndPassword(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      if (user != null) {
        clearAppMemoryCaches();
        await AuthSessionCache.instance.save(
          userId: user['id']?.toString() ?? '',
          username: user['username']?.toString() ?? '',
          role: user['role']?.toString() ?? 'user',
          fullName: user['full_name']?.toString(),
          nickName: user['nick_name']?.toString(),
          teacherId: user['teacher_id']?.toString(),
          mustChangePassword:
              (user['must_change_password'] as num?)?.toInt() != 0,
        );
        if (!mounted) return;
        if ((user['must_change_password'] as num?)?.toInt() != 0) {
          if (mounted) context.go('/change-password');
        } else {
          widget.onAuthenticated();
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = context.l10n.invalidUsernameOrPassword;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = context.l10n.loginFailedTryAgain;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surfaceSoft,
    body: Column(
      children: [
        buildTitleBar(-1, context),
        Expanded(
          child: _checkingSession
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Container(
                      width: 480,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadii.panel),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 72,
                                  child: Image.asset(
                                    'assets/images/logo.webp',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Center(
                                      child: Text(
                                        'E',
                                        style: AppTypography.sectionTitleStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Edukita',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                      const SizedBox(height: AppSpacing.xxs),
                                      Text(
                                        context.l10n.foundationEducationSystem,
                                        style: AppTypography.bodyStrongStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              context.l10n.brandTagline,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyStyle,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _usernameController,
                              focusNode: _usernameFocusNode,
                              autofocus: true,
                              enabled: !_loading,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  _passwordFocusNode.requestFocus(),
                              decoration: InputDecoration(
                                labelText: context.l10n.username,
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? context.l10n.fieldRequiredMessage(
                                      context.l10n.username,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              enabled: !_loading,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              decoration: InputDecoration(
                                labelText: context.l10n.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? context.l10n.fieldRequiredMessage(
                                      context.l10n.password,
                                    )
                                  : null,
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.md,
                                ),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTypography.bodyStrongStyle
                                        .copyWith(color: AppColors.errorDark),
                                  ),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.lg),
                            FilledButton(
                              onPressed: _loading ? null : _login,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs,
                                ),
                                child: _loading
                                    ? const SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(context.l10n.login),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );
}
