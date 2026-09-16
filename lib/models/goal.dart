class Goal {
  final String id;
  String title;
  String description;
  DateTime? targetDate;
  double progress; // 0.0 - 1.0
  bool done;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.targetDate,
    this.progress = 0.0,
    this.done = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetDate': targetDate?.toIso8601String(),
        'progress': progress,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        targetDate: json['targetDate'] != null
            ? DateTime.parse(json['targetDate'] as String)
            : null,
        progress: (json['progress'] as num).toDouble(),
        done: json['done'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
