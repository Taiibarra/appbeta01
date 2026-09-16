import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/insight.dart';
import '../services/app_state.dart';
import '../services/insights_engine.dart';
import '../services/money_format.dart';
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
                    _greeting(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(quoteOfTheDay(),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
                ],
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
                color: AppColors.indigo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                icon: Icons.local_fire_department_rounded,
                value: '$longestStreak',
                label: 'Mejor racha',
                color: AppColors.amber,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                icon: Icons.account_balance_wallet_rounded,
                value: formatMoney(appState.totalBalance),
                label: 'Balance',
                color: appState.totalBalance >= 0 ? AppColors.mint : AppColors.coral,
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
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
          width: 6,
          height: 6,
          decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
