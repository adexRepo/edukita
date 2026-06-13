import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, this.forced = false});

  final bool forced;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final passwordChangedMessage = context.l10n.passwordChangedLoginAgain;
    final currentPasswordIncorrectMessage =
        context.l10n.currentPasswordIncorrect;
    final session = await AuthSessionCache.instance.read();
    if (session == null) {
      if (mounted) context.go('/login');
      return;
    }
    setState(() => _saving = true);
    try {
      await DatabaseProvider.instance.changePassword(
        userId: session.userId,
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      await AuthSessionCache.instance.clear();
      AppToast.showSuccess(passwordChangedMessage);
      if (mounted) context.go('/login');
    } catch (error) {
      final message = error.toString().contains('Current password is incorrect')
          ? currentPasswordIncorrectMessage
          : error.toString().replaceFirst('Bad state: ', '');
      AppToast.showFailed(message);
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          buildTitleBar(-1, context),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: 460,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.forced
                              ? context.l10n.createNewPassword
                              : context.l10n.changePassword,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.forced
                              ? context.l10n.temporaryPasswordMustBeReplaced
                              : context.l10n.strongPasswordDescription,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        _passwordField(
                          _currentController,
                          context.l10n.currentPassword,
                        ),
                        const SizedBox(height: 12),
                        _passwordField(
                          _newController,
                          context.l10n.newPassword,
                          validateNew: true,
                        ),
                        const SizedBox(height: 12),
                        _passwordField(
                          _confirmController,
                          context.l10n.confirmNewPassword,
                          confirm: true,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.lock_reset_outlined),
                          label: Text(
                            _saving
                                ? '${context.l10n.saving}...'
                                : context.l10n.changePassword,
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

  Widget _passwordField(
    TextEditingController controller,
    String label, {
    bool validateNew = false,
    bool confirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final text = value ?? '';
        if (text.isEmpty) return context.l10n.fieldRequiredMessage(label);
        if (validateNew && text.length < 8) {
          return context.l10n.passwordMinimumEight;
        }
        if (validateNew && text == _currentController.text) {
          return context.l10n.newPasswordMustDiffer;
        }
        if (confirm && text != _newController.text) {
          return context.l10n.passwordsDoNotMatch;
        }
        return null;
      },
    );
  }
}
