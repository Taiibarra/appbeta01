import 'package:flutter/material.dart';

/// A dedicated pool of money set aside for one purpose (a trip, a new
/// phone, an emergency fund) — separate from every other pool, unlike
/// the shared "Ahorro" category savings goals draw from.
class PiggyBank {
  final String id;
  String name;
  String iconKey;
  Color color;
  double? targetAmount;
  double savedAmount;
  final DateTime createdAt;

  PiggyBank({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.color,
    this.targetAmount,
    this.savedAmount = 0,
    required this.createdAt,
  });

  double get progress {
    if (targetAmount == null || targetAmount == 0) return 0;
    return (savedAmount / targetAmount!).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        'colorValue': color.toARGB32(),
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PiggyBank.fromJson(Map<String, dynamic> json) => PiggyBank(
        id: json['id'] as String,
        name: json['name'] as String,
        iconKey: json['iconKey'] as String,
        color: Color(json['colorValue'] as int),
        targetAmount: json['targetAmount'] != null
            ? (json['targetAmount'] as num).toDouble()
            : null,
        savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
