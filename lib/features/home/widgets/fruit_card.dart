import 'package:flutter/material.dart';

import '../../../data/database.dart';
import 'fruit_thumb.dart';

class FruitCard extends StatelessWidget {
  const FruitCard({
    super.key,
    required this.fruit,
    this.score,
    this.locality,
    this.reason,
    this.onTap,
  });

  final Fruit fruit;
  final int? score;
  final String? locality;
  final String? reason;
  final VoidCallback? onTap;

  Color _localityColor(String? l) {
    switch (l) {
      case '本地特产':
        return const Color(0xFF2E7D32);
      case '邻近产区':
        return const Color(0xFFEF6C00);
      case '外来':
        return const Color(0xFF546E7A);
      default:
        return Colors.grey;
    }
  }

  ({String label, Color color, IconData icon}) _scoreInfo(int s) {
    if (s >= 85) {
      return (label: '强荐', color: const Color(0xFFD84315), icon: Icons.star_rounded);
    }
    if (s >= 70) {
      return (label: '推荐', color: const Color(0xFFEF6C00), icon: Icons.thumb_up_rounded);
    }
    return (label: '可吃', color: const Color(0xFF607D8B), icon: Icons.check_circle_outline_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: scheme.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FruitThumb(
                  colorHex: fruit.colorHex,
                  name: fruit.name,
                  emoji: fruit.emoji,
                  size: 58,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fruit.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (score != null) _buildScoreBadge(_scoreInfo(score!)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (locality != null) _buildLocalityChip(locality!),
                          if (locality != null) const SizedBox(width: 6),
                          if (fruit.peakSeason.isNotEmpty)
                            Flexible(
                              child: Text(
                                fruit.peakSeason,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      if (reason != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          reason!,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 13,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(({String label, Color color, IconData icon}) info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 13, color: info.color),
          const SizedBox(width: 3),
          Text(
            info.label,
            style: TextStyle(
              color: info.color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalityChip(String l) {
    final c = _localityColor(l);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        l,
        style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}