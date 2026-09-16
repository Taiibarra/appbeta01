import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../services/app_state.dart';
import '../services/date_format_es.dart';
import '../services/money_format.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final goals = appState.goals;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Metas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalSheet(context),
        child: const Icon(Icons.add),
      ),
      body: goals.isEmpty
          ? _EmptyState(onAdd: () => _showAddGoalSheet(context))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: goals.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _GoalCard(goal: goals[i]),
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_outlined, size: 56, color: AppColors.indigo),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes metas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Define una meta y da seguimiento a tu progreso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAdd, child: const Text('CREAR META')),
          ],
        ),
      ),
    );
  }
}
