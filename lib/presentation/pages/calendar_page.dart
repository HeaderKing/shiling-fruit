import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../services/solar_term.dart';
import '../providers.dart';
import '../theme/season.dart';
import '../widgets/empty_state.dart';
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
  late PageController _page;

  @override
  void initState() {
    super.initState();
    final initial = DateTime.now().month - 1;
    _tab = TabController(length: 12, vsync: this, initialIndex: initial);
    _page = PageController(initialPage: initial);
    _tab.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tab.indexIsChanging || _tab.index != _page.page?.round()) {
      _page.animateToPage(
        _tab.index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _tab.removeListener(_onTabChanged);
    _tab.dispose();
    _page.dispose();
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
          data: (c) => Text('${c?.name ?? ''} · 全年月历'),
        ),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          dividerHeight: 0,
          tabAlignment: TabAlignment.start,
          tabs: List.generate(12, (i) {
            final m = i + 1;
            final p = SeasonPalette.of(m);
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(p.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('$m月'),
                ],
              ),
            );
          }),
        ),
      ),
      body: PageView.builder(
        controller: _page,
        scrollDirection: Axis.vertical,
        itemCount: 12,
        onPageChanged: (i) {
          if (_tab.index != i) {
            _tab.animateTo(i, duration: const Duration(milliseconds: 200));
          }
        },
        itemBuilder: (_, i) => _MonthView(month: i + 1),
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
    final palette = SeasonPalette.of(month);
    return recs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('错误: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            emoji: '🌫️',
            title: '本月暂无推荐',
          );
        }
        final byPeriod = <String, List<Recommendation>>{
          '上旬': [],
          '中旬': [],
          '下旬': [],
        };
        for (final r in list) {
          byPeriod[r.period]?.add(r);
        }
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: [
            _SolarTermBar(month: month, palette: palette),
            for (final period in const ['上旬', '中旬', '下旬']) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: palette.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${byPeriod[period]!.length} 种',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (byPeriod[period]!.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Text('暂无', style: TextStyle(color: Colors.grey)),
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
      loading: () => const SizedBox(height: 86),
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

class _SolarTermBar extends StatelessWidget {
  const _SolarTermBar({required this.month, required this.palette});
  final int month;
  final SeasonPalette palette;

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final terms = SolarTerm.ofMonth(year, month);
    if (terms.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          for (final t in terms)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: palette.primary.withValues(alpha: 0.4), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '${t.name} · ${t.date.month}/${t.date.day}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.primary,
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
