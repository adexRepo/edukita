import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edukita/core/database/database_provider.dart';

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
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return Scaffold(
        backgroundColor: AppColors.surfaceSoft,
        body: Column(
          children: [
            buildTitleBar(-1, context),
            const Expanded(
              child: Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 120 || constraints.maxHeight < 80) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              buildTitleBar(-1, context),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: 440,
                      child: Container(
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
                                    color: AppColors.primary.withValues(
                                      alpha: 0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset(
                                    'assets/images/logo.webp',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Center(
                                      child: Text(
                                        'E',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryDark,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Edukita',
                                      textAlign: TextAlign.center,
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
                            Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Ilmu yang Tertata, Generasi Bermakna',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    height: 1.5,
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _usernameController,
                              focusNode: _usernameFocusNode,
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) =>
                                  _passwordFocusNode.requestFocus(),
                              decoration: InputDecoration(
                                labelText: context.l10n.username,
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_loading) _login();
                              },
                              decoration: InputDecoration(
                                labelText: context.l10n.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 18),
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.32,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.errorDark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            SizedBox(
                              height: 44,
                              child: FilledButton(
                                onPressed: _loading ? null : _login,
                                child: _loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white,
                                        ),
                                      )
                                    : Text(
                                        context.l10n.login,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
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
          );
        },
      ),
    );
  }
}
