class Task {
  final int id;
  final String title;
  final String status;

  Task({required this.id, required this.title, required this.status});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      status: json['status'],
    );
  }
}
