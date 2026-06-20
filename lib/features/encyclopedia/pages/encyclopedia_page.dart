import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database.dart';
import '../../home/widgets/fruit_thumb.dart';
import 'fruit_encyclopedia_page.dart';
import 'seasonal_map_page.dart';

class EncyclopediaPage extends ConsumerWidget {
  const EncyclopediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fruitsAsync = ref.watch(allFruitsProvider);
    final month = ref.watch(monthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('水果百科'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _openSearch(context),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _SearchBar(onTap: () => _openSearch(context)),
        const SizedBox(height: 20),

        // 时令地图入口卡片
        Card(
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SeasonalMapPage()),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.map_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🗺️ $month 月时令地图',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '查看全国各地当季水果分布',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text('🌿 $month 月时令热点', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        fruitsAsync.when(
          data: (fruits) => SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fruits.length > 8 ? 8 : fruits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _FruitCircle(fruit: fruits[i], onTap: () => _openFruit(context, fruits[i].id)),
            ),
          ),
          loading: () => const SizedBox(height: 110),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        Text('📂 分类浏览', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _CategoryGrid(onTap: (cat) => _openCategory(context, cat)),
        const SizedBox(height: 24),
        Text('🍎 全部水果', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        fruitsAsync.when(
          data: (fruits) {
            final sorted = [...fruits]..sort((a, b) => a.name.compareTo(b.name));
            return _FruitLetterList(fruits: sorted, onTap: (id) => _openFruit(context, id));
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('加载失败'),
        ),
      ]),
    );
  }

  void _openSearch(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => const _SearchPage(),
  ));
}
  void _openFruit(BuildContext context, String fruitId) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FruitEncyclopediaPage(fruitId: fruitId)));
  void _openCategory(BuildContext context, String category) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(appBar: AppBar(title: Text(category)), body: const Center(child: Text('分类浏览页')))));
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text('搜索水果、品种、产地…', style: TextStyle(color: scheme.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }
}

class _FruitCircle extends StatelessWidget {
  const _FruitCircle({required this.fruit, required this.onTap});
  final Fruit fruit;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      FruitThumb(colorHex: fruit.colorHex, name: fruit.name, emoji: fruit.emoji, size: 56),
      const SizedBox(height: 6),
      Text(fruit.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1),
    ]),
  );
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.onTap});
  final Function(String) onTap;
  static const _cats = [
    ('berry', '浆果', '🫐', ['草莓', '蓝莓', '桑葚']),
    ('stone', '核果', '🍑', ['桃', '李', '杏', '樱桃']),
    ('citrus', '柑橘', '🍊', ['橙子', '橘子', '柚子']),
    ('tropical', '热带', '🥭', ['荔枝', '芒果', '榴莲']),
    ('melon', '瓜类', '🍉', ['西瓜', '哈密瓜']),
    ('pome', '仁果', '🍎', ['苹果', '梨']),
  ];

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6),
    itemCount: _cats.length,
    itemBuilder: (_, i) => Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onTap(_cats[i].$1),
        borderRadius: BorderRadius.circular(12),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_cats[i].$3, style: const TextStyle(fontSize: 28)),
          Text(_cats[i].$2, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(_cats[i].$4.join(' · '), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ]),
      ),
    ),
  );
}

class _FruitLetterList extends StatelessWidget {
  const _FruitLetterList({required this.fruits, required this.onTap});
  final List<Fruit> fruits;
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final map = <String, List<Fruit>>{};
    for (final f in fruits) {
      map.putIfAbsent(f.name.isNotEmpty ? f.name[0] : '#', () => []).add(f);
    }
    return Column(children: map.entries.map((e) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 2)),
        Wrap(spacing: 12, runSpacing: 4, children: e.value.map((f) => GestureDetector(
          onTap: () => onTap(f.id),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(f.emoji.isNotEmpty ? f.emoji : '•', style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4), Text(f.name, style: const TextStyle(fontSize: 14)),
          ]),
        )).toList()),
      ],
    )).toList());
  }
}

