import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration screen ready. Connect your backend register API next.'),
      ),
    );

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7F3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.person_add_alt_1, size: 42),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Register to start tracking routes, prices, and alerts.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirm Password'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please confirm password';
                        }
                        if (value != passwordController.text.trim()) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading ? null : handleRegister,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Register'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}