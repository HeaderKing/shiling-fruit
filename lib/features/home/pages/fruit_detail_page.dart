import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../providers/home_providers.dart';

class FruitDetailPage extends ConsumerStatefulWidget {
  const FruitDetailPage({super.key, required this.fruitId});
  final String fruitId;

  @override
  ConsumerState<FruitDetailPage> createState() => _FruitDetailPageState();
}

class _FruitDetailPageState extends ConsumerState<FruitDetailPage> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _refreshFav();
  }

  Future<void> _refreshFav() async {
    final isFav = await ref.read(dbProvider).isFavorite(widget.fruitId);
    if (mounted) setState(() => _isFav = isFav);
  }

  Future<void> _toggleFav() async {
    final db = ref.read(dbProvider);
    if (_isFav) {
      await db.removeFavorite(widget.fruitId);
    } else {
      await db.addFavorite(widget.fruitId);
    }
    _refreshFav();
  }

  List<String> _decodeStringList(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _decodeMap(String json) {
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Color _heroBg(String hex) {
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final base = Color(int.parse(h, radix: 16));
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness((hsl.lightness + 0.35).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 0.5).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final fAsync = ref.watch(fruitProvider(widget.fruitId));
    final priceAsync = ref.watch(fruitPriceProvider(widget.fruitId));
    return Scaffold(
      body: fAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
        data: (f) {
          if (f == null) return const Center(child: Text('未找到该水果'));
          final aliases = _decodeStringList(f.aliasJson);
          final benefits = _decodeStringList(f.benefitsJson);
          final contra = _decodeStringList(f.contraindicationsJson);
          final origins = _decodeStringList(f.originsJson);
          final vitamins = _decodeMap(f.vitaminsJson);
          final minerals = _decodeMap(f.mineralsJson);
          final heroBg = _heroBg(f.colorHex);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: heroBg,
                surfaceTintColor: heroBg,
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: _isFav ? Colors.red.shade400 : null,
                    ),
                    onPressed: _toggleFav,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    f.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          heroBg.withValues(alpha: 0.4),
                          heroBg,
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 36),
                      child: Text(
                        f.emoji.isNotEmpty
                            ? f.emoji
                            : (f.name.isEmpty ? '?' : f.name.characters.first),
                        style: const TextStyle(fontSize: 96, height: 1),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (aliases.isNotEmpty || f.englishName.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final a in aliases)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(a,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          if (f.englishName.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                f.englishName,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    _Section(
                      title: '基础信息',
                      accent: heroBg,
                      children: [
                        _KV('甜度',
                            '${f.brixMin.toStringAsFixed(0)}-${f.brixMax.toStringAsFixed(0)} °Bx'),
                        _KV('热量', '${f.calorieKcalPer100g} kcal / 100g'),
                        _KV('性味', f.tcmNature),
                        _KV('上市旺季', f.peakSeason),
                        if (origins.isNotEmpty) _KV('主产地', origins.join('、')),
                        priceAsync.maybeWhen(
                          data: (price) {
                            if (price == null) return const SizedBox.shrink();
                            return _KV(
                              '参考批发价',
                              '¥${price.avgPrice.toStringAsFixed(2)} / kg · ${price.source}（${price.updatedAt}，n=${price.sampleCount}）',
                            );
                          },
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (vitamins.isNotEmpty || minerals.isNotEmpty)
                      _Section(
                        title: '营养（mg / 100g）',
                        accent: heroBg,
                        children: [
                          for (final e in vitamins.entries)
                            _KV('维生素 ${e.key}', '${e.value}'),
                          for (final e in minerals.entries) _KV(e.key, '${e.value}'),
                        ],
                      ),
                    const SizedBox(height: 14),
                    _Section(
                      title: '健康功效',
                      accent: heroBg,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: benefits
                              .map((b) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      b,
                                      style: const TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Section(
                      title: '禁忌人群',
                      accent: heroBg,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: contra
                              .map((c) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      c,
                                      style: const TextStyle(
                                        color: Color(0xFFC62828),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    required this.accent,
  });
  final String title;
  final List<Widget> children;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 84,
              child: Text(k, style: TextStyle(color: Colors.grey.shade700))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}
