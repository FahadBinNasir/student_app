import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../models/assignment.dart';
import '../theme/app_theme.dart';

class AssignmentsScreen extends StatefulWidget {
  final AuthService authService;
  const AssignmentsScreen({super.key, required this.authService});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  bool _isFetching = false;
  List<Assignment> _allAssignments = [];

  // Hardcoded tracking keys representing internal LMS identifier strings for Spring-2026 courses
  final List<Map<String, String>> _courseRegistry = [
    {'id': '101', 'name': 'SOFTWARE QUALITY ENGINEERING'},
    {'id': '102', 'name': 'HUMAN COMPUTER INTERACTION'},
    {'id': '103', 'name': 'CLOUD COMPUTING'},
    {'id': '104', 'name': 'TECHNICAL WRITING & PRESENTATION SKILLS'},
    {'id': '105', 'name': 'CLOUD COMPUTING LAB'},
    {'id': '106', 'name': 'SOFTWARE APPLICATIONS FOR MOBILE DEVICES'},
    {'id': '107', 'name': 'SOFTWARE APPLICATIONS FOR MOBILE DEVICES LAB'},
    {'id': '108', 'name': 'AGILE DEVELOPMENT'},
    {'id': '109', 'name': 'Understanding Quran V'},
  ];

  @override
  void initState() {
    super.initState();
    _syncLmsData();
  }

  Future<void> _syncLmsData() async {
    setState(() => _isFetching = true);
    List<Assignment> temporaryContainer = [];

    try {
      // Sequentially query each active courses stream matrix over LMS
      for (var course in _courseRegistry) {
        final scrapedList = await widget.authService.lms.fetchAssignments(
          course['id']!,
        );
        temporaryContainer.addAll(scrapedList);
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _allAssignments = temporaryContainer;
        _isFetching = false;
      });
    }
  }

  Color _getStatusColor(String state) {
    switch (state) {
      case 'submitted':
        return const Color(0xFF10B981); // Green
      case 'overdue':
        return const Color(0xFFEF4444); // Red
      default:
        return AppTheme.accentGold; // Orange / Pending Soon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "ASSIGNMENTS",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: _isFetching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isFetching ? null : _syncLmsData,
          ),
        ],
      ),
      body: SafeArea(
        child: _allAssignments.isEmpty && !_isFetching
            ? Center(
                child: Text(
                  "No current assignments parsed or session timed out.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _allAssignments.length,
                itemBuilder: (context, index) {
                  final assignment = _allAssignments[index];
                  final statusColor = _getStatusColor(assignment.statusBucket);

                  // Locate the friendly presentation name string matching core assignment items
                  final courseMeta = _courseRegistry.firstWhere(
                    (element) => element['id'] == assignment.courseId,
                    orElse: () => {'name': 'Unknown Course'},
                  );

                  return FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border(
                          left: BorderSide(color: statusColor, width: 5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    courseMeta['name']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentBlue,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    assignment.isSubmitted
                                        ? "SUBMITTED"
                                        : "PENDING",
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              assignment.title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  assignment.deadlineRaw,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "Marks: ${assignment.marks}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentGold,
                                  ),
                                ),
                              ],
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
