import 'dart:async';

import 'package:edukita/features/users/data/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/form_validation.dart';

typedef UserFormSubmit = FutureOr<void> Function(User user);

class UserFormCard extends StatefulWidget {
  const UserFormCard({
    super.key,
    required this.onSubmit,
    this.initialUser,
    this.isEditing = false,
  });

  final User? initialUser;
  final bool isEditing;
  final UserFormSubmit onSubmit;

  @override
  State<UserFormCard> createState() => _UserFormCardState();
}

class _UserFormCardState extends State<UserFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nickNameController;
  late final TextEditingController _fullNameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.initialUser?.username ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.initialUser?.password ?? '',
    );
    _nickNameController = TextEditingController(
      text: widget.initialUser?.nickName ?? '',
    );
    _fullNameController = TextEditingController(
      text: widget.initialUser?.fullName ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nickNameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = widget.initialUser != null
        ? widget.initialUser!.copyWith(
            nickName: _nickNameController.text.trim(),
            fullName: _fullNameController.text.trim(),
          )
        : User(
            username: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
            nickName: _nickNameController.text.trim(),
            fullName: _fullNameController.text.trim(),
          );

    final action = widget.isEditing
        ? SubmissionAction.update
        : SubmissionAction.create;

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSubmit(user);
      AppToast.showSubmissionSuccess(action: action, subject: 'user');
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'user');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    enabled: !isEditing,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      return AppFormValidation.requiredText(
                        value,
                        'Username',
                        minLength: 3,
                        maxLength: 32,
                      );
                    },
                    inputFormatters: [LengthLimitingTextInputFormatter(32)],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !isEditing,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if (!isEditing &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Password is required';
                      }
                      if ((value?.isNotEmpty ?? false) &&
                          value!.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      if ((value?.length ?? 0) > 64) {
                        return 'Password must be at most 64 characters';
                      }
                      return null;
                    },
                    inputFormatters: [LengthLimitingTextInputFormatter(64)],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nickNameController,
                    decoration: const InputDecoration(labelText: 'Nickname'),
                    validator: (value) => AppFormValidation.requiredText(
                      value,
                      'Nickname',
                      minLength: 2,
                      maxLength: 40,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(40)],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) => AppFormValidation.requiredText(
                      value,
                      'Full name',
                      minLength: 3,
                      maxLength: 80,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(80)],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isEditing ? 'Update User' : 'Create User'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
