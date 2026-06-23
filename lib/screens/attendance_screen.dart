import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../models/attendance.dart';
import '../theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  final AuthService authService;
  const AttendanceScreen({super.key, required this.authService});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isSyncing = false;
  List<Attendance> _attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchCmsAttendance();
  }

  Future<void> _fetchCmsAttendance() async {
    setState(() => _isSyncing = true);

    try {
      final records = await widget.authService.cms.fetchAttendance();
      if (mounted) {
        setState(() {
          _attendanceRecords = records;
          _isSyncing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "ATTENDANCE METRICS",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _fetchCmsAttendance,
          ),
        ],
      ),
      body: SafeArea(
        child: _attendanceRecords.isEmpty && !_isSyncing
            ? Center(
                child: Text(
                  "No attendance profiles loaded from CMS.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = _attendanceRecords[index];
                  // If it drops below 75%, trigger red indicator warning, otherwise use standard accent blue
                  final trackColor = record.isLowAttendance
                      ? const Color(0xFFEF4444)
                      : AppTheme.accentBlue;

                  return FadeInLeft(
                    duration: const Duration(milliseconds: 350),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    value: record.percentage / 100.0,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      trackColor,
                                    ),
                                    strokeWidth: 6,
                                  ),
                                ),
                                Text(
                                  "${record.percentage.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: trackColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.courseName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Attended: ${record.presentClasses} / ${record.totalClasses} Lectures",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
