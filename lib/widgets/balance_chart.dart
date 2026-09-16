import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../theme.dart';
import 'app_card.dart';

const _monthAbbr = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// Bar chart of net balance (income − expense) for each of the last
/// [months] calendar months, so trends are visible at a glance instead
/// of only the current month's snapshot.
class BalanceChart extends StatelessWidget {
  final List<Transaction> transactions;
  final int months;

  const BalanceChart({super.key, required this.transactions, this.months = 6});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final buckets = <DateTime, double>{};
    for (var i = months - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      buckets[d] = 0;
    }
    for (final t in transactions) {
      final key = DateTime(t.date.year, t.date.month, 1);
      if (!buckets.containsKey(key)) continue;
      buckets[key] = buckets[key]! + (t.isIncome ? t.amount : -t.amount);
    }

    final entries = buckets.entries.toList();
    final maxAbs = entries.fold<double>(
        1, (m, e) => e.value.abs() > m ? e.value.abs() : m);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BALANCE POR MES',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textMuted)),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: BarChart(
              BarChartData(
                minY: -maxAbs * 1.15,
                maxY: maxAbs * 1.15,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _monthAbbr[entries[i].key.month - 1],
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(entries.length, (i) {
                  final value = entries[i].value;
                  final positive = value >= 0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 14,
                        color: positive ? AppColors.olive : AppColors.danger,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
