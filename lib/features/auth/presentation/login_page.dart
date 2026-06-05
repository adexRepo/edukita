import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
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
        await AuthSessionCache.instance.save(
          userId: user['id']?.toString() ?? '',
          username: user['username']?.toString() ?? '',
          role: user['role']?.toString() ?? 'user',
          fullName: user['full_name']?.toString(),
          nickName: user['nick_name']?.toString(),
          teacherId: user['teacher_id']?.toString(),
        );
        widget.onAuthenticated();
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
        await AuthSessionCache.instance.save(
          userId: user['id']?.toString() ?? '',
          username: user['username']?.toString() ?? '',
          role: user['role']?.toString() ?? 'user',
          fullName: user['full_name']?.toString(),
          nickName: user['nick_name']?.toString(),
          teacherId: user['teacher_id']?.toString(),
        );
        widget.onAuthenticated();
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Invalid username or password.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
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
        backgroundColor: AppColors.surface,
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
      backgroundColor: AppColors.surface,
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
                      width: 420,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/logo.webp',
                                    height: 128,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Text(
                                      'Edukita',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    'Edukita',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                ],
                              ),
                              const Divider(height: 13, thickness: 3),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  "Ilmu yang Tertata, Generasi Bermakna",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize: AppTypography.bodyLarge,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.3,
                                        height: 1.5,
                                        color: AppColors.textSecondary,
                                      ),
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
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  if (!_loading) _login();
                                },
                                decoration: InputDecoration(
                                  labelText: context.l10n.password,
                                  border: const OutlineInputBorder(),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 24),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              FilledButton(
                                onPressed: _loading ? null : _login,
                                child: _loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(context.l10n.login),
                              ),
                            ],
                          ),
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
