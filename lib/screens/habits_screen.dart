import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/app_state.dart';

const _emojiOptions = ['💪', '📚', '🧘', '💧', '🏃', '😴', '🥗', '✍️', '🎯', '🚭'];

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final habits = appState.habits;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Hábitos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitSheet(context),
        child: const Icon(Icons.add),
      ),
      body: habits.isEmpty
          ? _EmptyState(onAdd: () => _showAddHabitSheet(context))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: habits.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _HabitTile(habit: habits[i]),
            ),
    );
  }

  void _showAddHabitSheet(BuildContext context) {
    final controller = TextEditingController();
    String selectedEmoji = _emojiOptions.first;

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
                  Text('Nuevo hábito',
                      style: Theme.of(ctx)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Ej. Leer 20 minutos'),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _emojiOptions.map((e) {
                      final selected = e == selectedEmoji;
                      return GestureDetector(
                        onTap: () => setState(() => selectedEmoji = e),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF5E60CE).withValues(alpha: 0.2)
                                : const Color(0xFFF0EFFA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(e, style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        context.read<AppState>().addHabit(name, selectedEmoji);
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

class _HabitTile extends StatelessWidget {
  final Habit habit;
  const _HabitTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final doneToday = habit.isCompletedOn(dateKey(DateTime.now()));

    return Card(
      child: ListTile(
        onTap: () => appState.toggleHabitToday(habit.id),
        onLongPress: () => _confirmDelete(context, habit),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF0EFFA),
          child: Text(habit.emoji, style: const TextStyle(fontSize: 18)),
        ),
        title: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          habit.currentStreak > 0
              ? '🔥 Racha de ${habit.currentStreak} día${habit.currentStreak == 1 ? '' : 's'}'
              : 'Sin racha activa',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Icon(
          doneToday ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: doneToday ? const Color(0xFF4CAF93) : Colors.grey.shade400,
          size: 28,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Eliminar "${habit.name}"? Se perderá su historial.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
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
            const Icon(Icons.check_circle_outline_rounded,
                size: 56, color: Color(0xFF5E60CE)),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes hábitos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer hábito y empieza a construir tu racha.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAdd, child: const Text('Crear hábito')),
          ],
        ),
      ),
    );
  }
}
