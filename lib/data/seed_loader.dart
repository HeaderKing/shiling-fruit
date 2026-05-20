import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'database.dart';

/// 把 assets/data/*.json 导入到 SQLite。
/// 用 UserPrefs 表的 `seed_version` 记录已导入版本，避免重复导入。
class SeedLoader {
  SeedLoader(this._db);
  final AppDatabase _db;

  /// 升级数据时把这个值加一，重启 App 会重新加载。
  static const _currentVersion = '1';
  static const _versionKey = 'seed_version';

  Future<void> ensureLoaded() async {
    final current = await _db.getPref(_versionKey);
    if (current == _currentVersion) return;

    await _db.transaction(() async {
      // 清空旧数据（保留 favorites 和 prefs）
      await _db.delete(_db.recommendations).go();
      await _db.delete(_db.fruits).go();
      await _db.delete(_db.cities).go();

      await _loadCities();
      await _loadFruits();
      await _loadRecommendations();
      await _db.setPref(_versionKey, _currentVersion);
    });
  }

  Future<void> _loadCities() async {
    final raw = await rootBundle.loadString('assets/data/cities.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    await _db.batch((b) {
      for (final c in list) {
        b.insert(
          _db.cities,
          CitiesCompanion.insert(
            id: c['id'] as String,
            name: c['name'] as String,
            province: c['province'] as String,
            region: c['region'] as String,
            climateZone: c['climate_zone'] as String,
            lat: (c['lat'] as num).toDouble(),
            lng: (c['lng'] as num).toDouble(),
          ),
        );
      }
    });
  }

  Future<void> _loadFruits() async {
    final raw = await rootBundle.loadString('assets/data/fruits.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    await _db.batch((b) {
      for (final f in list) {
        b.insert(
          _db.fruits,
          FruitsCompanion.insert(
            id: f['id'] as String,
            name: f['name'] as String,
            englishName: f['english_name'] as String? ?? '',
            image: f['image'] as String? ?? '',
            colorHex: f['color_hex'] as String? ?? '#CCCCCC',
            brixMin: (f['brix_min'] as num).toDouble(),
            brixMax: (f['brix_max'] as num).toDouble(),
            calorieKcalPer100g: (f['calorie_kcal_per_100g'] as num).toInt(),
            tcmNature: f['tcm_nature'] as String? ?? '平',
            peakSeason: f['peak_season'] as String? ?? '',
            aliasJson: jsonEncode(f['alias'] ?? []),
            vitaminsJson: jsonEncode(f['vitamins'] ?? {}),
            mineralsJson: jsonEncode(f['minerals'] ?? {}),
            benefitsJson: jsonEncode(f['benefits'] ?? []),
            contraindicationsJson: jsonEncode(f['contraindications'] ?? []),
            originsJson: jsonEncode(f['origins'] ?? []),
          ),
        );
      }
    });
  }

  Future<void> _loadRecommendations() async {
    final raw =
        await rootBundle.loadString('assets/data/recommendations.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    await _db.batch((b) {
      for (final r in list) {
        b.insert(
          _db.recommendations,
          RecommendationsCompanion.insert(
            cityId: r['city_id'] as String,
            month: (r['month'] as num).toInt(),
            period: r['period'] as String,
            fruitId: r['fruit_id'] as String,
            score: (r['score'] as num).toInt(),
            reason: r['reason'] as String,
            locality: r['locality'] as String,
          ),
        );
      }
    });
  }
}
