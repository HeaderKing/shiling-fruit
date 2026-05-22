import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/fruit_card.dart';
import 'fruit_detail_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: favs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              emoji: '💝',
              title: '还没有收藏',
              subtitle: '在水果详情页点 ♡ 把喜欢的水果收藏起来',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final fid = list[i].fruitId;
              final fAsync = ref.watch(fruitProvider(fid));
              return fAsync.when(
                loading: () => const SizedBox(height: 64),
                error: (e, _) => ListTile(title: Text('错误: $e')),
                data: (f) {
                  if (f == null) return const SizedBox.shrink();
                  return FruitCard(
                    fruit: f,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FruitDetailPage(fruitId: f.id),
                    )),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
