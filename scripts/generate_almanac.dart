// 生成人类可读的"时令水果汇总" Markdown
// 输入: data/cities.json, data/fruits.json, data/recommendations.json
// 输出: docs/fruit-almanac.md
// 运行: dart scripts/generate_almanac.dart

import 'dart:io';
import 'dart:convert';

void main() {
  final root = Directory.current.path;
  final cities =
      (jsonDecode(File('$root/data/cities.json').readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();
  final fruits =
      (jsonDecode(File('$root/data/fruits.json').readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();
  final recs =
      (jsonDecode(File('$root/data/recommendations.json').readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>();

  final fruitById = {for (final f in fruits) f['id'] as String: f};

  final cityByRegion = <String, List<Map<String, dynamic>>>{};
  for (final c in cities) {
    cityByRegion.putIfAbsent(c['region'] as String, () => []).add(c);
  }

  const regions = ['华北', '东北', '华东', '华中', '华南', '西南', '西北'];

  final buf = StringBuffer();
  buf.writeln('# 全国时令水果指南');
  buf.writeln();
  buf.writeln(
      '> 自动生成自 `data/recommendations.json`。请勿手工编辑——改数据后运行 `dart scripts/generate_almanac.dart` 重新生成。');
  buf.writeln();
  buf.writeln(
      '覆盖 ${cities.length} 个城市，${fruits.length} 种水果，${recs.length} 条月份/旬段推荐。');
  buf.writeln();
  buf.writeln('---');
  buf.writeln();

  for (final region in regions) {
    final regionCities = cityByRegion[region] ?? [];
    if (regionCities.isEmpty) continue;
    buf.writeln('## $region');
    buf.writeln();
    for (final city in regionCities) {
      final cityId = city['id'] as String;
      final cityName = city['name'] as String;
      final province = city['province'] as String;
      buf.writeln('### $cityName（$province）');
      buf.writeln();

      final cityRecs = recs.where((r) => r['city_id'] == cityId).toList();
      for (var m = 1; m <= 12; m++) {
        final monthRecs = cityRecs.where((r) => r['month'] == m).toList();
        if (monthRecs.isEmpty) continue;
        buf.writeln('**$m 月**');
        buf.writeln();
        for (final period in ['上旬', '中旬', '下旬']) {
          final entries = monthRecs.where((r) => r['period'] == period).toList()
            ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
          if (entries.isEmpty) continue;
          buf.write('- $period: ');
          final tags = entries.take(5).map((r) {
            final f = fruitById[r['fruit_id']];
            final name = f?['name'] ?? r['fruit_id'];
            return '${name}（${r['score']}, ${r['locality']}）';
          }).join('、');
          buf.writeln(tags);
        }
        buf.writeln();
      }
      buf.writeln('---');
      buf.writeln();
    }
  }

  buf.writeln('## 附录：水果速查');
  buf.writeln();
  buf.writeln('| 名称 | 别名 | 甜度°Bx | 性味 | 主要功效 | 禁忌 | 主产地 |');
  buf.writeln('|---|---|---|---|---|---|---|');
  for (final f in fruits) {
    final name = f['name'];
    final alias = (f['alias'] as List).join('/');
    final brix = '${f['brix_min']}-${f['brix_max']}';
    final tcm = f['tcm_nature'];
    final benefits = (f['benefits'] as List).take(2).join('/');
    final contra = (f['contraindications'] as List).take(2).join('/');
    final origins = (f['origins'] as List).take(2).join('/');
    buf.writeln('| $name | $alias | $brix | $tcm | $benefits | $contra | $origins |');
  }

  File('$root/docs/fruit-almanac.md').writeAsStringSync(buf.toString());
  print('生成 docs/fruit-almanac.md，长度 ${buf.length} 字符');
}
