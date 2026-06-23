import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  final AuthService authService;

  // Explicit tracking array for Spring-2026 courses
  final List<String> _courses = [
    "SOFTWARE QUALITY ENGINEERING",
    "HUMAN COMPUTER INTERACTION",
    "CLOUD COMPUTING",
    "TECHNICAL WRITING & PRESENTATION SKILLS",
    "CLOUD COMPUTING LAB",
    "SOFTWARE APPLICATIONS FOR MOBILE DEVICES",
    "SOFTWARE APPLICATIONS FOR MOBILE DEVICES LAB",
    "AGILE DEVELOPMENT",
    "Understanding Quran V",
  ];

  DashboardScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "DASHBOARD",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Card(
                  color: AppTheme.cardDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.accentBlue.withValues(
                            alpha: 0.2,
                          ),
                          child: const Icon(
                            Icons.school,
                            color: AppTheme.accentGold,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authService.studentName ?? "FAHAD BIN NASIR",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authService.enrollmentNumber ?? "02-131232-105",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "Enrolled Courses (Spring-2026)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _courses.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return FadeInLeft(
                      delay: Duration(milliseconds: index * 60),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.book_outlined,
                              color: AppTheme.accentBlue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            _courses[index],
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w646,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
