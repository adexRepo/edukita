import 'package:edukita/features/users/user_model.dart';
import 'package:flutter/material.dart';

typedef UserFormSubmit = void Function(User user);

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

  void _submit() {
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

    widget.onSubmit(user);
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
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    },
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nickNameController,
                    decoration: const InputDecoration(labelText: 'Nickname'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nickname is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _submit,
                        child: Text(isEditing ? 'Update User' : 'Create User'),
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
