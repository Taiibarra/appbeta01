import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/insight.dart';
import '../services/app_state.dart';
import '../services/insights_engine.dart';
import '../services/money_format.dart';
import '../services/notification_service.dart';
import '../services/quotes.dart';
import '../theme.dart';
import '../widgets/insight_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final insights = generateInsights(appState);
    final topInsight = insights.isNotEmpty ? insights.first : allGoodInsight;
    final restInsights = insights.length > 1 ? insights.sublist(1) : <Insight>[];

    final totalHabits = appState.habits.length;
    final doneToday = appState.todayCompletedCount;
    final longestStreak = appState.habits.isEmpty
        ? 0
        : appState.habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(appState.userName),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(quoteOfTheDay(),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showReminderSheet(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
                child: Icon(
                  appState.reminderEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_outlined,
                  size: 18,
                  color: appState.reminderEnabled ? AppColors.rust : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionLabel('Tu asistente dice'),
        const SizedBox(height: 10),
        InsightBanner(insight: topInsight),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.check_circle_rounded,
                value: totalHabits == 0 ? '-' : '$doneToday/$totalHabits',
                label: 'Hábitos hoy',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                icon: Icons.local_fire_department_rounded,
                value: '$longestStreak',
                label: 'Mejor racha',
                color: AppColors.rustLight,
                highlight: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                icon: Icons.account_balance_wallet_rounded,
                value: formatMoney(appState.totalBalance),
                label: 'Balance',
                color: appState.totalBalance >= 0 ? AppColors.olive : AppColors.danger,
              ),
            ),
          ],
        ),
        if (restInsights.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionHeader(title: 'Más observaciones'),
          const SizedBox(height: 12),
          ...restInsights.take(4).map(
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InsightRow(insight: i),
                ),
              ),
        ],
      ],
    );
  }

  void _showReminderSheet(BuildContext context) {
    final appState = context.read<AppState>();
    bool enabled = appState.reminderEnabled;
    TimeOfDay time = TimeOfDay(hour: appState.reminderHour, minute: appState.reminderMinute);

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
                    Text(
                      'RECORDATORIO DIARIO',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Te avisamos mientras la app esté abierta o en segundo plano '
                      'en tu navegador — no es una notificación garantizada con la '
                      'app cerrada del todo.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Activar recordatorio', style: TextStyle(fontSize: 14)),
                        Switch(
                          value: enabled,
                          activeThumbColor: AppColors.rust,
                          onChanged: (v) async {
                            if (v && NotificationService.permission != 'granted') {
                              final result = await NotificationService.requestPermission();
                              if (result != 'granted') return;
                            }
                            setState(() => enabled = v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hora', style: TextStyle(fontSize: 14)),
                        OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(context: ctx, initialTime: time);
                            if (picked != null) setState(() => time = picked);
                          },
                          child: Text(time.format(ctx)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          appState.setReminder(
                            enabled: enabled,
                            hour: time.hour,
                            minute: time.minute,
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('GUARDAR'),
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

  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final base = hour < 12
        ? 'Buenos días'
        : hour < 19
            ? 'Buenas tardes'
            : 'Buenas noches';
    final greeting = (name == null || name.isEmpty) ? base : '$base, $name';
    return greeting.toUpperCase();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 1,
          color: AppColors.rust,
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.barlowCondensed(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
