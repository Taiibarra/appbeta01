import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/insight.dart';
import '../theme.dart';
import 'app_card.dart';

Color _colorFor(InsightType type) {
  switch (type) {
    case InsightType.warning:
      return AppColors.danger;
    case InsightType.success:
      return AppColors.olive;
    case InsightType.info:
      return AppColors.rustLight;
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
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(insight.icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title.toUpperCase(),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: const TextStyle(
                      fontSize: 13, height: 1.4, color: AppColors.textSecondary),
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
          Icon(insight.icon, color: color, size: 17),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title.toUpperCase(),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.message,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
