// 中文维基百科水果词条抓取脚本。
// 用法: dart scripts/scrape_wiki.dart "烟台苹果"
// 免 API key。
// 输出 alias / origins / peak_season 候选 + 维基词条摘要，供贡献者人工核对。

import 'dart:convert';
import 'dart:io';

const _apiBase = 'https://zh.wikipedia.org/w/api.php';

Future<void> main(List<String> argv) async {
  if (argv.isEmpty) {
    stderr.writeln('用法: dart scripts/scrape_wiki.dart "烟台苹果"');
    exit(1);
  }
  final title = argv.first;

  // 1. 取词条摘要（intro 段）
  final introUri = Uri.parse('$_apiBase'
      '?action=query&format=json&prop=extracts&exintro=1&explaintext=1'
      '&redirects=1&titles=${Uri.encodeQueryComponent(title)}');
  final resp = await _get(introUri);
  final pages = (resp['query']?['pages'] as Map?)?.values.toList() ?? [];
  if (pages.isEmpty || pages.first['extract'] == null) {
    stderr.writeln('未找到维基词条: $title');
    exit(2);
  }
  final extract = pages.first['extract'] as String;
  final realTitle = pages.first['title'] as String? ?? title;

  print('词条: $realTitle');
  print('─' * 50);
  print(extract);
  print('─' * 50);

  // 2. 简单正则提取候选字段
  final aliases = <String>{};
  for (final m
      in RegExp(r'(?:又[名称]|别[名称]|俗[名称])(?:为|是|叫|：)?\s*([一-龥]{2,10})')
          .allMatches(extract)) {
    aliases.add(m.group(1)!);
  }
  for (final m
      in RegExp(r'[（(]([一-龥]{2,8})(?:[、，,]|[）)])').allMatches(extract)) {
    aliases.add(m.group(1)!);
  }
  aliases.remove(realTitle);

  final origins = <String>{};
  for (final m in RegExp(
          r'(?:主产|原产|盛产|分布)(?:于|地?是|地?为|区?有?)?\s*([一-龥、，,]{2,30})')
      .allMatches(extract)) {
    final group = m.group(1)!;
    for (final part in group.split(RegExp(r'[、，,]'))) {
      final p = part.trim();
      if (p.isNotEmpty && p.length <= 8) origins.add(p);
    }
  }

  String? peakSeason;
  final monthRange =
      RegExp(r'(\d{1,2})\s*(?:[-~–至到])\s*(\d{1,2})\s*月').firstMatch(extract);
  if (monthRange != null) {
    peakSeason = '${monthRange.group(1)}-${monthRange.group(2)}月';
  }

  print('\n[自动提取候选]\n');
  final out = <String, dynamic>{
    'alias': aliases.take(5).toList(),
    'origins': origins.take(5).toList(),
    if (peakSeason != null) 'peak_season': peakSeason,
  };
  print(const JsonEncoder.withIndent('  ').convert(out));
  print('\n⚠️ 自动提取仅是候选，请人工对照词条摘要核对再填入 data/fruits.json。');
}

Future<Map<String, dynamic>> _get(Uri uri) async {
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    req.headers.add('User-Agent',
        'shiling-fruit-bot/0.1 (https://github.com/HeaderKing/shiling-fruit)');
    final resp = await req.close();
    if (resp.statusCode != 200) {
      stderr.writeln('HTTP ${resp.statusCode}: $uri');
      exit(3);
    }
    final body = await resp.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}
