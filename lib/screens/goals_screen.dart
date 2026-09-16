import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/finance_category.dart';
import '../models/goal.dart';
import '../models/piggy_bank.dart';
import '../services/app_state.dart';
import '../services/date_format_es.dart';
import '../services/money_format.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final goals = appState.goals;
    final banks = appState.piggyBanks;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Metas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalSheet(context),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          SectionHeader(
            title: 'Alcancías',
            action: 'Agregar',
            onAction: () => _showAddPiggyBankSheet(context),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aparta dinero para un propósito específico — cada alcancía es un '
            'monto independiente, no se mezcla con las demás.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 12),
          if (banks.isEmpty)
            AppCard(
              child: Text(
                'Sin alcancías todavía.',
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            )
          else
            ...banks.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PiggyBankCard(bank: b),
                )),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Metas'),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            const _EmptyGoals()
          else
            ...goals.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GoalCard(goal: g),
                )),
        ],
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? targetDate;
    bool isFinancial = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
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
                    const Text('Nueva meta',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Ej. Correr 5km'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(hintText: 'Descripción (opcional)'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) setState(() => targetDate = picked);
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(targetDate == null
                          ? 'Fecha objetivo (opcional)'
                          : formatDateShortEs(targetDate!)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Meta de ahorro',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              const Text(
                                'El progreso se calcula solo desde tus transacciones de Ahorro.',
                                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isFinancial,
                          activeThumbColor: AppColors.rust,
                          onChanged: (v) => setState(() => isFinancial = v),
                        ),
                      ],
                    ),
                    if (isFinancial) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration:
                            const InputDecoration(prefixText: '\$ ', hintText: 'Monto objetivo'),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;
                          double? targetAmount;
                          if (isFinancial) {
                            targetAmount = double.tryParse(
                                amountController.text.replaceAll(',', '.'));
                            if (targetAmount == null || targetAmount <= 0) return;
                          }
                          context.read<AppState>().addGoal(
                                title,
                                descController.text.trim(),
                                targetDate,
                                targetAmount: targetAmount,
                              );
                          Navigator.pop(ctx);
                        },
                        child: const Text('AGREGAR'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPiggyBankSheet(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    String iconKey = 'compras';
    Color color = categoryColorPalette.first;
    bool hasTarget = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
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
                    const Text('Nueva alcancía',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Ej. iPhone nuevo'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Ícono', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categoryIconPalette.entries.map((e) {
                        final selected = e.key == iconKey;
                        return GestureDetector(
                          onTap: () => setState(() => iconKey = e.key),
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: selected ? color.withValues(alpha: 0.2) : AppColors.surface,
                              border: Border.all(color: selected ? color : AppColors.border),
                            ),
                            child: Icon(e.value,
                                size: 17, color: selected ? color : AppColors.textMuted),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Color', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Row(
                      children: categoryColorPalette.map((c) {
                        final selected = c == color;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => color = c),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? AppColors.textPrimary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ponerle una meta', style: TextStyle(fontSize: 13.5)),
                        Switch(
                          value: hasTarget,
                          activeThumbColor: AppColors.rust,
                          onChanged: (v) => setState(() => hasTarget = v),
                        ),
                      ],
                    ),
                    if (hasTarget) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: targetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration:
                            const InputDecoration(prefixText: '\$ ', hintText: 'Monto objetivo'),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;
                          double? target;
                          if (hasTarget) {
                            target = double.tryParse(targetController.text.replaceAll(',', '.'));
                          }
                          context.read<AppState>().addPiggyBank(
                                name: name,
                                iconKey: iconKey,
                                color: color,
                                targetAmount: target,
                              );
                          Navigator.pop(ctx);
                        },
                        child: const Text('CREAR ALCANCÍA'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PiggyBankCard extends StatelessWidget {
  final PiggyBank bank;
  const _PiggyBankCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    final icon = categoryIconPalette[bank.iconKey] ?? Icons.savings_rounded;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bank.color.withValues(alpha: 0.16)),
                child: Icon(icon, size: 16, color: bank.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(bank.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                onPressed: () => context.read<AppState>().deletePiggyBank(bank.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: formatMoney(bank.savedAmount),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (bank.targetAmount != null)
                  TextSpan(
                    text: ' / ${formatMoney(bank.targetAmount!)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          if (bank.targetAmount != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: bank.progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceRaised,
                color: bank.color,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showAmountDialog(
                    context,
                    title: 'Agregar dinero',
                    onConfirm: (amount) =>
                        context.read<AppState>().depositToPiggyBank(bank.id, amount),
                  ),
                  child: const Text('AGREGAR', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: bank.savedAmount <= 0
                      ? null
                      : () => _showAmountDialog(
                            context,
                            title: 'Retirar dinero',
                            max: bank.savedAmount,
                            onConfirm: (amount) =>
                                context.read<AppState>().withdrawFromPiggyBank(bank.id, amount),
                          ),
                  child: const Text('RETIRAR', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAmountDialog(
    BuildContext context, {
    required String title,
    required ValueChanged<double> onConfirm,
    double? max,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: max != null ? 'Máximo ${formatMoney(max)}' : '0',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.replaceAll(',', '.'));
              if (amount == null || amount <= 0) return;
              onConfirm(amount);
              Navigator.pop(ctx);
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final progress = appState.effectiveProgress(goal);
    final done = appState.effectiveDone(goal);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (goal.isFinancial) ...[
                const Icon(Icons.savings_outlined, size: 16, color: AppColors.olive),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? AppColors.textMuted : AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textMuted),
                onPressed: () => context.read<AppState>().deleteGoal(goal.id),
              ),
            ],
          ),
          if (goal.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(goal.description,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          if (goal.targetDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Meta: ${formatDateShortEs(goal.targetDate!)}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          if (goal.isFinancial)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${formatMoney(appState.totalSavedAllTime)} de ${formatMoney(goal.targetAmount!)} ahorrados',
                style: const TextStyle(color: AppColors.olive, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceRaised,
              color: done ? AppColors.olive : AppColors.rustLight,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).round()}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              if (!goal.isFinancial)
                Expanded(
                  child: Slider(
                    value: progress,
                    onChanged: (v) =>
                        context.read<AppState>().updateGoalProgress(goal.id, v),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aún no tienes metas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 6),
          Text(
            'Usa el botón + para definir una meta y dar seguimiento a tu progreso.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}
