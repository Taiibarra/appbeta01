import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/journal_entry.dart';
import '../theme.dart';
import 'app_card.dart';

/// Line chart of mood over the most recent journal entries. Mood is
/// scored 0 (muy mal) to 4 (excelente) — the inverse of the Mood enum's
/// declaration order, which runs best-to-worst.
class MoodChart extends StatelessWidget {
  final List<JournalEntry> entries;
  const MoodChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final chronological = entries.reversed.take(14).toList();
    if (chronological.length < 2) {
      return AppCard(
        child: Text(
          'Registra al menos 2 entradas para ver tu tendencia de ánimo.',
          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < chronological.length; i++) {
      final score = (4 - chronological[i].mood.index).toDouble();
      spots.add(FlSpot(i.toDouble(), score));
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TU ÁNIMO EN EL TIEMPO',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textMuted)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minY: -0.4,
                maxY: 4.4,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: AppColors.rust,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.rust,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.rust.withValues(alpha: 0.10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_shortDate(chronological.first.date),
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
              Text(_shortDate(chronological.last.date),
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  String _shortDate(DateTime d) => '${d.day}/${d.month}';
}
