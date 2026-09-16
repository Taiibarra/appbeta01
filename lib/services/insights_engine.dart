import 'package:flutter/material.dart';

import '../models/insight.dart';
import 'app_state.dart';

/// Pure rule-based analysis over the user's current data. No network calls,
/// no external AI — every insight is derived deterministically so it stays
/// free, instant and works offline.
List<Insight> generateInsights(AppState state) {
  final insights = <Insight>[];
  final now = DateTime.now();

  _habitInsights(state, now, insights);
  _journalInsights(state, now, insights);
  _financeInsights(state, now, insights);
  _goalInsights(state, now, insights);

  insights.sort((a, b) => a.priority.compareTo(b.priority));
  return insights;
}

void _habitInsights(AppState state, DateTime now, List<Insight> out) {
  if (state.habits.isEmpty) return;

  if (state.todayCompletedCount == 0 && now.hour >= 18) {
    out.add(const Insight(
      icon: Icons.nightlight_round,
      title: 'Se acaba el día',
      message: 'Todavía no marcas ningún hábito hoy. Un pequeño esfuerzo antes de dormir cuenta.',
      type: InsightType.warning,
      priority: 10,
    ));
  }

  for (final habit in state.habits) {
    if (habit.currentStreak == 0 && habit.longestStreak >= 3) {
      out.add(Insight(
        icon: Icons.local_fire_department_outlined,
        title: 'Racha perdida',
        message: 'Perdiste tu racha de ${habit.longestStreak} días en "${habit.name}". Retómala hoy.',
        type: InsightType.warning,
        priority: 20,
      ));
    }
  }

  final bestStreak = state.habits.isEmpty
      ? 0
      : state.habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  if (bestStreak >= 7) {
    out.add(Insight(
      icon: Icons.emoji_events_rounded,
      title: 'Racha sólida',
      message: 'Llevas $bestStreak días seguidos con al menos un hábito. Sigue así.',
      type: InsightType.success,
      priority: 60,
    ));
  }
}

void _journalInsights(AppState state, DateTime now, List<Insight> out) {
  if (state.journalEntries.isEmpty) return;

  final lastEntry = state.journalEntries.first;
  final daysSince = now.difference(lastEntry.date).inDays;
  if (daysSince >= 3) {
    out.add(Insight(
      icon: Icons.edit_note_rounded,
      title: 'Diario abandonado',
      message: 'No escribes en tu diario hace $daysSince días. Registrar cómo te sientes ayuda a notar patrones.',
      type: InsightType.info,
      priority: 30,
    ));
  }

  if (state.journalEntries.length >= 6) {
    final recent = state.journalEntries.take(3).map((e) => e.mood.index).toList();
    final previous = state.journalEntries.skip(3).take(3).map((e) => e.mood.index).toList();
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final previousAvg = previous.reduce((a, b) => a + b) / previous.length;
    // Mood enum is ordered great..awful, so a higher index average means worse mood.
    if (recentAvg - previousAvg >= 1) {
      out.add(const Insight(
        icon: Icons.trending_down_rounded,
        title: 'Tu ánimo bajó',
        message: 'Tus últimas entradas muestran un ánimo más bajo que la semana anterior. Considera bajar el ritmo hoy.',
        type: InsightType.warning,
        priority: 15,
      ));
    } else if (previousAvg - recentAvg >= 1) {
      out.add(const Insight(
        icon: Icons.trending_up_rounded,
        title: 'Tu ánimo mejoró',
        message: 'Tus últimas entradas muestran mejor ánimo que antes. Lo que estás haciendo funciona.',
        type: InsightType.success,
        priority: 65,
      ));
    }
  }
}

void _financeInsights(AppState state, DateTime now, List<Insight> out) {
  if (state.transactions.isNotEmpty) {
    final last = state.lastTransactionDate;
    if (last != null) {
      final daysSince = now.difference(last).inDays;
      if (daysSince >= 3) {
        out.add(Insight(
          icon: Icons.receipt_long_rounded,
          title: 'Gastos sin registrar',
          message: 'No registras movimientos hace $daysSince días. Anota tus gastos para no perder el control.',
          type: InsightType.info,
          priority: 35,
        ));
      }
    }

    if (state.monthNet < 0) {
      out.add(Insight(
        icon: Icons.trending_down_rounded,
        title: 'Balance negativo',
        message: 'Este mes gastaste \$${state.monthExpense.toStringAsFixed(0)} y solo ingresaste \$${state.monthIncome.toStringAsFixed(0)}.',
        type: InsightType.warning,
        priority: 5,
      ));
    }
  }

  for (final budget in state.budgets) {
    final spent = state.spentThisMonthFor(budget.categoryId);
    if (budget.monthlyLimit <= 0) continue;
    final ratio = spent / budget.monthlyLimit;
    final label = state.categoryById(budget.categoryId).label;
    if (ratio >= 1) {
      out.add(Insight(
        icon: Icons.error_outline_rounded,
        title: 'Presupuesto superado',
        message: 'Superaste tu presupuesto de $label por \$${(spent - budget.monthlyLimit).toStringAsFixed(0)}.',
        type: InsightType.warning,
        priority: 8,
      ));
    } else if (ratio >= 0.9) {
      out.add(Insight(
        icon: Icons.warning_amber_rounded,
        title: 'Cerca del límite',
        message: 'Vas en ${(ratio * 100).round()}% de tu presupuesto de $label este mes.',
        type: InsightType.warning,
        priority: 25,
      ));
    }
  }

  final nonEssentialTotal = state.nonEssentialWeekTotal;
  if (nonEssentialTotal > 0) {
    final byCategory = state.nonEssentialWeekByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = byCategory.first;
    final label = state.categoryById(top.key).label;
    out.add(Insight(
      icon: Icons.local_fire_department_outlined,
      title: 'Gasto no esencial de la semana',
      message:
          'Esta semana llevas \$${nonEssentialTotal.toStringAsFixed(0)} en gastos que no son de primera necesidad — la mayoría en $label (\$${top.value.toStringAsFixed(0)}).',
      type: InsightType.info,
      priority: 40,
    ));
  }
}

void _goalInsights(AppState state, DateTime now, List<Insight> out) {
  for (final goal in state.goals) {
    if (state.effectiveDone(goal) || goal.targetDate == null) continue;
    final progress = state.effectiveProgress(goal);
    final daysLeft = goal.targetDate!.difference(now).inDays;
    if (daysLeft <= 7 && daysLeft >= 0 && progress < 0.8) {
      out.add(Insight(
        icon: Icons.flag_circle_rounded,
        title: 'Meta próxima a vencer',
        message: '"${goal.title}" vence en $daysLeft días y va en ${(progress * 100).round()}%.',
        type: InsightType.warning,
        priority: 12,
      ));
    } else if (daysLeft < 0) {
      out.add(Insight(
        icon: Icons.event_busy_rounded,
        title: 'Meta vencida',
        message: '"${goal.title}" pasó su fecha objetivo con ${(progress * 100).round()}% de progreso.',
        type: InsightType.warning,
        priority: 18,
      ));
    }
  }
}

/// A short, friendly fallback when there is nothing urgent to flag.
const Insight allGoodInsight = Insight(
  icon: Icons.check_circle_outline_rounded,
  title: 'Todo en orden',
  message: 'No hay alertas por ahora. Sigue registrando tus hábitos, ánimo y gastos para mejores recomendaciones.',
  type: InsightType.success,
  priority: 100,
);
