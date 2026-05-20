import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../providers.dart';
import '../widgets/fruit_card.dart';
import 'calendar_page.dart';
import 'city_picker_page.dart';
import 'favorites_page.dart';
import 'fruit_detail_page.dart';
import 'fruit_index_page.dart';
import 'settings_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);
    final month = ref.watch(monthProvider);
    final period = ref.watch(periodProvider);
    final recs = ref.watch(currentRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: city.when(
          loading: () => const Text('加载中…'),
          error: (e, _) => Text('错误: $e'),
          data: (c) => InkWell(
            onTap: () => _pickCity(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c?.name ?? '选择城市'),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: '月历',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const CalendarPage(),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.apps),
            tooltip: '全部水果',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const FruitIndexPage(),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: '收藏',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const FavoritesPage(),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '设置',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SettingsPage(),
            )),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              '$month 月 $period · 今日推荐',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: recs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('错误: $e')),
              data: (list) => _RecommendationList(items: list),
            ),
          ),
        ],
      ),
    );
  }

  void _pickCity(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const CityPickerPage(),
    ));
  }
}

class _RecommendationList extends ConsumerWidget {
  const _RecommendationList({required this.items});
  final List<Recommendation> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(child: Text('当前时段无推荐数据'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final r = items[index];
        final fruitAsync = ref.watch(fruitProvider(r.fruitId));
        return fruitAsync.when(
          loading: () => const SizedBox(height: 64),
          error: (e, _) => ListTile(title: Text('错误: $e')),
          data: (f) {
            if (f == null) return const SizedBox.shrink();
            return FruitCard(
              fruit: f,
              score: r.score,
              locality: r.locality,
              reason: r.reason,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FruitDetailPage(fruitId: f.id),
              )),
            );
          },
        );
      },
    );
  }
}
