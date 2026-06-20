import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../home/widgets/fruit_thumb.dart';

/// 百科详情页 — 升级版
class FruitEncyclopediaPage extends ConsumerStatefulWidget {
  const FruitEncyclopediaPage({super.key, required this.fruitId});
  final String fruitId;

  @override
  ConsumerState<FruitEncyclopediaPage> createState() => _FruitEncyclopediaPageState();
}

class _FruitEncyclopediaPageState extends ConsumerState<FruitEncyclopediaPage> {
  bool _isFav = false;

  @override
  void initState() { super.initState(); _checkFav(); }

  Future<void> _checkFav() async {
    final fav = await ref.read(dbProvider).isFavorite(widget.fruitId);
    if (mounted) setState(() => _isFav = fav);
  }

  @override
  Widget build(BuildContext context) {
    final fruitAsync = ref.watch(fruitProvider(widget.fruitId));

    return Scaffold(
      body: fruitAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (fruit) {
          if (fruit == null) return const ErrorView(message: '未找到该水果');
          final benefits = _decodeList(fruit.benefitsJson);
          final contra = _decodeList(fruit.contraindicationsJson);
          final origins = _decodeList(fruit.originsJson);
          final varieties = _decodeList(fruit.aliasJson);
          final heroBg = _heroBg(fruit.colorHex);

          return CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 240, pinned: true,
              backgroundColor: heroBg, surfaceTintColor: heroBg,
              actions: [
                IconButton(
                  icon: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: _isFav ? Colors.red.shade400 : null),
                  onPressed: () async {
                    if (_isFav) { await ref.read(dbProvider).removeFavorite(widget.fruitId); }
                    else { await ref.read(dbProvider).addFavorite(widget.fruitId); }
                    _checkFav();
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(fruit.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800)),
                background: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [heroBg.withValues(alpha: 0.4), heroBg],
                  )),
                  alignment: Alignment.center,
                  child: Padding(padding: const EdgeInsets.only(bottom: 36),
                    child: Text(fruit.emoji.isNotEmpty ? fruit.emoji : fruit.name.characters.first,
                        style: const TextStyle(fontSize: 96, height: 1)),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([
                // 基础信息
                _InfoCard(fruit: fruit, origins: origins),
                const SizedBox(height: 16),

                // 挑选技巧
                if (fruit.pickingTips.isNotEmpty) ...[
                  _TipCard(tips: fruit.pickingTips),
                  const SizedBox(height: 16),
                ],

                // 品种
                if (varieties.isNotEmpty) ...[
                  _SectionCard(title: '📋 品种', children: varieties.map((v) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Container(width: 8, height: 8,
                          decoration: const BoxDecoration(color: Color(0xFF66BB6A), shape: BoxShape.circle)),
                      const SizedBox(width: 8), Expanded(child: Text(v, style: const TextStyle(fontSize: 14))),
                    ]),
                  )).toList()),
                  const SizedBox(height: 16),
                ],

                // 营养
                _NutritionCard(fruit: fruit),
                const SizedBox(height: 16),

                // 功效 + 禁忌
                if (benefits.isNotEmpty || contra.isNotEmpty) ...[
                  _HealthCard(benefits: benefits, contraindications: contra),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 32),
              ])),
            ),
          ]);
        },
      ),
    );
  }

  List<String> _decodeList(String json) {
    try { return (jsonDecode(json) as List).cast<String>(); } catch (_) { return []; }
  }

  Color _heroBg(String hex) {
    var h = hex.replaceAll('#', ''); if (h.length == 6) h = 'FF$h';
    final hsl = HSLColor.fromColor(Color(int.parse(h, radix: 16)));
    return hsl.withLightness((hsl.lightness + 0.35).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 0.5).clamp(0.0, 1.0)).toColor();
  }
}

// ---- 子组件 ----

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.fruit, required this.origins});
  final Fruit fruit;
  final List<String> origins;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          FruitThumb(colorHex: fruit.colorHex, name: fruit.name, emoji: fruit.emoji, size: 48),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fruit.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            if (fruit.englishName.isNotEmpty)
              Text(fruit.englishName, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          ])),
        ]),
        const Divider(height: 24),
        _Row('甜度', '${fruit.brixMin.toStringAsFixed(0)}-${fruit.brixMax.toStringAsFixed(0)} °Bx'),
        _Row('热量', '${fruit.calorieKcalPer100g} kcal / 100g'),
        _Row('性味', fruit.tcmNature),
        _Row('旺季', fruit.peakSeason),
        if (origins.isNotEmpty) _Row('主产地', origins.join('、')),
      ]),
    );
  }

  Widget _Row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 64, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
    ]),
  );
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tips});
  final String tips;

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC8E6C9))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🔍', style: TextStyle(fontSize: 20)), const SizedBox(width: 8),
          const Text('如何挑选', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        Text(tips, style: const TextStyle(fontSize: 14, height: 1.6)),
      ]),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10), ...children,
      ]),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.fruit});
  final Fruit fruit;

  Map<String, dynamic> _decodeMap(String json) {
    try { return jsonDecode(json) as Map<String, dynamic>; } catch (_) { return {}; }
  }

  @override
  Widget build(BuildContext context) {
    final vitamins = _decodeMap(fruit.vitaminsJson);
    final minerals = _decodeMap(fruit.mineralsJson);
    if (vitamins.isEmpty && minerals.isEmpty) return const SizedBox.shrink();
    return _SectionCard(title: '🥗 营养（mg / 100g）', children: [
      ...vitamins.entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            SizedBox(width: 80, child: Text('维生素 ${e.key}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
            Text('${e.value}', style: const TextStyle(fontSize: 13)),
          ]))),
      ...minerals.entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            SizedBox(width: 80, child: Text(e.key, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
            Text('${e.value}', style: const TextStyle(fontSize: 13)),
          ]))),
    ]);
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.benefits, required this.contraindications});
  final List<String> benefits;
  final List<String> contraindications;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (benefits.isNotEmpty)
        _SectionCard(title: '✅ 健康功效', children: [
          Wrap(spacing: 6, runSpacing: 6, children: benefits.map((b) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
            child: Text(b, style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w600)),
          )).toList()),
        ]),
      if (contraindications.isNotEmpty) ...[
        const SizedBox(height: 12),
        _SectionCard(title: '⚠️ 禁忌人群', children: [
          Wrap(spacing: 6, runSpacing: 6, children: contraindications.map((c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(20)),
            child: Text(c, style: const TextStyle(color: Color(0xFFC62828), fontSize: 12, fontWeight: FontWeight.w600)),
          )).toList()),
        ]),
      ],
    ]);
  }
}