import 'package:flutter/material.dart';

enum InsightType { warning, success, info }

class Insight {
  final IconData icon;
  final String title;
  final String message;
  final InsightType type;
  final int priority; // lower = more urgent, shown first

  const Insight({
    required this.icon,
    required this.title,
    required this.message,
    required this.type,
    this.priority = 50,
  });
}
