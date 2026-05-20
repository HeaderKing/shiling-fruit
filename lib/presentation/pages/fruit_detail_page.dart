import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/fruit_thumb.dart';

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

  @override
  Widget build(BuildContext context) {
    final fAsync = ref.watch(fruitProvider(widget.fruitId));
    return Scaffold(
      appBar: AppBar(
        title: fAsync.maybeWhen(
          data: (f) => Text(f?.name ?? ''),
          orElse: () => const Text('水果详情'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite : Icons.favorite_border,
              color: _isFav ? Colors.red : null,
            ),
            onPressed: _toggleFav,
          ),
        ],
      ),
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  FruitThumb(colorHex: f.colorHex, name: f.name, size: 88),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        if (aliases.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '别名: ${aliases.join("、")}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        if (f.englishName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(f.englishName,
                                style: TextStyle(color: Colors.grey.shade600)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _Section(title: '基础信息', children: [
                _KV('甜度',
                    '${f.brixMin.toStringAsFixed(0)}-${f.brixMax.toStringAsFixed(0)} °Bx'),
                _KV('热量', '${f.calorieKcalPer100g} kcal / 100g'),
                _KV('性味', f.tcmNature),
                _KV('上市旺季', f.peakSeason),
                if (origins.isNotEmpty) _KV('主产地', origins.join('、')),
              ]),
              const SizedBox(height: 16),
              if (vitamins.isNotEmpty || minerals.isNotEmpty)
                _Section(title: '营养（mg / 100g）', children: [
                  for (final e in vitamins.entries)
                    _KV('维生素 ${e.key}', '${e.value}'),
                  for (final e in minerals.entries) _KV(e.key, '${e.value}'),
                ]),
              const SizedBox(height: 16),
              _Section(
                title: '健康功效',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: benefits
                        .map((b) => Chip(
                              label: Text(b),
                              backgroundColor: Colors.green.shade50,
                              labelStyle:
                                  TextStyle(color: Colors.green.shade800),
                            ))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: '禁忌人群',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: contra
                        .map((c) => Chip(
                              label: Text(c),
                              backgroundColor: Colors.red.shade50,
                              labelStyle: TextStyle(color: Colors.red.shade800),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
