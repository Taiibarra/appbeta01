import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/transaction.dart';

class StorageService {
  static const _habitsKey = 'habits';
  static const _journalKey = 'journal_entries';
  static const _goalsKey = 'goals';
  static const _transactionsKey = 'transactions';
  static const _budgetsKey = 'budgets';

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_habitsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Habit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(habits.map((h) => h.toJson()).toList());
    await prefs.setString(_habitsKey, raw);
  }

  Future<List<JournalEntry>> loadJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_journalKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_journalKey, raw);
  }

  Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(goals.map((g) => g.toJson()).toList());
    await prefs.setString(_goalsKey, raw);
  }

  Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_transactionsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_transactionsKey, raw);
  }

  Future<List<Budget>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_budgetsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Budget.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(budgets.map((b) => b.toJson()).toList());
    await prefs.setString(_budgetsKey, raw);
  }
}
