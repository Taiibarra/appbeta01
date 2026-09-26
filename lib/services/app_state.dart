import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/budget.dart';
import '../models/business.dart';
import '../models/day_block.dart';
import '../models/finance_category.dart';
import '../models/fixed_money_item.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../models/piggy_bank.dart';
import '../models/transaction.dart';
import 'storage_service.dart';

const _uuid = Uuid();

String dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _monthKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Habit> habits = [];
  List<JournalEntry> journalEntries = [];
  List<Goal> goals = [];
  List<Transaction> transactions = [];
  List<Budget> budgets = [];
  List<FixedMoneyItem> fixedIncomes = [];
  List<FixedMoneyItem> fixedExpenses = [];
  List<SpendCategory> customCategories = [];
  List<PiggyBank> piggyBanks = [];
  List<DayBlock> dayBlocks = [];
  List<Business> businesses = [];
  List<Lead> leads = [];
  List<DateTime> businessActions = [];
  String? userName;
  bool loaded = false;

  bool reminderEnabled = false;
  int reminderHour = 20;
  int reminderMinute = 0;
  String? lastReminderShownOn;

  Future<void> load() async {
    habits = await _storage.loadHabits();
    journalEntries = await _storage.loadJournalEntries();
    goals = await _storage.loadGoals();
    transactions = await _storage.loadTransactions();
    budgets = await _storage.loadBudgets();
    fixedIncomes = await _storage.loadFixedIncomes();
    fixedExpenses = await _storage.loadFixedExpenses();
    customCategories = await _storage.loadCustomCategories();
    piggyBanks = await _storage.loadPiggyBanks();
    dayBlocks = await _storage.loadDayBlocks() ?? defaultDayBlocks();
    businesses = await _storage.loadBusinesses() ?? defaultBusinesses();
    leads = await _storage.loadLeads();
    businessActions = await _storage.loadBusinessActions();
    userName = await _storage.loadUserName();
    final reminder = await _storage.loadReminderSettings();
    reminderEnabled = reminder.enabled;
    reminderHour = reminder.hour;
    reminderMinute = reminder.minute;
    lastReminderShownOn = await _storage.loadLastReminderShownOn();
    await _applyDueFixedItems();
    loaded = true;
    notifyListeners();
  }

  /// Deposits/charges any fixed income or expense that hasn't already
  /// fired this calendar month, as a real transaction — so fixed items
  /// show up in Finanzas immediately and keep recurring automatically
  /// every month without you having to log them by hand.
  Future<void> _applyDueFixedItems() async {
    final currentMonth = _monthKey(DateTime.now());
    var changed = false;

    for (final item in fixedIncomes) {
      if (item.lastAppliedMonth != currentMonth) {
        transactions.insert(
          0,
          Transaction(
            id: _uuid.v4(),
            categoryId: 'otroIngreso',
            isIncome: true,
            amount: item.amount,
            note: item.label,
            date: DateTime.now(),
          ),
        );
        item.lastAppliedMonth = currentMonth;
        changed = true;
      }
    }
    for (final item in fixedExpenses) {
      if (item.lastAppliedMonth != currentMonth) {
        transactions.insert(
          0,
          Transaction(
            id: _uuid.v4(),
            categoryId: 'otroGasto',
            isIncome: false,
            amount: item.amount,
            note: item.label,
            date: DateTime.now(),
          ),
        );
        item.lastAppliedMonth = currentMonth;
        changed = true;
      }
    }

    if (changed) {
      await _storage.saveTransactions(transactions);
      await _storage.saveFixedIncomes(fixedIncomes);
      await _storage.saveFixedExpenses(fixedExpenses);
    }
  }

  Future<void> setReminder({required bool enabled, required int hour, required int minute}) async {
    reminderEnabled = enabled;
    reminderHour = hour;
    reminderMinute = minute;
    await _storage.saveReminderSettings(enabled: enabled, hour: hour, minute: minute);
    notifyListeners();
  }

  Future<void> markReminderShownToday() async {
    lastReminderShownOn = dateKey(DateTime.now());
    await _storage.saveLastReminderShownOn(lastReminderShownOn!);
  }

  /// Whether it's time to nudge the user today: reminders are on, the
  /// clock has passed the chosen time, and it hasn't already fired today.
  bool get shouldShowReminderNow {
    if (!reminderEnabled) return false;
    if (lastReminderShownOn == dateKey(DateTime.now())) return false;
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, reminderHour, reminderMinute);
    return now.isAfter(target);
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
  Future<void> addGoal(
    String title,
    String description,
    DateTime? targetDate, {
    double? targetAmount,
  }) async {
    goals.add(Goal(
      id: _uuid.v4(),
      title: title,
      description: description,
      targetDate: targetDate,
      targetAmount: targetAmount,
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

  int get activeGoalsCount => goals.where((g) => !effectiveDone(g)).length;

  /// Total ever logged under the "Ahorro" category — the pool every
  /// financial goal's progress is measured against.
  double get totalSavedAllTime => transactions
      .where((t) => t.categoryId == 'ahorro')
      .fold(0.0, (sum, t) => sum + t.amount);

  double effectiveProgress(Goal goal) {
    if (!goal.isFinancial) return goal.progress;
    if (goal.targetAmount == null || goal.targetAmount == 0) return 0;
    return (totalSavedAllTime / goal.targetAmount!).clamp(0.0, 1.0);
  }

  bool effectiveDone(Goal goal) =>
      goal.isFinancial ? effectiveProgress(goal) >= 1.0 : goal.done;

  // Finance
  List<SpendCategory> get allCategories => [...builtinCategories, ...customCategories];

  List<SpendCategory> get incomeCategories =>
      allCategories.where((c) => c.isIncome).toList(growable: false);

  List<SpendCategory> get expenseCategories =>
      allCategories.where((c) => !c.isIncome).toList(growable: false);

  SpendCategory categoryById(String id) => allCategories.firstWhere(
        (c) => c.id == id,
        orElse: () => builtinCategories.firstWhere((c) => c.id == 'otroGasto'),
      );

  Future<void> addCustomCategory({
    required String label,
    required String iconKey,
    required Color color,
    required bool isIncome,
    required bool isEssential,
  }) async {
    customCategories.add(SpendCategory(
      id: _uuid.v4(),
      label: label,
      iconKey: iconKey,
      color: color,
      isIncome: isIncome,
      isEssential: isEssential,
      isCustom: true,
    ));
    await _storage.saveCustomCategories(customCategories);
    notifyListeners();
  }

  Future<void> deleteCustomCategory(String id) async {
    customCategories.removeWhere((c) => c.id == id);
    await _storage.saveCustomCategories(customCategories);
    notifyListeners();
  }

  Future<void> addTransaction(
    String categoryId,
    bool isIncome,
    double amount,
    String note,
    DateTime date,
  ) async {
    transactions.insert(
      0,
      Transaction(
        id: _uuid.v4(),
        categoryId: categoryId,
        isIncome: isIncome,
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

  Future<void> setBudget(String categoryId, double monthlyLimit) async {
    final index = budgets.indexWhere((b) => b.categoryId == categoryId);
    if (index != -1) {
      budgets[index].monthlyLimit = monthlyLimit;
    } else {
      budgets.add(Budget(categoryId: categoryId, monthlyLimit: monthlyLimit));
    }
    await _storage.saveBudgets(budgets);
    notifyListeners();
  }

  Future<void> removeBudget(String categoryId) async {
    budgets.removeWhere((b) => b.categoryId == categoryId);
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

  Map<String, double> get monthSpendByCategory {
    final map = <String, double>{};
    for (final t in currentMonthTransactions.where((t) => !t.isIncome)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  double spentThisMonthFor(String categoryId) =>
      monthSpendByCategory[categoryId] ?? 0.0;

  DateTime? get lastTransactionDate => transactions.isEmpty
      ? null
      : transactions.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b);

  /// Monday 00:00 of the current calendar week.
  DateTime get startOfWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  List<Transaction> get thisWeekTransactions =>
      transactions.where((t) => !t.date.isBefore(startOfWeek)).toList();

  double get essentialWeekTotal => thisWeekTransactions
      .where((t) => !t.isIncome && categoryById(t.categoryId).isEssential)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get nonEssentialWeekTotal => thisWeekTransactions
      .where((t) => !t.isIncome && !categoryById(t.categoryId).isEssential)
      .fold(0.0, (sum, t) => sum + t.amount);

  Map<String, double> get nonEssentialWeekByCategory {
    final map = <String, double>{};
    for (final t in thisWeekTransactions
        .where((t) => !t.isIncome && !categoryById(t.categoryId).isEssential)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  // Fixed monthly budget (income vs. fixed expenses worksheet). Adding one
  // deposits/charges it into Finanzas immediately, then again automatically
  // every new calendar month — see _applyDueFixedItems.
  Future<void> addFixedIncome(String label, double amount) async {
    fixedIncomes.add(FixedMoneyItem(id: _uuid.v4(), label: label, amount: amount));
    await _applyDueFixedItems();
    notifyListeners();
  }

  Future<void> deleteFixedIncome(String id) async {
    fixedIncomes.removeWhere((i) => i.id == id);
    await _storage.saveFixedIncomes(fixedIncomes);
    notifyListeners();
  }

  Future<void> addFixedExpense(String label, double amount) async {
    fixedExpenses.add(FixedMoneyItem(id: _uuid.v4(), label: label, amount: amount));
    await _applyDueFixedItems();
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

  // Piggy banks (alcancías) — independent money pools, unlike the shared
  // "Ahorro" category savings goals draw from. Deposits/withdrawals flow
  // through the real transaction ledger so Finanzas stays consistent.
  Future<void> addPiggyBank({
    required String name,
    required String iconKey,
    required Color color,
    double? targetAmount,
  }) async {
    piggyBanks.add(PiggyBank(
      id: _uuid.v4(),
      name: name,
      iconKey: iconKey,
      color: color,
      targetAmount: targetAmount,
      createdAt: DateTime.now(),
    ));
    await _storage.savePiggyBanks(piggyBanks);
    notifyListeners();
  }

  Future<void> deletePiggyBank(String id) async {
    piggyBanks.removeWhere((b) => b.id == id);
    await _storage.savePiggyBanks(piggyBanks);
    notifyListeners();
  }

  Future<void> depositToPiggyBank(String id, double amount) async {
    final bank = piggyBanks.firstWhere((b) => b.id == id);
    bank.savedAmount += amount;
    transactions.insert(
      0,
      Transaction(
        id: _uuid.v4(),
        categoryId: 'ahorro',
        isIncome: false,
        amount: amount,
        note: 'Alcancía: ${bank.name}',
        date: DateTime.now(),
      ),
    );
    await _storage.savePiggyBanks(piggyBanks);
    await _storage.saveTransactions(transactions);
    notifyListeners();
  }

  Future<void> withdrawFromPiggyBank(String id, double amount) async {
    final bank = piggyBanks.firstWhere((b) => b.id == id);
    final actual = amount.clamp(0.0, bank.savedAmount);
    if (actual <= 0) return;
    bank.savedAmount -= actual;
    transactions.insert(
      0,
      Transaction(
        id: _uuid.v4(),
        categoryId: 'ahorro',
        isIncome: true,
        amount: actual,
        note: 'Retiro de alcancía: ${bank.name}',
        date: DateTime.now(),
      ),
    );
    await _storage.savePiggyBanks(piggyBanks);
    await _storage.saveTransactions(transactions);
    notifyListeners();
  }

  double get totalSavedInPiggyBanks =>
      piggyBanks.fold(0.0, (sum, b) => sum + b.savedAmount);

  // Mi Día — routine blocks, quick-capture queues per business and the
  // end-of-day review. Captures can happen anytime; *attending* them is
  // meant for business windows, so every attend action is timestamped to
  // tell inside-window work from interruptions.
  List<DayBlock> blocksFor(DateTime day) =>
      dayBlocks.where((b) => b.appliesOn(day)).toList()
        ..sort((a, b) => a.startMinute.compareTo(b.startMinute));

  DayBlock? blockAt(DateTime time) {
    final minute = time.hour * 60 + time.minute;
    for (final b in blocksFor(time)) {
      if (b.containsMinute(minute)) return b;
    }
    return null;
  }

  DayBlock? get currentBlock => blockAt(DateTime.now());

  DayBlock? get nextBlock {
    final now = DateTime.now();
    final minute = now.hour * 60 + now.minute;
    for (final b in blocksFor(now)) {
      if (b.startMinute > minute) return b;
    }
    return null;
  }

  bool isBusinessWindow(DateTime time) => blockAt(time)?.kind == BlockKind.negocio;

  Future<void> addDayBlock(DayBlock block) async {
    dayBlocks.add(block);
    await _storage.saveDayBlocks(dayBlocks);
    notifyListeners();
  }

  Future<void> updateDayBlock(DayBlock block) async {
    final i = dayBlocks.indexWhere((b) => b.id == block.id);
    if (i == -1) return;
    dayBlocks[i] = block;
    await _storage.saveDayBlocks(dayBlocks);
    notifyListeners();
  }

  Future<void> deleteDayBlock(String id) async {
    dayBlocks.removeWhere((b) => b.id == id);
    await _storage.saveDayBlocks(dayBlocks);
    notifyListeners();
  }

  Future<void> resetDayBlocks() async {
    dayBlocks = defaultDayBlocks();
    await _storage.saveDayBlocks(dayBlocks);
    notifyListeners();
  }

  Business businessById(String id) =>
      businesses.firstWhere((b) => b.id == id, orElse: () => businesses.first);

  List<Lead> leadsFor(String businessId, LeadStage stage) => leads
      .where((l) => l.businessId == businessId && l.stage == stage)
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  /// Captured but not yet attended — what's waiting when a window opens.
  List<Lead> queueFor(String businessId) => leadsFor(businessId, LeadStage.nuevo);

  int get totalQueued => leads.where((l) => l.stage == LeadStage.nuevo).length;

  List<Lead> coolingFor(String businessId) =>
      leads.where((l) => l.businessId == businessId && l.isCooling).toList();

  Future<void> addLead(String businessId, String text) async {
    final now = DateTime.now();
    leads.add(Lead(
      id: _uuid.v4(),
      businessId: businessId,
      text: text,
      createdAt: now,
      updatedAt: now,
    ));
    await _storage.saveLeads(leads);
    notifyListeners();
  }

  Future<void> moveLead(String id, LeadStage stage) async {
    final lead = leads.firstWhere((l) => l.id == id);
    final now = DateTime.now();
    lead.stage = stage;
    lead.updatedAt = now;
    lead.closedAt = stage.isOpen ? null : now;
    await _logBusinessAction(now);
    await _storage.saveLeads(leads);
    notifyListeners();
  }

  Future<void> updateLeadText(String id, String text) async {
    final lead = leads.firstWhere((l) => l.id == id);
    lead.text = text;
    lead.updatedAt = DateTime.now();
    await _storage.saveLeads(leads);
    notifyListeners();
  }

  Future<void> deleteLead(String id) async {
    leads.removeWhere((l) => l.id == id);
    await _storage.saveLeads(leads);
    notifyListeners();
  }

  Future<void> _logBusinessAction(DateTime at) async {
    final cutoff = at.subtract(const Duration(days: 30));
    businessActions
      ..removeWhere((a) => a.isBefore(cutoff))
      ..add(at);
    await _storage.saveBusinessActions(businessActions);
  }

  DayClose get todayClose {
    final now = DateTime.now();
    final today = dateKey(now);
    final minuteNow = now.hour * 60 + now.minute;
    final windows = blocksFor(now)
        .where((b) => b.kind == BlockKind.negocio && b.startMinute <= minuteNow)
        .toList();
    final actionsToday = businessActions.where((a) => dateKey(a) == today).toList();

    var attended = 0;
    for (final w in windows) {
      final hit = actionsToday.any((a) => w.containsMinute(a.hour * 60 + a.minute));
      if (hit) attended++;
    }
    final inside = actionsToday.where(isBusinessWindow).length;

    return DayClose(
      windowsSoFar: windows.length,
      windowsAttended: attended,
      actionsInWindow: inside,
      actionsOutside: actionsToday.length - inside,
      captured: leads.where((l) => dateKey(l.createdAt) == today).length,
      resolved: leads
          .where((l) => l.closedAt != null && dateKey(l.closedAt!) == today)
          .length,
      carriedOver: totalQueued,
    );
  }
}

class DayClose {
  final int windowsSoFar;
  final int windowsAttended;
  final int actionsInWindow;
  final int actionsOutside;
  final int captured;
  final int resolved;
  final int carriedOver;

  const DayClose({
    required this.windowsSoFar,
    required this.windowsAttended,
    required this.actionsInWindow,
    required this.actionsOutside,
    required this.captured,
    required this.resolved,
    required this.carriedOver,
  });
}

const _weekdays = [1, 2, 3, 4, 5];

int _m(int h, [int m = 0]) => h * 60 + m;

/// Starting routine built around a 6 am wake-up and an 8–5 job, with
/// short business windows at the edges of the workday and after the gym.
List<DayBlock> defaultDayBlocks() {
  DayBlock b(String label, BlockKind kind, int start, int end, List<int> days) =>
      DayBlock(
        id: _uuid.v4(),
        label: label,
        kind: kind,
        startMinute: start,
        endMinute: end,
        weekdays: days,
      );
  return [
    b('Despertar y alistarte', BlockKind.descanso, _m(6), _m(7, 30), _weekdays),
    b('Ventana rápida', BlockKind.negocio, _m(7, 30), _m(8), _weekdays),
    b('Trabajo', BlockKind.trabajo, _m(8), _m(12, 30), _weekdays),
    b('Comida · ventana', BlockKind.negocio, _m(12, 30), _m(13, 30), _weekdays),
    b('Trabajo', BlockKind.trabajo, _m(13, 30), _m(17), _weekdays),
    b('Gym', BlockKind.gym, _m(17, 30), _m(19), _weekdays),
    b('Ventana principal', BlockKind.negocio, _m(19, 30), _m(21), _weekdays),
    b('Descanso', BlockKind.descanso, _m(21), _m(23), _weekdays),
    b('Gym', BlockKind.gym, _m(9), _m(10, 30), [6]),
    b('Citas y visitas', BlockKind.negocio, _m(10, 30), _m(14), [6]),
    b('Descanso', BlockKind.descanso, _m(14), _m(23), [6]),
    b('Ventana corta', BlockKind.negocio, _m(11), _m(13), [7]),
  ];
}

List<Business> defaultBusinesses() => [
      Business(id: 'carros', name: 'Carros', emoji: '🚗', closedLabel: 'Vendido'),
      Business(id: 'viajes', name: 'Viajes', emoji: '✈️', closedLabel: 'Reservado'),
    ];
