import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/day_block.dart';
import '../services/app_state.dart';
import '../services/date_format_es.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

const _dayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _weekday = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final blocks = appState.dayBlocks.where((b) => b.weekdays.contains(_weekday)).toList()
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));

    return Scaffold(
      appBar: AppBar(title: const Text('Mi horario')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBlockSheet(context, null, _weekday),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          Row(
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = day == _weekday;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _weekday = day),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.rust.withValues(alpha: 0.22) : null,
                      border: Border.all(color: selected ? AppColors.rust : AppColors.border),
                    ),
                    child: Text(_dayLetters[i],
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          if (blocks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  const Text('Sin bloques este día',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    'Agrega tus bloques: trabajo, gym, ventanas para tus negocios y descanso. '
                    'Al crear uno puedes marcar varios días a la vez.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => _showBlockSheet(context, null, _weekday),
                    child: const Text('AGREGAR BLOQUE'),
                  ),
                ],
              ),
            ),
          ...blocks.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => _showBlockSheet(context, b, _weekday),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(b.kind.icon, color: b.kind.color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              '${b.kind.label} · ${formatMinuteOfDay(b.startMinute)}–${formatMinuteOfDay(b.endMinute)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        b.weekdays.map((d) => _dayLetters[d - 1]).join(' '),
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

void _showBlockSheet(BuildContext context, DayBlock? existing, int weekday) {
  final appState = context.read<AppState>();
  final label = TextEditingController(text: existing?.label ?? '');
  // A new block picks up where that day's last block ends, so building
  // the day top to bottom is mostly just choosing the end time.
  final lastEnd = appState.dayBlocks
      .where((b) => b.weekdays.contains(weekday))
      .fold<int?>(null, (m, b) => m == null || b.endMinute > m ? b.endMinute : m);
  var kind = existing?.kind ?? BlockKind.trabajo;
  var start = existing?.startMinute ?? lastEnd ?? 6 * 60;
  var end = existing?.endMinute ?? (start + 60).clamp(0, 23 * 60 + 59);
  final days = {...?existing?.weekdays, if (existing == null) weekday};

  Future<int?> pickTime(BuildContext ctx, int minute) async {
    final t = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final valid = end > start && days.isNotEmpty;
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
                Text(existing == null ? 'Nuevo bloque' : 'Editar bloque',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BlockKind.values.map((k) {
                    final selected = k == kind;
                    return GestureDetector(
                      onTap: () => setState(() => kind = k),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? k.color.withValues(alpha: 0.22) : AppColors.surface,
                          border: Border.all(color: selected ? k.color : AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(k.icon, size: 16, color: k.color),
                            const SizedBox(width: 6),
                            Text(k.label),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: label,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: 'Nombre (ej. ${kind.label})'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final m = await pickTime(ctx, start);
                          if (m != null) setState(() => start = m);
                        },
                        child: Text('Inicio  ${formatMinuteOfDay(start)}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final m = await pickTime(ctx, end);
                          if (m != null) setState(() => end = m);
                        },
                        child: Text('Fin  ${formatMinuteOfDay(end)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(7, (i) {
                    final d = i + 1;
                    final on = days.contains(d);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => on ? days.remove(d) : days.add(d)),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: on ? AppColors.rust.withValues(alpha: 0.22) : AppColors.surface,
                            border: Border.all(color: on ? AppColors.rust : AppColors.border),
                          ),
                          child: Text(_dayLetters[i]),
                        ),
                      ),
                    );
                  }),
                ),
                if (end <= start) ...[
                  const SizedBox(height: 10),
                  const Text('La hora de fin debe ser después del inicio.',
                      style: TextStyle(fontSize: 12, color: AppColors.danger)),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (existing != null)
                      TextButton.icon(
                        onPressed: () {
                          appState.deleteDayBlock(existing.id);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.danger),
                        label: const Text('ELIMINAR',
                            style: TextStyle(color: AppColors.danger)),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: !valid
                          ? null
                          : () {
                              final block = DayBlock(
                                id: existing?.id ?? const Uuid().v4(),
                                label: label.text.trim().isEmpty
                                    ? kind.label
                                    : label.text.trim(),
                                kind: kind,
                                startMinute: start,
                                endMinute: end,
                                weekdays: days.toList()..sort(),
                              );
                              existing == null
                                  ? appState.addDayBlock(block)
                                  : appState.updateDayBlock(block);
                              Navigator.pop(ctx);
                            },
                      child: const Text('GUARDAR'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
