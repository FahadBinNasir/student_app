class Course {
  final String id;
  final String name;

  Course({required this.id, required this.name});

  // Factory constructor to handle potential JSON structures from local caching
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
