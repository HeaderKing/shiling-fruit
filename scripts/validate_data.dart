// 时令水果数据校验器
// 检查 cities/fruits/recommendations 的完整性、外键、覆盖率
// 运行: dart scripts/validate_data.dart  (在仓库根目录执行)
// exit 0 = 全部通过；exit 1 = 有 ERROR；exit 0 + 标准错误打印 = 仅 WARNING

import 'dart:io';
import 'dart:convert';

void main() {
  final root = Directory.current.path;
  final cities =
      jsonDecode(File('$root/data/cities.json').readAsStringSync()) as List;
  final fruits =
      jsonDecode(File('$root/data/fruits.json').readAsStringSync()) as List;
  final recs =
      jsonDecode(File('$root/data/recommendations.json').readAsStringSync())
          as List;

  final cityIds = cities.map((c) => c['id'] as String).toSet();
  final fruitIds = fruits.map((f) => f['id'] as String).toSet();

  final errors = <String>[];
  final warnings = <String>[];

  // 1. 外键
  for (final r in recs) {
    if (!cityIds.contains(r['city_id'])) {
      errors.add('city_id 未注册: ${r['city_id']} in ${jsonEncode(r)}');
    }
    if (!fruitIds.contains(r['fruit_id'])) {
      errors.add('fruit_id 未注册: ${r['fruit_id']} in ${jsonEncode(r)}');
    }
  }

  // 2. 枚举
  const validPeriods = {'上旬', '中旬', '下旬'};
  const validLocalities = {'本地特产', '邻近产区', '外来'};
  for (final r in recs) {
    if (!validPeriods.contains(r['period'])) {
      errors.add('period 非法: ${r['period']}');
    }
    if (!validLocalities.contains(r['locality'])) {
      errors.add('locality 非法: ${r['locality']}');
    }
    final m = r['month'] as int;
    if (m < 1 || m > 12) errors.add('month 越界: $m');
    final s = r['score'] as int;
    if (s < 0 || s > 100) errors.add('score 越界: $s');
  }

  // 3. 覆盖率: 每 (city, month, period) 至少 1 条
  final coverage = <String, int>{};
  for (final r in recs) {
    final key = '${r['city_id']}-${r['month']}-${r['period']}';
    coverage[key] = (coverage[key] ?? 0) + 1;
  }
  for (final c in cityIds) {
    for (var m = 1; m <= 12; m++) {
      for (final p in validPeriods) {
        final key = '$c-$m-$p';
        final n = coverage[key] ?? 0;
        if (n == 0) {
          warnings.add('无推荐: $c $m月$p');
        }
      }
    }
  }

  // 4. 输出
  print('=== 数据校验报告 ===');
  print('城市数:     ${cities.length}');
  print('水果数:     ${fruits.length}');
  print('推荐条目数: ${recs.length}');
  print('期望最少:   ${cityIds.length * 12 * 3} 条 (city × month × period)');
  print(
      '覆盖率:     ${(coverage.length / (cityIds.length * 12 * 3) * 100).toStringAsFixed(1)}%');

  if (errors.isNotEmpty) {
    stderr.writeln('\nERRORS (${errors.length}):');
    for (final e in errors.take(50)) {
      stderr.writeln('  - $e');
    }
    if (errors.length > 50) stderr.writeln('  ... 还有 ${errors.length - 50} 条');
  }
  if (warnings.isNotEmpty) {
    stderr.writeln('\nWARNINGS (${warnings.length}):');
    for (final w in warnings.take(20)) {
      stderr.writeln('  - $w');
    }
    if (warnings.length > 20) {
      stderr.writeln('  ... 还有 ${warnings.length - 20} 条');
    }
  }

  if (errors.isNotEmpty) {
    exit(1);
  }
  print('\n✓ 全部通过 (${warnings.length} 个 WARNING)');
}
