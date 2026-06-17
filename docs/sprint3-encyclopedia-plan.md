# Sprint 3：百科升级/搜索 — 实施计划

> 目标：将水果详情页从"数据展示"升级为"百科知识门户"，集成搜索能力。
> 产出：可独立发布的 v0.4.0 版本，含百科 Tab、升级的水果详情页、全文搜索、时令地图。

---

## 目录

1. [功能总览](#1-功能总览)
2. [后端：搜索服务与百科 API](#2-后端搜索服务与百科-api)
3. [后端：MeiliSearch 集成](#3-后端-meilisearch-集成)
4. [后端：时令地图数据服务](#4-后端时令地图数据服务)
5. [Flutter：百科 Tab 首页](#5-flutter百科-tab-首页)
6. [Flutter：水果详情页大升级](#6-flutter水果详情页大升级)
7. [Flutter：如何挑选专区](#7-flutter如何挑选专区)
8. [Flutter：用户晒图墙](#8-flutter用户晒图墙)
9. [Flutter：品种对比](#9-flutter品种对比)
10. [Flutter：时令地图](#10-flutter时令地图)
11. [Flutter：全局搜索](#11-flutter全局搜索)
12. [Flutter：百科离线缓存](#12-flutter百科离线缓存)
13. [验证与检查清单](#13-验证与检查清单)

---

## 1. 功能总览

```
Tab 2: 水果百科

┌───────────────────────────────────────────────┐
│  [🔍 搜索水果、品种、产地…]                    │
│                                                │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ │
│  │🍎 按季节│ │🗺️ 按产地│ │📂 按种类│ │🔥 热门 │ │
│  └────────┘ └────────┘ └────────┘ └────────┘ │
│                                                │
│  🗺️ [时令地图预览] → 点击进入全国地图           │
│                                                │
│  🔥 本周热门水果排行                            │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐         │
│  │🍉 │ │🍑 │ │🥭 │ │🍇 │ │🥝 │         │
│  └────┘ └────┘ └────┘ └────┘ └────┘         │
└───────────────────────────────────────────────┘

水果详情页（升级后）：

┌───────────────────────────────────────────────┐
│ 🍑 水蜜桃                                       │
│                                                │
│ ┌─ 基础信息 ───────────────────────────────┐  │
│ │ 甜度 11-14 · 热量 46kcal · 性味 温       │  │
│ │ 别名：玉露桃  · Peak: 6-8月              │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ ┌─ 如何挑选 ⭐⭐⭐⭐☆ ──────────────────┐       │
│ │ ✅ 闻：桃香浓郁 = 熟度恰好           │       │
│ │ ✅ 看：底部发白 = 熟了                │       │
│ │ ✅ 按：回弹 = 可即食                 │       │
│ │ ❌ 软塌塌 = 过熟                     │       │
│ │ [对比图]  [教学视频]                 │       │
│ └──────────────────────────────────────────┘  │
│                                                │
│ ┌─ 品种图谱 ──────────────────────────────┐  │
│ │ 🥇 湖景桃 · 7月 · 极甜 · 无锡产       │  │
│ │ 🥈 白凤桃 · 6月 · 清甜 · 无锡产       │  │
│ │ 🥉 蟠桃   · 8月 · 扁形 · 新疆产       │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ ┌─ 用户晒图墙 ────────────────────────────┐  │
│ │ [📷][📷][📷][📷][📷]                   │  │
│ │ [📷][📷][📷][📷][📷]                   │  │
│ │ 共 246 张 · 我也要晒 →                  │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ ┌─ 精选攻略 ──────────────────────────────┐  │
│ │ "水蜜桃的 3 种神仙吃法" · 👍 423       │  │
│ │ "无锡人教你挑湖景桃" · 👍 287          │  │
│ └──────────────────────────────────────────┘  │
└───────────────────────────────────────────────┘
```

---

## 2. 后端搜索服务与百科 API

### 2.1 新增 API

```
GET /api/fruits
    ?category=berry|stone|citrus|tropical|melon|pome
    &season=spring|summer|autumn|winter
    &origin=华东|华南|...
    &sort=name|season|popularity

GET /api/fruits/:id              百科详情（含扩展字段）
GET /api/fruits/:id/varieties    品种列表
GET /api/fruits/:id/posts        关联 UGC 帖子
GET /api/fruits/:id/hot-posts    精选攻略（点赞最高）

GET /api/search
    ?q=荔枝
    &type=fruit|post|user
    &page=1

GET /api/seasonal-map
    ?month=6&period=上旬
```

### 2.2 百科数据融合（离线 + 在线）

```dart
// lib/data/repositories/fruit_repository.dart
class FruitRepository {
  /// 获取百科详情：本地基础 + 在线扩展 + 社区内容
  Future<FruitEncyclopedia> getEncyclopedia(String fruitId) async {
    // 1. 离线基础数据（保证无网可用）
    final localFruit = await _db.findFruit(fruitId);
    if (localFruit == null) throw Exception('水果不存在');

    // 2. 在线扩展信息（挑选技巧等）
    FruitExtModel? ext;
    try {
      final result = await _api.fetchOne<Map<String, dynamic>>(
        'fruits',
        select: 'picking_tips,storage_tips,best_eat_method,variety_json,grade_std',
        filters: {'id': fruitId},
      );
      if (result != null) ext = FruitExtModel.fromJson(result);
    } catch (_) {}

    // 3. 社区精选攻略
    List<PostModel> hotPosts = [];
    try {
      final list = await _api.fetchList<Map<String, dynamic>>(
        'posts',
        filters: {'fruit_id': fruitId, 'status': 'approved', 'type': 'guide'},
        order: 'like_count desc',
        limit: 5,
      );
      hotPosts = list.map((j) => PostModel.fromJson(j)).toList();
    } catch (_) {}

    return FruitEncyclopedia(
      basic: localFruit,
      pickingTips: ext?.pickingTips ?? '',
      storageTips: ext?.storageTips ?? '',
      bestEatMethod: ext?.bestEatMethod ?? '',
      varieties: VarietyModel.listFromJson(ext?.varietyJson ?? []),
      gradeStd: ext?.gradeStd ?? '',
      hotPosts: hotPosts,
    );
  }
}
```

### 2.3 水果分类

```dart
enum FruitCategory {
  berry('浆果', ['草莓', '蓝莓', '桑葚']),
  stone('核果', ['桃', '李', '杏', '樱桃', '杨梅']),
  citrus('柑橘', ['橙子', '橘子', '柚子', '柠檬']),
  tropical('热带', ['芒果', '荔枝', '龙眼', '榴莲', '火龙果']),
  melon('瓜类', ['西瓜', '哈密瓜']),
  pome('仁果', ['苹果', '梨', '山楂']),
  other('其他', ['葡萄', '猕猴桃', '柿子', '石榴']);

  final String label;
  final List<String> examples;
  const FruitCategory(this.label, this.examples);
}
```

---

## 3. 后端 MeiliSearch 集成

### 3.1 部署

```bash
docker run -d \
  --name meilisearch \
  -p 7700:7700 \
  -e MEILI_MASTER_KEY='your-key' \
  -v $(pwd)/meili_data:/meili_data \
  getmeili/meilisearch:v1.8
```

### 3.2 数据同步

```typescript
// Supabase Edge Function: sync-search
// 定期同步水果和帖子数据到 MeiliSearch
import { MeiliSearch } from 'meilisearch'

const meili = new MeiliSearch({
  host: Deno.env.get('MEILI_HOST')!,
  apiKey: Deno.env.get('MEILI_API_KEY')!,
})

async function syncFruits(supabase: any) {
  const { data: fruits } = await supabase.from('fruits').select('*')
  await meili.index('fruits').addDocuments(
    fruits.map((f: any) => ({
      id: f.id,
      name: f.name,
      english_name: f.english_name,
      alias: JSON.parse(f.alias_json || '[]'),
      variety_names: JSON.parse(f.variety_json || '[]').map((v: any) => v.name),
      origins: JSON.parse(f.origins_json || '[]'),
      peak_season: f.peak_season,
    }))
  )
}
```

### 3.3 Flutter 端搜索调用

```dart
// lib/features/search/providers/search_providers.dart

final searchResultsProvider =
    FutureProvider.family<SearchResults, SearchQuery>((ref, query) async {
  // 1. 尝试在线搜索
  try {
    final supabase = Supabase.instance.client;
    final result = await supabase.functions.invoke('search', body: {
      'query': query.q,
      'type': query.type,
      'page': query.page,
    });
    return SearchResults.fromJson(result.data);
  } catch (_) {
    // 2. 离线降级：本地 ILIKE 搜索
    return _localSearch(ref, query);
  }
});

Future<SearchResults> _localSearch(Ref ref, SearchQuery query) async {
  final db = ref.read(dbProvider);
  final all = await db.allFruits();
  final q = query.q.toLowerCase();
  final matched = all.where((f) =>
    f.name.contains(q) || f.englishName.contains(q) || f.id.contains(q)
  ).toList();
  return SearchResults(fruits: matched, posts: []);
}
```

---

## 4. 后端时令地图数据服务

时令地图数据直接由本地 `recommendations.json` 离线包计算生成。

```dart
// lib/data/repositories/seasonal_map_repository.dart
class SeasonalMapRepository {
  SeasonalMapRepository(this._db);
  final AppDatabase _db;

  Future<List<SeasonalMapEntry>> getMapData(int month, String period) async {
    final cities = await _db.allCities();
    final entries = <SeasonalMapEntry>[];

    for (final city in cities) {
      final recs = await _db.recommendationsFor(city.id, month, period);
      if (recs.isEmpty) continue;

      final avgScore = recs.map((r) => r.score).reduce((a, b) => a + b) / recs.length;
      final localCount = recs.where((r) => r.locality == '本地特产').length;
      final top = recs.first;

      entries.add(SeasonalMapEntry(
        cityId: city.id,
        cityName: city.name,
        region: city.region,
        lat: city.lat, lng: city.lng,
        intensity: avgScore,
        localSpecialty: localCount,
        topFruit: top.fruitId,
        topScore: top.score,
      ));
    }
    return entries;
  }
}
```

---

## 5. Flutter：百科 Tab 首页

### 5.1 百科首页

```dart
// lib/features/encyclopedia/pages/encyclopedia_page.dart
class EncyclopediaPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends ConsumerState<EncyclopediaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('水果百科'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded),
            tooltip: '品种对比',
            onPressed: () => _openCompare(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SearchBar(onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchPage()),
          )),
          const SizedBox(height: 16),
          _CategoryGrid(
            categories: FruitCategory.values,
            onTap: (cat) => _openCategory(context, cat),
          ),
          const SizedBox(height: 24),
          _SeasonalHotSection(onFruitTap: (fid) => _openDetail(context, fid)),
          const SizedBox(height: 24),
          _SeasonalMapPreview(onTap: () => _openMap(context)),
          const SizedBox(height: 24),
          _FruitRanking(title: '🔥 本周热门', onFruitTap: (fid) => _openDetail(context, fid)),
        ],
      ),
    );
  }
}
```

### 5.2 分类网格

```dart
// 2x3 网格展示 6 大类
// 每格：emoji + 类名 + 示例水果
// 点击进入分类列表页
```

---

## 6. Flutter：水果详情页大升级

### 6.1 新详情页结构

```dart
// lib/features/encyclopedia/pages/fruit_encyclopedia_page.dart
class FruitEncyclopediaPage extends ConsumerStatefulWidget {
  const FruitEncyclopediaPage({super.key, required this.fruitId});
  final String fruitId;
}

class _FruitEncyclopediaPageState extends ConsumerState<FruitEncyclopediaPage> {
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(fruitEncyclopediaProvider(widget.fruitId));

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (data) {
          if (data == null) return const ErrorView(message: '未找到');
          return CustomScrollView(slivers: [
            // SliverAppBar（复用现有）
            _EncyclopediaHeader(fruit: data.basic),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([
                // 区块 1：基础信息
                _BasicInfoSection(fruit: data.basic),
                const SizedBox(height: 16),

                // 区块 2：如何挑选
                if (data.pickingTips.isNotEmpty)
                  _PickingTipsSection(tips: data.pickingTips),
                const SizedBox(height: 16),

                // 区块 3：品种图谱
                if (data.varieties.isNotEmpty)
                  _VarietySection(varieties: data.varieties),
                const SizedBox(height: 16),

                // 区块 4：存储与食用
                if (data.storageTips.isNotEmpty || data.bestEatMethod.isNotEmpty)
                  _StorageAndEatSection(
                    storage: data.storageTips,
                    eatMethod: data.bestEatMethod,
                  ),
                const SizedBox(height: 16),

                // 区块 5：用户晒图墙
                _UserGallerySection(fruitId: widget.fruitId),
                const SizedBox(height: 16),

                // 区块 6：精选攻略
                if (data.hotPosts.isNotEmpty)
                  _HotPostsSection(posts: data.hotPosts),
                const SizedBox(height: 32),
              ])),
            ),
          ]);
        },
      ),
    );
  }
}
```

### 6.2 基础信息区块

```dart
class _BasicInfoSection extends StatelessWidget {
  // 展示：
  // - 别名标签
  // - 甜度、热量、性味
  // - 旺季描述
  // - 主产地
  // - 参考批发价（复用现有 Price 数据）
}
```

---

## 7. Flutter：如何挑选专区

### 7.1 Markdown 渲染

```dart
// lib/features/encyclopedia/widgets/picking_tips_section.dart
import 'package:flutter_markdown/flutter_markdown.dart';

class _PickingTipsSection extends StatelessWidget {
  const _PickingTipsSection({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🔍', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('如何挑选', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            _RatingBadge(score: 4.2, count: 156),
          ]),
          const SizedBox(height: 12),
          MarkdownBody(
            data: tips,
            styleSheet: MarkdownStyleSheet(
              h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              p: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.thumb_up_outlined, size: 16),
              label: const Text('有用'),
              onPressed: () => _markHelpful(context),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.edit_note_rounded, size: 16),
              label: const Text('我也来补充'),
              onPressed: () => _openSupplement(context),
            ),
          ]),
        ],
      ),
    );
  }
}

// 依赖：flutter_markdown: ^0.7.0
```

### 7.2 内容来源

```
内容优先级：
1. 官方录入（fruits.json 的 picking_tips 字段）
2. 用户投票最高的攻略帖
3. 管理员推荐内容

渲染能力：
- Markdown 标准语法
- ✅ ❌ ⚠️ 💡 emoji 标识
- 内嵌图片（对比图、示意图）
```

---

## 8. Flutter：用户晒图墙

### 8.1 晒图墙

```dart
// lib/features/encyclopedia/widgets/user_gallery_section.dart
class _UserGallerySection extends ConsumerWidget {
  const _UserGallerySection({required this.fruitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(fruitGalleryProvider(fruitId));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('📷', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text('用户晒图', style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        TextButton.icon(
          icon: const Icon(Icons.add_a_photo_rounded, size: 16),
          label: const Text('我也要晒'),
          onPressed: () => _openNewPost(context),
        ),
      ]),
      const SizedBox(height: 8),
      postsAsync.when(
        loading: () => const _GalleryShimmer(),
        error: (_, __) => const SizedBox.shrink(),
        data: (posts) {
          if (posts.isEmpty) return _EmptyGallery(onPost: () => _openNewPost(context));
          final images = posts.expand((p) => p.images).take(9).toList();
          return Column(children: [
            SizedBox(
              height: 240,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4,
                ),
                itemCount: images.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _openGallery(context, images),
                  child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover),
                ),
              ),
            ),
            TextButton(
              onPressed: () => _openAllGallery(context),
              child: Text('查看全部 ${posts.length} 张晒图 →'),
            ),
          ]);
        },
      ),
    ]);
  }
}
```

### 8.2 大图浏览

使用 `photo_view` 库实现，支持双指缩放、左右滑动切换。

---

## 9. Flutter：品种对比

### 9.1 对比选择器

```dart
// lib/features/encyclopedia/pages/fruit_compare_page.dart
// 用户选择 2-3 个水果 → 并排对比

// ┌──────────┬──────────┐
// │ 🍑 水蜜桃  │ 🍑 蟠桃  │
// │ 甜度 11-14 │ 甜度 13-16│
// │ 46kcal    │ 44kcal   │
// │ 旺季 6-8月 │ 旺季 7-9月│
// │ 无锡产    │ 新疆产   │
// └──────────┴──────────┘
```

### 9.2 对比逻辑

```dart
class FruitCompare {
  final List<Fruit> fruits;
  final Map<String, List<CompareRow>> rows;

  static FruitCompare build(List<FruitEncyclopedia> items) {
    return FruitCompare(
      fruits: items.map((f) => f.basic).toList(),
      rows: {
        '甜度 (°Bx)': items.map((f) => CompareRow(value: '${f.basic.brixMin}-${f.basic.brixMax}')).toList(),
        '热量': items.map((f) => CompareRow(value: '${f.basic.calorieKcalPer100g} kcal')).toList(),
        '性味': items.map((f) => CompareRow(value: f.basic.tcmNature)).toList(),
        '旺季': items.map((f) => CompareRow(value: f.basic.peakSeason)).toList(),
      },
    );
  }
}
```

---

## 10. Flutter：时令地图

### 10.1 地图页

```dart
// lib/features/encyclopedia/pages/seasonal_map_page.dart
class SeasonalMapPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SeasonalMapPage> createState() => _SeasonalMapPageState();
}

class _SeasonalMapPageState extends ConsumerState<SeasonalMapPage> {
  int _month = DateTime.now().month;
  String _period = '上旬';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_month}月$_period · 全国时令'),
      ),
      body: Column(children: [
        _MonthSlider(month: _month, onChanged: (m) => setState(() => _month = m)),
        _PeriodSelector(period: _period, onChanged: (p) => setState(() => _period = p)),
        Expanded(child: _MapWidget(month: _month, period: _period)),
        _MapLegend(),
      ]),
    );
  }
}
```

### 10.2 地图组件

```dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class _MapWidget extends ConsumerWidget {
  // 使用 flutter_map（Leaflet 纯 Dart 实现，无高德依赖）
  // 城市 Marker 按推荐强度着色
  // 点击弹窗显示推荐水果

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(seasonalMapProvider(MapMonthKey(month, period)));

    return FlutterMap(
      options: const MapOptions(
        center: LatLng(35.86, 104.19),
        zoom: 4.5, minZoom: 3, maxZoom: 8,
      ),
      children: [
        TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
        data.when(
          data: (entries) => MarkerLayer(
            markers: entries.map((e) => Marker(
              point: LatLng(e.lat, e.lng),
              builder: (_) => _CityMarker(entry: e),
            )).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('地图加载失败')),
        ),
      ],
    );
  }
}
```

---

## 11. Flutter：全局搜索

### 11.1 搜索页

```dart
// lib/features/search/pages/search_page.dart
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _ctrl = TextEditingController();
  String _type = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '搜索水果、品种、产地…',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (q) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: _ctrl.text.isEmpty
          ? _SearchHistory()
          : _SearchResults(query: _ctrl.text, type: _type),
    );
  }
}
```

### 11.2 搜索结果

```dart
class _SearchResults extends ConsumerWidget {
  // 分组展示：
  // ┌─ 水果 ───────────────────────┐
  // │ 🍑 水蜜桃  旺季 6-8月        │
  // │ 🍑 蟠桃    旺季 7-9月        │
  // └──────────────────────────────┘
  // ┌─ 社区帖子 ───────────────────┐
  // │ "水蜜桃购买攻略"            │
  // │ "水蜜桃 3 种神仙吃法"       │
  // └──────────────────────────────┘
}
```

---

## 12. Flutter：百科离线缓存

### 12.1 冷热分离

```dart
// 热数据（前 30 个高频水果）：启动时预加载到内存
// 冷数据（其他）：按需加载，加载后缓存到 SQLite

class EncyclopediaCache {
  static const _hotIds = [
    'watermelon', 'peach', 'mango', 'grape', 'kiwi',
    'strawberry', 'lychee', 'apple', 'orange', 'longan',
    // ... 共 30 个
  ];

  static final Map<String, FruitEncyclopedia> _cache = {};

  static Future<void> preload(FruitRepository repo) async {
    final results = await Future.wait(
      _hotIds.map((id) => repo.getEncyclopedia(id).catchError((_) => null)),
    );
    for (final r in results.whereType<FruitEncyclopedia>()) {
      _cache[r.basic.id] = r;
    }
  }

  static FruitEncyclopedia? get(String id) => _cache[id];
}
```

### 12.2 本地缓存表

```dart
// 新增 Drift 表：百科缓存
class EncyclopediaCacheTable extends Table {
  TextColumn get fruitId => text()();
  TextColumn get pickingTips => text()();
  TextColumn get storageTips => text()();
  TextColumn get bestEatMethod => text()();
  TextColumn get varietyJson => text()();
  TextColumn get gradeStd => text()();
  TextColumn get cachedAt => text()(); // ISO 8601

  @override
  Set<Column> get primaryKey => {fruitId};
}
```

---

## 13. 验证与检查清单

### 13.1 完成检查清单

| # | 任务 | 状态 | 验证方式 |
|---|------|------|----------|
| S3.1 | 百科 Tab 就绪 | ☐ | Tab 可见，分类/热门/地图入口完整 |
| S3.2 | 分类浏览 | ☐ | 6 大类点击展示对应水果列表 |
| S3.3 | 百科详情页升级 | ☐ | 基础+挑选+品种+晒图+攻略完整 |
| S3.4 | 挑选专区 | ☐ | Markdown 正确渲染 |
| S3.5 | 品种图谱 | ☐ | 列表展示品种信息 |
| S3.6 | 用户晒图墙 | ☐ | 瀑布流展示，大图浏览 |
| S3.7 | 精选攻略 | ☐ | 关联帖子列表显示 |
| S3.8 | 品种对比 | ☐ | 2-3 水果并排对比 |
| S3.9 | 时令地图 | ☐ | 中国地图+Marker+月份切换 |
| S3.10 | 全局搜索 | ☐ | 搜索框+结果展示 |
| S3.11 | 离线搜索降级 | ☐ | 无网时本地搜索结果正常 |
| S3.12 | 百科离线缓存 | ☐ | 热门水果离线可查看 |

### 13.2 新增依赖

```yaml
dependencies:
  flutter_markdown: ^0.7.0        # Markdown 渲染
  flutter_map: ^6.1.0             # 地图
  latlong2: ^0.9.0                # 经纬度
  photo_view: ^0.15.0             # 大图浏览
  url_launcher: ^6.2.0            # 打开外部链接
```

### 13.3 Commit 规划

```
feat(encyclopedia): 百科 Tab 及分类浏览
feat(encyclopedia): 水果详情页升级（挑选/品种/存储）
feat(encyclopedia): 用户晒图墙及大图浏览
feat(encyclopedia): 品种对比功能
feat(encyclopedia): 时令地图交互
feat(search): MeiliSearch 全文搜索 + 离线降级
feat(core): 百科缓存管理器
```