class Attendance {
  final String courseName;
  final int totalClasses;
  final int presentClasses;
  final double percentage;

  Attendance({
    required this.courseName,
    required this.totalClasses,
    required this.presentClasses,
    required this.percentage,
  });

  bool get isLowAttendance => percentage < 75.0; // Highlight threshold rule

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      courseName: json['courseName'] as String,
      totalClasses: json['totalClasses'] as int,
      presentClasses: json['presentClasses'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseName': courseName,
      'totalClasses': totalClasses,
      'presentClasses': presentClasses,
      'percentage': percentage,
    };
  }
}
