import 'mood.dart';

class JournalEntry {
  final String id;
  final DateTime date;
  Mood mood;
  String note;

  JournalEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mood': mood.name,
        'note': note,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mood: Mood.values.byName(json['mood'] as String),
        note: json['note'] as String,
      );
}
