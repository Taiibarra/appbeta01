import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/fixed_money_item.dart';
import '../services/app_state.dart';
import '../services/money_format.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';

class FixedBudgetScreen extends StatelessWidget {
  const FixedBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Presupuesto fijo')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const Text(
            'Anota tus ingresos mensuales y tus gastos fijos para ver de un '
            'vistazo cuánto te queda libre cada mes.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Ingresos fijos',
            action: 'Agregar',
            onAction: () => _showAddSheet(
              context,
              isIncome: true,
            ),
          ),
          const SizedBox(height: 12),
          if (appState.fixedIncomes.isEmpty)
            const _EmptyRow(text: 'Sin ingresos fijos registrados.')
          else
            ...appState.fixedIncomes.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FixedItemRow(
                    item: i,
                    color: AppColors.olive,
                    onDelete: () => context.read<AppState>().deleteFixedIncome(i.id),
                  ),
                )),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Gastos fijos',
            action: 'Agregar',
            onAction: () => _showAddSheet(
              context,
              isIncome: false,
            ),
          ),
          const SizedBox(height: 12),
          if (appState.fixedExpenses.isEmpty)
            const _EmptyRow(text: 'Sin gastos fijos registrados.')
          else
            ...appState.fixedExpenses.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FixedItemRow(
                    item: i,
                    color: AppColors.danger,
                    onDelete: () => context.read<AppState>().deleteFixedExpense(i.id),
                  ),
                )),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Comparativa'),
          const SizedBox(height: 12),
          _ComparisonTable(appState: appState),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, {required bool isIncome}) {
    final labelController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.surfaceRaised,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isIncome ? 'NUEVO INGRESO FIJO' : 'NUEVO GASTO FIJO',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: isIncome ? 'Ej. Salario' : 'Ej. Renta',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(prefixText: '\$ ', hintText: '0'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final label = labelController.text.trim();
                    final amount =
                        double.tryParse(amountController.text.replaceAll(',', '.'));
                    if (label.isEmpty || amount == null || amount <= 0) return;
                    final state = context.read<AppState>();
                    if (isIncome) {
                      state.addFixedIncome(label, amount);
                    } else {
                      state.addFixedExpense(label, amount);
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('GUARDAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FixedItemRow extends StatelessWidget {
  final FixedMoneyItem item;
  final Color color;
  final VoidCallback onDelete;

  const _FixedItemRow({required this.item, required this.color, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
          Text(
            formatMoney(item.amount),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: color),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final AppState appState;
  const _ComparisonTable({required this.appState});

  @override
  Widget build(BuildContext context) {
    final income = appState.totalFixedIncome;
    final expenses = appState.totalFixedExpenses;
    final net = appState.fixedNet;
    final positive = net >= 0;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _row('Ingresos fijos', formatMoney(income), AppColors.olive),
          const Divider(height: 1),
          _row('Gastos fijos', '-${formatMoney(expenses)}', AppColors.danger),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: (positive ? AppColors.olive : AppColors.danger).withValues(alpha: 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  positive ? 'TE QUEDA LIBRE' : 'TE FALTA',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  formatMoney(net.abs()),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: positive ? AppColors.olive : AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String text;
  const _EmptyRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
    );
  }
}
