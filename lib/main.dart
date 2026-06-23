import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Note: Firebase.initializeApp() would go here once your google-services.json is in place
  runApp(const StudentMinApp());
}

class StudentMinApp extends StatelessWidget {
  const StudentMinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BUKC Student Engine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
