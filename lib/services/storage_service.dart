import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget.dart';
import '../models/fixed_money_item.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/transaction.dart';

class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;
  const ReminderSettings({required this.enabled, required this.hour, required this.minute});
}

class StorageService {
  static const _habitsKey = 'habits';
  static const _journalKey = 'journal_entries';
  static const _goalsKey = 'goals';
  static const _transactionsKey = 'transactions';
  static const _budgetsKey = 'budgets';
  static const _userNameKey = 'user_name';
  static const _fixedIncomesKey = 'fixed_incomes';
  static const _fixedExpensesKey = 'fixed_expenses';
  static const _reminderEnabledKey = 'reminder_enabled';
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinuteKey = 'reminder_minute';
  static const _lastReminderShownOnKey = 'last_reminder_shown_on';

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

  Future<String?> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<List<FixedMoneyItem>> loadFixedIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_fixedIncomesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => FixedMoneyItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFixedIncomes(List<FixedMoneyItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_fixedIncomesKey, raw);
  }

  Future<List<FixedMoneyItem>> loadFixedExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_fixedExpensesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => FixedMoneyItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFixedExpenses(List<FixedMoneyItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_fixedExpensesKey, raw);
  }

  Future<ReminderSettings> loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return ReminderSettings(
      enabled: prefs.getBool(_reminderEnabledKey) ?? false,
      hour: prefs.getInt(_reminderHourKey) ?? 20,
      minute: prefs.getInt(_reminderMinuteKey) ?? 0,
    );
  }

  Future<void> saveReminderSettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinuteKey, minute);
  }

  Future<String?> loadLastReminderShownOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastReminderShownOnKey);
  }

  Future<void> saveLastReminderShownOn(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReminderShownOnKey, dateKey);
  }
}
