import 'package:flutter/material.dart';

import '../models/insight.dart';
import '../theme.dart';
import 'app_card.dart';

Color _colorFor(InsightType type) {
  switch (type) {
    case InsightType.warning:
      return AppColors.coral;
    case InsightType.success:
      return AppColors.mint;
    case InsightType.info:
      return AppColors.sky;
  }
}

/// The primary, larger banner used to surface the single most urgent
/// insight — this is the closest thing the app has to an "assistant"
/// speaking directly to the user.
class InsightBanner extends StatelessWidget {
  final Insight insight;
  const InsightBanner({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(insight.type);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.16),
            AppColors.surface,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(insight.icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact row used for secondary insights in a feed.
class InsightRow extends StatelessWidget {
  final Insight insight;
  const InsightRow({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(insight.type);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(insight.icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.message,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
