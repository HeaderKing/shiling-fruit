import 'package:flutter/material.dart';

import '../../data/database.dart';
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
        return Colors.green;
      case '邻近产区':
        return Colors.orange;
      case '外来':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              FruitThumb(colorHex: fruit.colorHex, name: fruit.name, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fruit.name,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (score != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$score',
                              style: TextStyle(
                                color: Colors.deepOrange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (locality != null)
                      Container(
                        margin: const EdgeInsets.only(top: 2, bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _localityColor(locality).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          locality!,
                          style: TextStyle(
                            color: _localityColor(locality),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (reason != null)
                      Text(
                        reason!,
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
