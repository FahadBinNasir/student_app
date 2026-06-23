class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String marks;
  final String deadlineRaw; // e.g., "10 May 2026 - 01:55 pm"
  final bool isSubmitted;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.marks,
    required this.deadlineRaw,
    required this.isSubmitted,
  });

  // Helper method to assess due urgency status for color coding
  String get statusBucket {
    if (isSubmitted) return 'submitted'; // UI: Green

    if (deadlineRaw.toLowerCase().contains('overdue')) {
      return 'overdue'; // UI: Red
    }

    return 'due_soon'; // UI: Orange
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      marks: json['marks'] as String,
      deadlineRaw: json['deadlineRaw'] as String,
      isSubmitted: json['isSubmitted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'marks': marks,
      'deadlineRaw': deadlineRaw,
      'isSubmitted': isSubmitted,
    };
  }
}
