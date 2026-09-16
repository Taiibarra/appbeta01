class Goal {
  final String id;
  String title;
  String description;
  DateTime? targetDate;
  double progress; // 0.0 - 1.0, ignored when targetAmount is set
  bool done;
  final DateTime createdAt;

  /// When set, this goal is a savings goal: its progress is computed
  /// automatically from money logged under the "Ahorro" finance
  /// category instead of being dragged by hand.
  double? targetAmount;

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.targetDate,
    this.progress = 0.0,
    this.done = false,
    required this.createdAt,
    this.targetAmount,
  });

  bool get isFinancial => targetAmount != null && targetAmount! > 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetDate': targetDate?.toIso8601String(),
        'progress': progress,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
        'targetAmount': targetAmount,
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
        targetAmount: json['targetAmount'] != null
            ? (json['targetAmount'] as num).toDouble()
            : null,
      );
}
