import 'package:flutter/material.dart';

import '../../services/solar_term.dart';
import '../theme/season.dart';

class SeasonHeader extends StatelessWidget {
  const SeasonHeader({
    super.key,
    required this.month,
    required this.period,
    required this.cityName,
  });

  final int month;
  final String period;
  final String cityName;

  @override
  Widget build(BuildContext context) {
    final palette = SeasonPalette.of(month);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final term = SolarTerm.current(DateTime.now());
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  palette.gradient[1].withValues(alpha: 0.4),
                  palette.gradient[0].withValues(alpha: 0.3),
                ]
              : palette.gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$month 月',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF3E2723),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: palette.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            period,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$cityName · 今日时令',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                palette.icon,
                style: const TextStyle(fontSize: 48, height: 1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(term.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  term.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    term.daysToNext <= 0
                        ? '即将进入 ${term.next}'
                        : '距「${term.next}」还有 ${term.daysToNext} 天',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
