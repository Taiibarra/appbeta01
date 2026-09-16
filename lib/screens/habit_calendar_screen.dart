import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/habit.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

const _weekdayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const _monthNames = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

class HabitCalendarScreen extends StatefulWidget {
  final Habit habit;
  const HabitCalendarScreen({super.key, required this.habit});

  @override
  State<HabitCalendarScreen> createState() => _HabitCalendarScreenState();
}

class _HabitCalendarScreenState extends State<HabitCalendarScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // Monday = 1 ... Sunday = 7 -> leading blanks before day 1.
    final leadingBlanks = firstOfMonth.weekday - 1;
    final today = DateTime.now();
    final isCurrentMonthToday =
        _visibleMonth.year == today.year && _visibleMonth.month == today.month;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(habit.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Text(habit.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatBox(label: 'RACHA ACTUAL', value: '${habit.currentStreak}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(label: 'MEJOR RACHA', value: '${habit.longestStreak}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                    label: 'TOTAL', value: '${habit.completedDates.length}'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => setState(() {
                        _visibleMonth =
                            DateTime(_visibleMonth.year, _visibleMonth.month - 1);
                      }),
                    ),
                    Text(
                      '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}'
                          .toUpperCase(),
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: isCurrentMonthToday
                          ? null
                          : () => setState(() {
                                _visibleMonth = DateTime(
                                    _visibleMonth.year, _visibleMonth.month + 1);
                              }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: _weekdayLabels
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(d,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.textMuted)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 6),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: leadingBlanks + daysInMonth,
                  itemBuilder: (context, index) {
                    if (index < leadingBlanks) return const SizedBox.shrink();
                    final day = index - leadingBlanks + 1;
                    final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
                    final isFuture = date.isAfter(today);
                    final key = dateKey(date);
                    final done = habit.completedDates.contains(key);
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done ? AppColors.olive.withValues(alpha: 0.22) : null,
                        border: Border.all(
                          color: done ? AppColors.olive : AppColors.border,
                        ),
                      ),
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                          color: isFuture
                              ? AppColors.textMuted.withValues(alpha: 0.4)
                              : done
                                  ? AppColors.olive
                                  : AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.barlowCondensed(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
