import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../services/app_state.dart';
import '../services/date_format_es.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: goals.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _GoalCard(goal: goals[i]),
            ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? targetDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nueva meta',
                      style: Theme.of(ctx)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;
                        context
                            .read<AppState>()
                            .addGoal(title, descController.text.trim(), targetDate);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Agregar'),
                    ),
                  ),
                ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: goal.done ? TextDecoration.lineThrough : null,
                      color: goal.done ? Colors.grey : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => context.read<AppState>().deleteGoal(goal.id),
                ),
              ],
            ),
            if (goal.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(goal.description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ),
            if (goal.targetDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Meta: ${formatDateShortEs(goal.targetDate!)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFF0EFFA),
                color: goal.done ? const Color(0xFF4CAF93) : const Color(0xFF5E60CE),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(goal.progress * 100).round()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Expanded(
                  child: Slider(
                    value: goal.progress,
                    onChanged: (v) =>
                        context.read<AppState>().updateGoalProgress(goal.id, v),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            const Icon(Icons.flag_outlined, size: 56, color: Color(0xFF5E60CE)),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes metas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Define una meta y da seguimiento a tu progreso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAdd, child: const Text('Crear meta')),
          ],
        ),
      ),
    );
  }
}
