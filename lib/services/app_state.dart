import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/budget.dart';
import '../models/finance_category.dart';
import '../models/fixed_money_item.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../models/transaction.dart';
import 'storage_service.dart';

const _uuid = Uuid();

String dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Habit> habits = [];
  List<JournalEntry> journalEntries = [];
  List<Goal> goals = [];
  List<Transaction> transactions = [];
  List<Budget> budgets = [];
  List<FixedMoneyItem> fixedIncomes = [];
  List<FixedMoneyItem> fixedExpenses = [];
  String? userName;
  bool loaded = false;

  Future<void> load() async {
    habits = await _storage.loadHabits();
    journalEntries = await _storage.loadJournalEntries();
    goals = await _storage.loadGoals();
    transactions = await _storage.loadTransactions();
    budgets = await _storage.loadBudgets();
    fixedIncomes = await _storage.loadFixedIncomes();
    fixedExpenses = await _storage.loadFixedExpenses();
    userName = await _storage.loadUserName();
    loaded = true;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    userName = name.trim();
    await _storage.saveUserName(userName!);
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

  // Finance
  Future<void> addTransaction(
    FinanceCategory category,
    double amount,
    String note,
    DateTime date,
  ) async {
    transactions.insert(
      0,
      Transaction(
        id: _uuid.v4(),
        category: category,
        amount: amount,
        note: note,
        date: date,
      ),
    );
    await _storage.saveTransactions(transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    transactions.removeWhere((t) => t.id == id);
    await _storage.saveTransactions(transactions);
    notifyListeners();
  }

  Future<void> setBudget(FinanceCategory category, double monthlyLimit) async {
    final index = budgets.indexWhere((b) => b.category == category);
    if (index != -1) {
      budgets[index].monthlyLimit = monthlyLimit;
    } else {
      budgets.add(Budget(category: category, monthlyLimit: monthlyLimit));
    }
    await _storage.saveBudgets(budgets);
    notifyListeners();
  }

  Future<void> removeBudget(FinanceCategory category) async {
    budgets.removeWhere((b) => b.category == category);
    await _storage.saveBudgets(budgets);
    notifyListeners();
  }

  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    return transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
  }

  double get totalBalance => transactions.fold(
        0.0,
        (sum, t) => sum + (t.isIncome ? t.amount : -t.amount),
      );

  double get monthIncome => currentMonthTransactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthExpense => currentMonthTransactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthNet => monthIncome - monthExpense;

  Map<FinanceCategory, double> get monthSpendByCategory {
    final map = <FinanceCategory, double>{};
    for (final t in currentMonthTransactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  double spentThisMonthFor(FinanceCategory category) =>
      monthSpendByCategory[category] ?? 0.0;

  DateTime? get lastTransactionDate => transactions.isEmpty
      ? null
      : transactions.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b);

  // Fixed monthly budget (income vs. fixed expenses worksheet)
  Future<void> addFixedIncome(String label, double amount) async {
    fixedIncomes.add(FixedMoneyItem(id: _uuid.v4(), label: label, amount: amount));
    await _storage.saveFixedIncomes(fixedIncomes);
    notifyListeners();
  }

  Future<void> deleteFixedIncome(String id) async {
    fixedIncomes.removeWhere((i) => i.id == id);
    await _storage.saveFixedIncomes(fixedIncomes);
    notifyListeners();
  }

  Future<void> addFixedExpense(String label, double amount) async {
    fixedExpenses.add(FixedMoneyItem(id: _uuid.v4(), label: label, amount: amount));
    await _storage.saveFixedExpenses(fixedExpenses);
    notifyListeners();
  }

  Future<void> deleteFixedExpense(String id) async {
    fixedExpenses.removeWhere((i) => i.id == id);
    await _storage.saveFixedExpenses(fixedExpenses);
    notifyListeners();
  }

  double get totalFixedIncome =>
      fixedIncomes.fold(0.0, (sum, i) => sum + i.amount);

  double get totalFixedExpenses =>
      fixedExpenses.fold(0.0, (sum, i) => sum + i.amount);

  double get fixedNet => totalFixedIncome - totalFixedExpenses;
}
