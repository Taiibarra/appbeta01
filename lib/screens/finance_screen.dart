import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_category.dart';
import '../models/transaction.dart';
import '../services/app_state.dart';
import '../services/date_format_es.dart';
import '../services/money_format.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Finanzas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Presupuestos',
            onPressed: () => _showBudgetsSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          _BalanceHeader(appState: appState),
          const SizedBox(height: 20),
          if (appState.monthSpendByCategory.isNotEmpty) ...[
            const SectionHeader(title: 'Gastos por categoría'),
            const SizedBox(height: 12),
            _CategoryBreakdown(appState: appState),
            const SizedBox(height: 24),
          ],
          if (appState.budgets.isNotEmpty) ...[
            const SectionHeader(title: 'Presupuestos'),
            const SizedBox(height: 12),
            ...appState.budgets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BudgetRow(
                    category: b.category,
                    limit: b.monthlyLimit,
                    spent: appState.spentThisMonthFor(b.category),
                  ),
                )),
            const SizedBox(height: 14),
          ],
          const SectionHeader(title: 'Movimientos recientes'),
          const SizedBox(height: 12),
          if (appState.transactions.isEmpty)
            const _EmptyTransactions()
          else
            ...appState.transactions.take(30).map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TransactionRow(transaction: t),
                )),
        ],
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddTransactionSheet(),
    );
  }

  void _showBudgetsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _BudgetsSheet(),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  final AppState appState;
  const _BalanceHeader({required this.appState});

  @override
  Widget build(BuildContext context) {
    final balance = appState.totalBalance;
    final positive = balance >= 0;

    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balance total', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(
            formatMoney(balance),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: positive ? AppColors.textPrimary : AppColors.coral,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Ingresos (mes)',
                  value: formatMoney(appState.monthIncome),
                  color: AppColors.mint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Gastos (mes)',
                  value: formatMoney(appState.monthExpense),
                  color: AppColors.coral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final AppState appState;
  const _CategoryBreakdown({required this.appState});

  @override
  Widget build(BuildContext context) {
    final data = appState.monthSpendByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = data.fold<double>(0, (sum, e) => sum + e.value);

    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 34,
                sections: data.map((e) {
                  return PieChartSectionData(
                    value: e.value,
                    color: e.key.color,
                    showTitle: false,
                    radius: 20,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.take(5).map((e) {
                final pct = total == 0 ? 0 : (e.value / total * 100).round();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: e.key.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(e.key.label,
                            style: const TextStyle(fontSize: 12.5),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('$pct%',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final FinanceCategory category;
  final double limit;
  final double spent;

  const _BudgetRow({required this.category, required this.limit, required this.spent});

  @override
  Widget build(BuildContext context) {
    final ratio = limit == 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final over = spent > limit;
    final color = over
        ? AppColors.coral
        : ratio >= 0.9
            ? AppColors.amber
            : AppColors.mint;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 16, color: category.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(category.label,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              Text(
                '${formatMoney(spent)} / ${formatMoney(limit)}',
                style: TextStyle(
                    fontSize: 12, color: over ? AppColors.coral : AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: AppColors.surfaceRaised,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.coral.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.coral),
      ),
      onDismissed: (_) => context.read<AppState>().deleteTransaction(transaction.id),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: transaction.category.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(transaction.category.icon, color: transaction.category.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.note.isNotEmpty ? transaction.note : transaction.category.label,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.category.label} · ${formatDateShortEs(transaction.date)}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              '${transaction.isIncome ? '+' : '-'}${formatMoney(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: transaction.isIncome ? AppColors.mint : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: const [
          Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('Aún no registras movimientos',
              style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text(
            'Agrega tu primer ingreso o gasto con el botón +.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _AddTransactionSheet extends StatefulWidget {
  const _AddTransactionSheet();

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  bool isExpense = true;
  FinanceCategory category = FinanceCategory.comida;
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final categories = isExpense
        ? FinanceCategoryX.expenseCategories
        : FinanceCategoryX.incomeCategories;
    if (!categories.contains(category)) category = categories.first;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nuevo movimiento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TypeToggle(
                    label: 'Gasto',
                    selected: isExpense,
                    color: AppColors.coral,
                    onTap: () => setState(() => isExpense = true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TypeToggle(
                    label: 'Ingreso',
                    selected: !isExpense,
                    color: AppColors.mint,
                    onTap: () => setState(() => isExpense = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(prefixText: '\$ ', hintText: '0'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(hintText: 'Nota (opcional)'),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((c) {
                final selected = c == category;
                return GestureDetector(
                  onTap: () => setState(() => category = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? c.color.withValues(alpha: 0.18) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? c.color : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 14, color: c.color),
                        const SizedBox(width: 6),
                        Text(c.label, style: const TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) return;
                  context.read<AppState>().addTransaction(
                        category,
                        amount,
                        noteController.text.trim(),
                        date,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeToggle({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? color : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _BudgetsSheet extends StatefulWidget {
  const _BudgetsSheet();

  @override
  State<_BudgetsSheet> createState() => _BudgetsSheetState();
}

class _BudgetsSheetState extends State<_BudgetsSheet> {
  late Map<FinanceCategory, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    controllers = {
      for (final c in FinanceCategoryX.expenseCategories)
        c: TextEditingController(
          text: appState.budgets
              .where((b) => b.category == c)
              .map((b) => b.monthlyLimit.toStringAsFixed(0))
              .firstOrNull ??
              '',
        ),
    };
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Presupuestos mensuales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text(
                'Define un límite por categoría para recibir alertas cuando te acerques.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: FinanceCategoryX.expenseCategories.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(c.icon, size: 18, color: c.color),
                          const SizedBox(width: 10),
                          Expanded(child: Text(c.label, style: const TextStyle(fontSize: 13.5))),
                          SizedBox(
                            width: 110,
                            child: TextField(
                              controller: controllers[c],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                prefixText: '\$ ',
                                isDense: true,
                                hintText: 'Sin límite',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final appState = context.read<AppState>();
                    for (final entry in controllers.entries) {
                      final value = double.tryParse(entry.value.text.trim());
                      if (value == null || value <= 0) {
                        appState.removeBudget(entry.key);
                      } else {
                        appState.setBudget(entry.key, value);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar presupuestos'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
