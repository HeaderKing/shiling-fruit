// USDA FoodData Central 营养数据抓取脚本。
// 用法: dart scripts/scrape_usda.dart "Apple"   (英文名)
// 需要环境变量 USDA_API_KEY (免费注册：https://fdc.nal.usda.gov/api-guide.html)
// 输出符合本项目 fruits.json schema 的 vitamins/minerals/calorie 字段片段。
//
// 注意：USDA 数据为美国市场参考值，需与中国本土数据交叉验证。
//      仅供贡献者填空起点，不可直接 commit 未经核对的结果。

import 'dart:convert';
import 'dart:io';

const _baseUrl = 'https://api.nal.usda.gov/fdc/v1';

// USDA nutrient ID → 本项目字段名映射（部分常用项）
const _vitaminMap = {
  '1162': 'C',
  '1175': 'B6',
  '1166': 'B2',
  '1165': 'B1',
  '1167': 'B3',
  '1109': 'E',
  '1106': 'A',
  '1185': 'K',
  '1177': 'B9',
};
const _mineralMap = {
  '1092': 'K',
  '1087': 'Ca',
  '1090': 'Mg',
  '1089': 'Fe',
  '1095': 'Zn',
  '1103': 'Se',
  '1101': 'Mn',
};

Future<void> main(List<String> argv) async {
  final key = Platform.environment['USDA_API_KEY'];
  if (key == null || key.isEmpty) {
    stderr.writeln('请先设置环境变量 USDA_API_KEY');
    stderr.writeln('  Linux/Mac:  export USDA_API_KEY=xxx');
    stderr.writeln('  Windows:    set USDA_API_KEY=xxx');
    stderr.writeln('  注册地址:    https://fdc.nal.usda.gov/api-guide.html');
    exit(1);
  }
  if (argv.isEmpty) {
    stderr.writeln('用法: dart scripts/scrape_usda.dart "Apple"');
    exit(1);
  }
  final query = argv.first;

  // 1. 搜索
  final searchUri = Uri.parse('$_baseUrl/foods/search'
      '?api_key=$key&query=${Uri.encodeQueryComponent(query)}'
      '&dataType=Foundation,SR%20Legacy&pageSize=5');
  final searchResp = await _get(searchUri);
  final foods = (searchResp['foods'] as List?) ?? [];
  if (foods.isEmpty) {
    stderr.writeln('未找到匹配的食物: $query');
    exit(2);
  }
  print('找到 ${foods.length} 条候选:');
  for (var i = 0; i < foods.length; i++) {
    final f = foods[i] as Map<String, dynamic>;
    print('  [$i] ${f['description']} (fdcId=${f['fdcId']}, type=${f['dataType']})');
  }

  // 2. 取第一条详情
  final pick = foods.first as Map<String, dynamic>;
  final fdcId = pick['fdcId'];
  print('\n使用第 [0] 条 (fdcId=$fdcId) 提取营养字段...\n');
  final detailUri = Uri.parse('$_baseUrl/food/$fdcId?api_key=$key');
  final detail = await _get(detailUri);

  // 3. 解析 nutrients
  final nutrients = (detail['foodNutrients'] as List?) ?? [];
  final vitamins = <String, num>{};
  final minerals = <String, num>{};
  num? calorie;
  for (final n in nutrients.cast<Map<String, dynamic>>()) {
    final nutId =
        (n['nutrient']?['id'] ?? n['nutrientId'])?.toString();
    final amount = (n['amount'] as num?) ??
        (n['value'] as num?) ??
        (n['nutrientValue'] as num?);
    if (nutId == null || amount == null) continue;
    if (nutId == '1008') {
      calorie = amount;
    } else if (_vitaminMap.containsKey(nutId)) {
      vitamins[_vitaminMap[nutId]!] = amount;
    } else if (_mineralMap.containsKey(nutId)) {
      minerals[_mineralMap[nutId]!] = amount;
    }
  }

  // 4. 输出 JSON 片段
  final out = <String, dynamic>{
    'english_name': pick['description'],
    'calorie_kcal_per_100g': calorie?.round() ?? 0,
    'vitamins': vitamins,
    'minerals': minerals,
  };
  print(const JsonEncoder.withIndent('  ').convert(out));
  print('\n请将以上字段对照后复制到 data/fruits.json 中对应 entry。');
  print('⚠️ USDA 数据为美国市场参考值，请与中国本土数据交叉验证。');
}

Future<Map<String, dynamic>> _get(Uri uri) async {
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
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

