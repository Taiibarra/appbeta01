import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import 'habit_calendar_screen.dart';

const _emojiOptions = ['💪', '📚', '🧘', '💧', '🏃', '😴', '🥗', '✍️', '🎯', '🚭'];

const _habitPresets = [
  ('Ir al gym', '💪'),
  ('Leer 20 min', '📚'),
  ('Meditar', '🧘'),
  ('Tomar agua', '💧'),
  ('Salir a correr', '🏃'),
  ('Dormir temprano', '😴'),
  ('Comer sano', '🥗'),
  ('Sin fumar', '🚭'),
];

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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
                    const Text('Nuevo hábito',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    const Text('Sugerencias',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _habitPresets.map((preset) {
                        return GestureDetector(
                          onTap: () => setState(() {
                            controller.text = preset.$1;
                            selectedEmoji = preset.$2;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(preset.$2, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(preset.$1, style: const TextStyle(fontSize: 12.5)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
                                  ? AppColors.indigo.withValues(alpha: 0.22)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: selected ? AppColors.indigo : AppColors.border,
                              ),
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

class _HabitTile extends StatefulWidget {
  final Habit habit;
  const _HabitTile({required this.habit});

  @override
  State<_HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<_HabitTile> with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 55),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onTap() {
    final appState = context.read<AppState>();
    final habit = widget.habit;
    final wasDone = habit.isCompletedOn(dateKey(DateTime.now()));

    appState.toggleHabitToday(habit.id);

    if (!wasDone) {
      _bounceController.forward(from: 0);
      final allDone = appState.habits.isNotEmpty &&
          appState.todayCompletedCount == appState.habits.length;
      if (allDone) _celebrate(context);
    }
  }

  void _celebrate(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.rust),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡Completaste todos tus hábitos de hoy!',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final doneToday = habit.isCompletedOn(dateKey(DateTime.now()));

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onLongPress: () => _confirmDelete(context, habit),
        onTap: _onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.surfaceRaised,
                child: Text(habit.emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      habit.currentStreak > 0
                          ? '🔥 Racha de ${habit.currentStreak} día${habit.currentStreak == 1 ? '' : 's'}'
                          : 'Sin racha activa',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HabitCalendarScreen(habit: habit)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.calendar_month_outlined,
                      color: AppColors.textMuted, size: 20),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _bounce,
                builder: (context, child) => Transform.scale(
                  scale: _bounce.value,
                  child: child,
                ),
                child: Icon(
                  doneToday ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: doneToday ? AppColors.mint : AppColors.textMuted,
                  size: 26,
                ),
              ),
            ],
          ),
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
              onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: const Text('ELIMINAR'),
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
                size: 56, color: AppColors.indigo),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes hábitos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea tu primer hábito y empieza a construir tu racha.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAdd, child: const Text('CREAR HÁBITO')),
          ],
        ),
      ),
    );
  }
}