/// 搜索页（使用 Riverpod 获取水果数据）
class _SearchPage extends ConsumerStatefulWidget {
  const _SearchPage();
  @override
  ConsumerState<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<_SearchPage> {
  final _ctrl = TextEditingController();
  List<Fruit> _results = [];
  bool _searched = false;
  final List<String> _history = ['草莓', '芒果', '西瓜']; // TODO: 从 SharedPreferences 加载

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _search() {
    final q = _ctrl.text.trim().toLowerCase();
    if (q.isEmpty) { setState(() { _results = []; _searched = false; }); return; }
    final fruits = ref.read(allFruitsProvider).valueOrNull ?? [];

    // 保存到搜索历史
    if (!_history.contains(q) && q.length > 1) {
      setState(() {
        _history.insert(0, q);
        if (_history.length > 10) _history.removeLast();
      });
    }

    setState(() {
      _results = fruits.where((f) {
        // 基础字段搜索
        if (f.name.toLowerCase().contains(q)) return true;
        if (f.englishName.toLowerCase().contains(q)) return true;
        if (f.peakSeason.toLowerCase().contains(q)) return true;

        // 搜索产地 (originsJson)
        if (f.originsJson.toLowerCase().contains(q)) return true;

        // 搜索别名 (aliasJson)
        if (f.aliasJson.toLowerCase().contains(q)) return true;

        return false;
      }).toList();

      // 排序: 名称完全匹配 > 名称前缀匹配 > 其他匹配
      _results.sort((a, b) {
        final aExact = a.name.toLowerCase() == q;
        final bExact = b.name.toLowerCase() == q;
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;

        final aStarts = a.name.toLowerCase().startsWith(q);
        final bStarts = b.name.toLowerCase().startsWith(q);
        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;

        return a.name.compareTo(b.name);
      });

      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '搜索水果…', border: InputBorder.none),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: _search),
        ],
      ),
      body: _buildBody(scheme),
    );
  }

  Widget _buildBody(ColorScheme scheme) {
    if (!_searched) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        // 搜索历史
        if (_history.isNotEmpty) ...[
          Row(children: [
            const Text('搜索历史', style: TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _history.clear()),
              child: const Text('清空', style: TextStyle(fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _history.map((keyword) =>
            ActionChip(
              label: Text(keyword),
              onPressed: () {
                _ctrl.text = keyword;
                _search();
              },
            ),
          ).toList()),
          const SizedBox(height: 24),
        ],

        // 热门搜索
        const Text('热门搜索', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: ['🔥 西瓜', '🔥 榴莲', '🔥 车厘子', '🔥 山竹', '🔥 荔枝'].map((keyword) =>
          ActionChip(
            avatar: const Text('🔥', style: TextStyle(fontSize: 12)),
            label: Text(keyword.replaceAll('🔥 ', '')),
            onPressed: () {
              _ctrl.text = keyword.replaceAll('🔥 ', '');
              _search();
            },
          ),
        ).toList()),
      ]);
    }

    if (_results.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('😕', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text('没有找到"${_ctrl.text}"', style: TextStyle(color: scheme.onSurfaceVariant)),
      ]));
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _FruitSearchTile(fruit: _results[i]),
    );
  }
}

/// 水果搜索委托（已废弃，改用 _SearchPage）
class FruitSearchDelegate extends SearchDelegate<String?> {
  FruitSearchDelegate(this._fruits);
  final List<Fruit> _fruits;

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildSearchList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchList(context);

  Widget _buildSearchList(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text('输入水果名称、品种或产地',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ]),
      );
    }

    final q = query.toLowerCase();
    final results = _fruits.where((f) =>
      f.name.toLowerCase().contains(q) ||
      f.englishName.toLowerCase().contains(q) ||
      f.peakSeason.toLowerCase().contains(q) ||
      f.id.contains(q)
    ).toList();

    if (results.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('😕', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text('没有找到 "$query"', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _FruitSearchTile(fruit: results[i]),
    );
  }
}

class _FruitSearchTile extends StatelessWidget {
  const _FruitSearchTile({required this.fruit});
  final Fruit fruit;

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(int.parse(fruit.colorHex.replaceAll('#', 'FF'), radix: 16)).withValues(alpha: 0.2);
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(fruit.emoji.isNotEmpty ? fruit.emoji : fruit.name[0], style: const TextStyle(fontSize: 20)),
      ),
      title: Text(fruit.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${fruit.englishName} · ${fruit.peakSeason}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FruitEncyclopediaPage(fruitId: fruit.id),
        ));
      },
    );
  }
}