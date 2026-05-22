import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../services/data_updater.dart';
import 'database.dart';

/// 把数据 JSON 导入到 SQLite。
/// 优先从 documents/data/（DataUpdater 维护）读取；不存在时回退 assets。
class SeedLoader {
  SeedLoader(this._db, this._updater);
  final AppDatabase _db;
  final DataUpdater _updater;

  static const _versionKey = 'seed_version';

  Future<void> ensureLoaded() async {
    final dataVersion = (await _updater.currentVersion()).toString();
    final current = await _db.getPref(_versionKey);
    if (current == dataVersion) return;

    await _db.transaction(() async {
      await _db.delete(_db.recommendations).go();
      await _db.delete(_db.fruits).go();
      await _db.delete(_db.cities).go();
      await _db.clearPrices();

      await _loadCities();
      await _loadFruits();
      await _loadRecommendations();
      await _loadPrices();
      await _db.setPref(_versionKey, dataVersion);
    });
  }

  Future<void> _loadCities() async {
    final raw = await _updater.readDataFile('cities.json');
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
    final raw = await _updater.readDataFile('fruits.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    await _db.batch((b) {
      for (final f in list) {
        b.insert(
          _db.fruits,
          FruitsCompanion.insert(
            id: f['id'] as String,
            name: f['name'] as String,
            englishName: f['english_name'] as String? ?? '',
            emoji: Value(f['emoji'] as String? ?? ''),
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
    final raw = await _updater.readDataFile('recommendations.json');
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

  Future<void> _loadPrices() async {
    String raw;
    try {
      raw = await _updater.readDataFile('prices.json');
    } catch (_) {
      return; // 价格数据可选，缺失时跳过
    }
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    for (final p in list) {
      await _db.upsertPrice(
        fruitId: p['fruit_id'] as String,
        avgPrice: (p['avg_price'] as num).toDouble(),
        unit: p['unit'] as String? ?? '元/kg',
        sampleCount: (p['sample_count'] as num?)?.toInt() ?? 0,
        source: p['source'] as String? ?? '',
        updatedAt: p['updated_at'] as String? ?? '',
      );
    }
  }
}
