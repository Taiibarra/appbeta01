class Habit {
  final String id;
  String name;
  String emoji;
  final DateTime createdAt;
  Set<String> completedDates; // "yyyy-MM-dd"

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.createdAt,
    Set<String>? completedDates,
  }) : completedDates = completedDates ?? {};

  bool isCompletedOn(String dateKey) => completedDates.contains(dateKey);

  void toggleDate(String dateKey) {
    if (completedDates.contains(dateKey)) {
      completedDates.remove(dateKey);
    } else {
      completedDates.add(dateKey);
    }
  }

  int get currentStreak {
    var streak = 0;
    var day = DateTime.now();
    while (true) {
      final key = _dateKey(day);
      if (completedDates.contains(key)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    if (completedDates.isEmpty) return 0;
    final dates = completedDates.map(DateTime.parse).toList()..sort();
    var longest = 1;
    var current = 1;
    for (var i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        longest = current > longest ? current : longest;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
        'completedDates': completedDates.toList(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedDates: Set<String>.from(json['completedDates'] as List),
      );
}
