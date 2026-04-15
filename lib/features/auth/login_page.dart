import 'package:edukita/features/common/title_bar.dart';
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
  String? _errorMessage;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        widget.onAuthenticated();
      } else {
        setState(() {
          _errorMessage = 'Invalid username or password.';
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          buildTitleBar(-1, context),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                'Edukita',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontSize: 32, // perfect for maxWidth 420
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      color: const Color(0xFF1F2937),
                                    ),
                              ),
                            ),
                            Divider(height: 13, thickness: 3),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                "Ilmu yang Tertata, Generasi Bermakna",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.3,
                                      height: 1.5, // spacing antar baris
                                      color: const Color(0xFF6B7280),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
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
                                    color: Theme.of(context).colorScheme.error,
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
                                  : const Text('Login'),
                            ),
                          ],
                        ),
                      ),
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
}
