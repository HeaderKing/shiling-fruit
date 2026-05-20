import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../providers.dart';
import '../widgets/fruit_card.dart';
import 'fruit_detail_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 12,
      vsync: this,
      initialIndex: DateTime.now().month - 1,
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    return Scaffold(
      appBar: AppBar(
        title: city.when(
          loading: () => const Text('月历'),
          error: (e, _) => const Text('月历'),
          data: (c) => Text('${c?.name ?? ''} · 月历'),
        ),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: List.generate(12, (i) => Tab(text: '${i + 1}月')),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: List.generate(12, (i) => _MonthView(month: i + 1)),
      ),
    );
  }
}

class _MonthView extends ConsumerWidget {
  const _MonthView({required this.month});
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recs = ref.watch(monthRecommendationsProvider(month));
    return recs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('错误: $e')),
      data: (list) {
        final byPeriod = <String, List<Recommendation>>{
          '上旬': [],
          '中旬': [],
          '下旬': [],
        };
        for (final r in list) {
          byPeriod[r.period]?.add(r);
        }
        return ListView(
          children: [
            for (final period in ['上旬', '中旬', '下旬']) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text(
                  period,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              if (byPeriod[period]!.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('无数据'),
                ),
              for (final r in byPeriod[period]!) _FruitRow(rec: r),
            ],
          ],
        );
      },
    );
  }
}

class _FruitRow extends ConsumerWidget {
  const _FruitRow({required this.rec});
  final Recommendation rec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(fruitProvider(rec.fruitId));
    return f.when(
      loading: () => const SizedBox(height: 64),
      error: (e, _) => ListTile(title: Text('错误: $e')),
      data: (fruit) {
        if (fruit == null) return const SizedBox.shrink();
        return FruitCard(
          fruit: fruit,
          score: rec.score,
          locality: rec.locality,
          reason: rec.reason,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => FruitDetailPage(fruitId: fruit.id),
          )),
        );
      },
    );
  }
}
