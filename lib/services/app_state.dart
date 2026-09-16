import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/goal.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import 'storage_service.dart';

const _uuid = Uuid();

String dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Habit> habits = [];
  List<JournalEntry> journalEntries = [];
  List<Goal> goals = [];
  bool loaded = false;

  Future<void> load() async {
    habits = await _storage.loadHabits();
    journalEntries = await _storage.loadJournalEntries();
    goals = await _storage.loadGoals();
    loaded = true;
    notifyListeners();
  }

  // Habits
  Future<void> addHabit(String name, String emoji) async {
    habits.add(Habit(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      createdAt: DateTime.now(),
    ));
    await _storage.saveHabits(habits);
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    habits.removeWhere((h) => h.id == id);
    await _storage.saveHabits(habits);
    notifyListeners();
  }

  Future<void> toggleHabitToday(String id) async {
    final habit = habits.firstWhere((h) => h.id == id);
    habit.toggleDate(dateKey(DateTime.now()));
    await _storage.saveHabits(habits);
    notifyListeners();
  }

  int get todayCompletedCount => habits
      .where((h) => h.isCompletedOn(dateKey(DateTime.now())))
      .length;

  // Journal
  Future<void> addJournalEntry(Mood mood, String note) async {
    journalEntries.insert(
      0,
      JournalEntry(
        id: _uuid.v4(),
        date: DateTime.now(),
        mood: mood,
        note: note,
      ),
    );
    await _storage.saveJournalEntries(journalEntries);
    notifyListeners();
  }

  Future<void> deleteJournalEntry(String id) async {
    journalEntries.removeWhere((e) => e.id == id);
    await _storage.saveJournalEntries(journalEntries);
    notifyListeners();
  }

  bool get hasEntryToday => journalEntries.any(
        (e) => dateKey(e.date) == dateKey(DateTime.now()),
      );

  // Goals
  Future<void> addGoal(String title, String description, DateTime? targetDate) async {
    goals.add(Goal(
      id: _uuid.v4(),
      title: title,
      description: description,
      targetDate: targetDate,
      createdAt: DateTime.now(),
    ));
    await _storage.saveGoals(goals);
    notifyListeners();
  }

  Future<void> updateGoalProgress(String id, double progress) async {
    final goal = goals.firstWhere((g) => g.id == id);
    goal.progress = progress.clamp(0.0, 1.0);
    goal.done = goal.progress >= 1.0;
    await _storage.saveGoals(goals);
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    goals.removeWhere((g) => g.id == id);
    await _storage.saveGoals(goals);
    notifyListeners();
  }

  int get activeGoalsCount => goals.where((g) => !g.done).length;
}
