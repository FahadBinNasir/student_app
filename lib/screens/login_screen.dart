import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _enrollmentController = TextEditingController(text: "02-131232-105");
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  String? _errorMessage;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    final success = await _authService.authenticateStudent(
      _enrollmentController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(authService: _authService),
          ),
        );
      } else {
        setState(
          () => _errorMessage =
              "Invalid credentials or portal connection failed.",
        );
      }
    }
  }

  @override
  void dispose() {
    _enrollmentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 80,
                        color: AppTheme.accentGold,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "BUKC STUDENT PORTAL",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        "LMS & CMS Synchronization Engine",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: TextFormField(
                    controller: _enrollmentController,
                    decoration: InputDecoration(
                      labelText: "Enrollment ID",
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppTheme.accentBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter enrollment number"
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInLeft(
                  delay: const Duration(milliseconds: 400),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Portal Password",
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppTheme.accentBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter account password"
                        : null,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: ListenableBuilder(
                    listenable: _authService,
                    builder: (context, _) {
                      return ElevatedButton(
                        onPressed: _authService.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _authService.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "SIGN IN SECURELY",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
