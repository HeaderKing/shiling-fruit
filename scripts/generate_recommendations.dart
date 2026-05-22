// 时令水果推荐生成器
// 输入: data/cities.json, data/templates/regional_calendar.json
// 输出: data/recommendations.json
// 运行: dart scripts/generate_recommendations.dart  (在仓库根目录执行)

import 'dart:io';
import 'dart:convert';

const _periodNames = ['上旬', '中旬', '下旬'];
const _maxPerSlot = 8;

void main() {
  final root = Directory.current.path;
  final citiesFile = File('$root/data/cities.json');
  final templateFile = File('$root/data/templates/regional_calendar.json');
  final outFile = File('$root/data/recommendations.json');

  if (!citiesFile.existsSync() || !templateFile.existsSync()) {
    stderr.writeln('请在仓库根目录运行: dart scripts/generate_recommendations.dart');
    exit(1);
  }

  final cities = jsonDecode(citiesFile.readAsStringSync()) as List;
  final template =
      jsonDecode(templateFile.readAsStringSync()) as Map<String, dynamic>;

  final recs = <Map<String, dynamic>>[];
  final missingRegions = <String>{};

  for (final city in cities) {
    final cityId = city['id'] as String;
    final region = city['region'] as String;
    final regionMonths = template[region] as Map<String, dynamic>?;
    if (regionMonths == null) {
      missingRegions.add(region);
      continue;
    }

    for (var month = 1; month <= 12; month++) {
      final pool = regionMonths['$month'] as List?;
      if (pool == null) continue;

      for (var p = 1; p <= 3; p++) {
        final entries = <Map<String, dynamic>>[];
        for (final item in pool.cast<Map<String, dynamic>>()) {
          final periods = (item['periods'] as List)
              .cast<num>()
              .map((e) => e.toInt())
              .toList();
          final scores = (item['scores'] as List)
              .cast<num>()
              .map((e) => e.toInt())
              .toList();
          if (!periods.contains(p)) continue;
          final score = scores[p - 1];
          if (score <= 0) continue;
          entries.add({
            'fruit_id': item['id'],
            'score': score,
            'reason': item['reason'],
            'locality': item['locality'],
          });
        }
        entries
            .sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
        for (final e in entries.take(_maxPerSlot)) {
          recs.add({
            'city_id': cityId,
            'month': month,
            'period': _periodNames[p - 1],
            'fruit_id': e['fruit_id'],
            'score': e['score'],
            'reason': e['reason'],
            'locality': e['locality'],
          });
        }
      }
    }
  }

  recs.sort((a, b) {
    final c = (a['city_id'] as String).compareTo(b['city_id'] as String);
    if (c != 0) return c;
    final m = (a['month'] as int).compareTo(b['month'] as int);
    if (m != 0) return m;
    final pa = _periodNames.indexOf(a['period'] as String);
    final pb = _periodNames.indexOf(b['period'] as String);
    final p = pa.compareTo(pb);
    if (p != 0) return p;
    return (b['score'] as int).compareTo(a['score'] as int);
  });

  final encoder = JsonEncoder.withIndent('  ');
  outFile.writeAsStringSync(encoder.convert(recs));
  print('生成 ${recs.length} 条推荐 → ${outFile.path}');
  if (missingRegions.isNotEmpty) {
    stderr.writeln('警告: 以下区域在模板中缺失: $missingRegions');
  }
}
