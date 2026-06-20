import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../services/location_service.dart';
import '../../../shared/theme/season.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/home_providers.dart';
import '../widgets/fruit_card.dart';
import '../widgets/season_header.dart';
import 'city_picker_page.dart';
import 'fruit_detail_page.dart';
import 'fruit_index_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityAsync = ref.watch(selectedCityProvider);
    final recs = ref.watch(currentRecommendationsProvider);
    final now = ref.watch(nowProvider);
    final month = ref.watch(monthProvider);
    final period = ref.watch(periodProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Row(
              children: [
                const Text('🍇 时令水果'),
                const Spacer(),
                cityAsync.when(
                  data: (city) => _CitySelector(city: city),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          recs.when(
            data: (list) {
              if (list.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    emoji: '🥺',
                    title: '暂无推荐',
                    subtitle: '这个时段没有特别推荐的水果',
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: SeasonHeader(
                          month: month,
                          period: period,
                          cityName: cityAsync.value?.name ?? '定位中',
                        ),
                      );
                    }
                    final rec = list[i - 1];
                    return FutureBuilder<Fruit?>(
                      future: ref.read(dbProvider).findFruit(rec.fruitId),
                      builder: (context, snapshot) {
                        final fruit = snapshot.data;
                        if (fruit == null) return const SizedBox.shrink();
                        return FruitCard(
                          fruit: fruit,
                          score: rec.score,
                          locality: rec.locality,
                          reason: rec.reason,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FruitDetailPage(fruitId: fruit.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: list.length + 1,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: EmptyState(
                emoji: '😵',
                title: '加载失败',
                subtitle: e.toString(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FruitIndexPage()),
        ),
        icon: const Icon(Icons.view_list_rounded),
        label: const Text('全部水果'),
      ),
    );
  }
}

class _CitySelector extends ConsumerWidget {
  const _CitySelector({required this.city});
  final City? city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CityPickerPage()),
        );
      },
      icon: const Icon(Icons.location_on_outlined, size: 18),
      label: Text(city?.name ?? '选择城市'),
    );
  }
}
