import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database.dart';
import '../../../presentation/providers.dart';
import '../../../services/location_service.dart';
import '../../../shared/theme/season.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/home_providers.dart';
import '../widgets/fruit_card.dart';
import '../widgets/season_header.dart';
import 'city_picker_page.dart';
import 'fruit_detail_page.dart';
import 'fruit_index_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _overridePeriod;

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    final month = ref.watch(monthProvider);
    final autoPeriod = ref.watch(periodProvider);
    final period = _overridePeriod ?? autoPeriod;
    final palette = SeasonPalette.of(month);

    return Scaffold(
      appBar: AppBar(
        title: city.when(
          loading: () => const Text('加载中…'),
          error: (e, _) => Text('错误: $e'),
          data: (c) => InkWell(
            onTap: () => _pickCity(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 18, color: palette.primary),
                  const SizedBox(width: 4),
                  Text(c?.name ?? '选择城市',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: '使用当前定位',
            onPressed: () => _locate(context),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: '全部水果',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const FruitIndexPage(),
            )),
          ),
        ],
      ),
      body: city.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
        data: (c) => Column(
          children: [
            SeasonHeader(
              month: month,
              period: period,
              cityName: c?.name ?? '—',
            ),
            _PeriodSelector(
              current: period,
              auto: autoPeriod,
              onChanged: (p) => setState(() => _overridePeriod = p),
            ),
            const SizedBox(height: 4),
            Expanded(child: _Recommendations(month: month, period: period)),
          ],
        ),
      ),
    );
  }

  void _pickCity(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const CityPickerPage(),
    ));
  }

  Future<void> _locate(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(
      content: Text('正在定位…'),
      duration: Duration(seconds: 2),
    ));
    final cityId = await ref.read(locationServiceProvider).currentCityId();
    if (!mounted) return;
    if (cityId == null) {
      messenger.showSnackBar(const SnackBar(
        content: Text('定位失败：请检查权限或开启位置服务'),
      ));
      return;
    }
    ref.read(selectedCityIdProvider.notifier).state = cityId;
    await ref.read(dbProvider).setPref('last_city', cityId);
    if (!mounted) return;
    final city = await ref.read(dbProvider).findCity(cityId);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text('已定位到：${city?.name ?? cityId}'),
    ));
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.current,
    required this.auto,
    required this.onChanged,
  });

  final String current;
  final String auto;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<String>(
        segments: [
          for (final p in const ['上旬', '中旬', '下旬'])
            ButtonSegment<String>(
              value: p,
              label: Text('${p == auto ? "● " : ""}$p'),
            ),
        ],
        selected: {current},
        showSelectedIcon: false,
        onSelectionChanged: (s) => onChanged(s.first),
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class _Recommendations extends ConsumerWidget {
  const _Recommendations({required this.month, required this.period});
  final int month;
  final String period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityId = ref.watch(selectedCityIdProvider);
    final recs = ref.watch(_recsProvider(_ReqKey(cityId, month, period)));
    return recs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('错误: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            emoji: '🥺',
            title: '当前时段没有推荐',
            subtitle: '试试切换其他旬段或城市',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final r = list[index];
            final fAsync = ref.watch(fruitProvider(r.fruitId));
            return fAsync.when(
              loading: () => const SizedBox(height: 86),
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
      },
    );
  }
}

class _ReqKey {
  const _ReqKey(this.cityId, this.month, this.period);
  final String cityId;
  final int month;
  final String period;

  @override
  bool operator ==(Object other) =>
      other is _ReqKey &&
      other.cityId == cityId &&
      other.month == month &&
      other.period == period;

  @override
  int get hashCode => Object.hash(cityId, month, period);
}

final _recsProvider =
    FutureProvider.family<List<Recommendation>, _ReqKey>((ref, key) {
  return ref
      .watch(dbProvider)
      .recommendationsFor(key.cityId, key.month, key.period);
});