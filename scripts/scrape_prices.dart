// scripts/scrape_prices.dart
// 爬全国农产品批发均价（数据源：新发地批发市场公开 priceDetail 接口）。
//
// 用法:
//   dart scripts/scrape_prices.dart           # 全部水果
//   dart scripts/scrape_prices.dart --days 30 # 最近 30 天
//   dart scripts/scrape_prices.dart --only yantai_apple,kuerle_pear
//
// 输出: data/prices.json
//
// 实现：一次性把水果分类 (prodCatid=1187) 近 N 天的全部批发价拉下来，
// 然后在本地按 fruit.name / alias / 去地域名 做模糊匹配求平均。
// 比逐个 prodName 查询更稳（接口对 prodName 是精确匹配，命中率低）。

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

const _endpoint = 'http://www.xinfadi.com.cn/getPriceData.html';

String _stripLocale(String name) {
  const prefixes = [
    '烟台','洛川','阿克苏','库尔勒','砀山','莱阳','奉化','南汇','大连',
    '黑龙江','吉林','辽宁','北京','天津','河北','山西','山东','河南',
    '湖北','湖南','江苏','浙江','安徽','福建','广东','广西','海南',
    '四川','重庆','贵州','云南','陕西','甘肃','宁夏','青海','新疆','西藏',
    '内蒙古','陕北','晋南','江南','华南','华北',
  ];
  for (final pre in prefixes) {
    if (name.startsWith(pre) && name.length > pre.length) {
      return name.substring(pre.length);
    }
  }
  return name;
}

Future<List<Map<String, dynamic>>> _fetchAllFruitPrices(
    HttpClient client, int days) async {
  final now = DateTime.now();
  final start = now.subtract(Duration(days: days));
  String fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  final all = <Map<String, dynamic>>[];
  var page = 1;
  const limit = 1000;
  while (true) {
    final body = {
      'limit': '$limit',
      'current': '$page',
      'pubDateStartTime': fmt(start),
      'pubDateEndTime': fmt(now),
      'prodCatid': '',
      'prodPcatid': '',
      'prodName': '',
    };
    final form = body.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    final req = await client.postUrl(Uri.parse(_endpoint));
    req.headers
      ..set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded')
      ..set(HttpHeaders.userAgentHeader, 'Mozilla/5.0')
      ..set('Referer', 'http://www.xinfadi.com.cn/priceDetail.html');
    req.write(form);
    final resp = await req.close();
    if (resp.statusCode != 200) {
      throw HttpException('HTTP ${resp.statusCode}');
    }
    final raw = await resp.transform(utf8.decoder).join();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = (json['list'] as List? ?? []).cast<Map<String, dynamic>>();
    if (list.isEmpty) break;
    // 服务端不按 prodCatid 过滤，脚本侧过滤水果
    final fruitsOnly =
        list.where((r) => r['prodCat'] == '水果').toList();
    all.addAll(fruitsOnly);
    if (list.length < limit) break;
    page++;
    if (page > 30) break;
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  return all;
}

({double? avg, int n}) _aggregate(
    List<Map<String, dynamic>> rows, List<String> keywords) {
  final prices = <double>[];
  for (final r in rows) {
    final name = (r['prodName'] as String? ?? '').toLowerCase();
    final unit = (r['unitInfo'] as String? ?? '').trim();
    if (!keywords.any((k) => name.contains(k.toLowerCase()))) continue;
    final low = double.tryParse('${r['lowPrice']}');
    final high = double.tryParse('${r['highPrice']}');
    final avg = double.tryParse('${r['avgPrice']}');
    double? v;
    if (avg != null && avg > 0) {
      v = avg;
    } else if (low != null && high != null) {
      v = (low + high) / 2;
    }
    if (v == null) continue;
    if (unit == '斤') v = v * 2; // 转 元/kg
    prices.add(v);
  }
  if (prices.isEmpty) return (avg: null, n: 0);
  final mean = prices.reduce((a, b) => a + b) / prices.length;
  return (avg: double.parse(mean.toStringAsFixed(2)), n: prices.length);
}

Future<void> main(List<String> argv) async {
  var days = 30;
  Set<String>? onlyIds;
  for (var i = 0; i < argv.length; i++) {
    if (argv[i] == '--days' && i + 1 < argv.length) {
      days = int.parse(argv[++i]);
    } else if (argv[i] == '--only' && i + 1 < argv.length) {
      onlyIds = argv[++i].split(',').map((s) => s.trim()).toSet();
    }
  }

  final fruitsPath = p.join('data', 'fruits.json');
  final fruits = (jsonDecode(await File(fruitsPath).readAsString()) as List)
      .cast<Map<String, dynamic>>();

  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8)
    ..idleTimeout = const Duration(seconds: 6);

  stdout.writeln('Fetching xinfadi fruit prices ($days days)…');
  final rows = await _fetchAllFruitPrices(client, days);
  stdout.writeln('Got ${rows.length} rows.');
  client.close();

  final out = <Map<String, dynamic>>[];
  for (final f in fruits) {
    final id = f['id'] as String;
    if (onlyIds != null && !onlyIds.contains(id)) continue;
    final name = f['name'] as String;
    final aliases = (f['alias'] as List? ?? []).cast<String>();

    final keywords = <String>{
      _stripLocale(name),
      ...aliases,
      name,
    }.where((s) => s.isNotEmpty).toList();

    final r = _aggregate(rows, keywords);
    if (r.avg == null) {
      stderr.writeln('[$id] $name 未匹配');
      continue;
    }
    stdout.writeln('[$id] $name avg=¥${r.avg}/kg n=${r.n}');
    out.add({
      'fruit_id': id,
      'avg_price': r.avg,
      'unit': '元/kg',
      'sample_count': r.n,
      'source': 'xinfadi.com.cn',
      'updated_at':
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    });
  }

  final outPath = p.join('data', 'prices.json');
  await File(outPath).writeAsString(
    const JsonEncoder.withIndent('  ').convert(out),
  );
  stdout.writeln('Wrote ${out.length} entries to $outPath');
}
