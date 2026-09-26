import 'package:flutter/material.dart';

import '../theme.dart';

enum BlockKind { trabajo, gym, negocio, descanso }

extension BlockKindMeta on BlockKind {
  String get label => switch (this) {
        BlockKind.trabajo => 'Trabajo',
        BlockKind.gym => 'Gym',
        BlockKind.negocio => 'Negocio',
        BlockKind.descanso => 'Descanso',
      };

  IconData get icon => switch (this) {
        BlockKind.trabajo => Icons.work_outline_rounded,
        BlockKind.gym => Icons.fitness_center_rounded,
        BlockKind.negocio => Icons.storefront_outlined,
        BlockKind.descanso => Icons.self_improvement_rounded,
      };

  Color get color => switch (this) {
        BlockKind.trabajo => AppColors.textSecondary,
        BlockKind.gym => AppColors.olive,
        BlockKind.negocio => AppColors.rust,
        BlockKind.descanso => AppColors.textMuted,
      };
}

/// One slot of the routine (e.g. "Trabajo 08:00–17:00, lunes a viernes").
/// Times are minutes since midnight so blocks compare cheaply against
/// the clock; `weekdays` uses DateTime.weekday (1 = lunes … 7 = domingo).
class DayBlock {
  final String id;
  String label;
  BlockKind kind;
  int startMinute;
  int endMinute;
  List<int> weekdays;

  DayBlock({
    required this.id,
    required this.label,
    required this.kind,
    required this.startMinute,
    required this.endMinute,
    required this.weekdays,
  });

  bool appliesOn(DateTime day) => weekdays.contains(day.weekday);

  bool containsMinute(int minute) => minute >= startMinute && minute < endMinute;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'kind': kind.name,
        'startMinute': startMinute,
        'endMinute': endMinute,
        'weekdays': weekdays,
      };

  factory DayBlock.fromJson(Map<String, dynamic> json) => DayBlock(
        id: json['id'] as String,
        label: json['label'] as String,
        kind: BlockKind.values.byName(json['kind'] as String),
        startMinute: json['startMinute'] as int,
        endMinute: json['endMinute'] as int,
        weekdays: (json['weekdays'] as List).cast<int>(),
      );
}
