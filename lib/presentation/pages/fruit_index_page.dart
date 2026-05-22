import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/fruit_thumb.dart';
import 'fruit_detail_page.dart';

class FruitIndexPage extends ConsumerWidget {
  const FruitIndexPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fruits = ref.watch(allFruitsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('全部水果')),
      body: fruits.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
        data: (list) {
          final sorted = [...list]..sort((a, b) => a.name.compareTo(b.name));
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: sorted.length,
            itemBuilder: (context, i) {
              final f = sorted[i];
              return InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FruitDetailPage(fruitId: f.id),
                )),
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: [
                    FruitThumb(
                      colorHex: f.colorHex,
                      name: f.name,
                      emoji: f.emoji,
                      size: 64,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      f.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
