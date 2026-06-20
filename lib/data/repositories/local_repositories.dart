import '../../data/database.dart';
import 'base_repositories.dart';

/// Drift (本地 SQLite) 实现的水果仓库
class LocalFruitRepository implements FruitRepository {
  final AppDatabase _db;

  LocalFruitRepository(this._db);

  @override
  Future<List<Fruit>> getAllFruits() => _db.allFruits();

  @override
  Future<Fruit?> getFruitById(String id) => _db.findFruit(id);

  @override
  Future<List<Fruit>> searchFruits(String query) async {
    final allFruits = await _db.allFruits();
    final q = query.toLowerCase();
    return allFruits.where((f) =>
      f.name.toLowerCase().contains(q) ||
      f.englishName.toLowerCase().contains(q) ||
      f.peakSeason.toLowerCase().contains(q)
    ).toList();
  }
}

/// Drift 实现的城市仓库
class LocalCityRepository implements CityRepository {
  final AppDatabase _db;

  LocalCityRepository(this._db);

  @override
  Future<List<City>> getAllCities() => _db.allCities();

  @override
  Future<City?> getCityById(String id) => _db.findCity(id);

  @override
  Future<List<City>> getCitiesByRegion(String region) =>
      _db.citiesByRegion(region);

  @override
  Future<Map<String, List<City>>> getCitiesGroupedByRegion() async {
    final all = await _db.allCities();
    const order = ['华北', '东北', '华东', '华中', '华南', '西南', '西北'];
    final map = <String, List<City>>{for (final r in order) r: []};
    for (final c in all) {
      map.putIfAbsent(c.region, () => []).add(c);
    }
    return map;
  }
}

/// Drift 实现的推荐仓库
class LocalRecommendationRepository implements RecommendationRepository {
  final AppDatabase _db;

  LocalRecommendationRepository(this._db);

  @override
  Future<List<Recommendation>> getRecommendations({
    required String cityId,
    required int month,
    required String period,
  }) => _db.recommendationsFor(cityId, month, period);

  @override
  Future<List<Recommendation>> getRecommendationsForMonth({
    required String cityId,
    required int month,
  }) => _db.recommendationsForMonth(cityId, month);
}

/// Drift 实现的收藏仓库
class LocalFavoriteRepository implements FavoriteRepository {
  final AppDatabase _db;

  LocalFavoriteRepository(this._db);

  @override
  Future<List<Favorite>> getAllFavorites() => _db.allFavorites();

  @override
  Stream<List<Favorite>> watchFavorites() => _db.watchFavorites();

  @override
  Future<bool> isFavorite(String fruitId) => _db.isFavorite(fruitId);

  @override
  Future<void> addFavorite(String fruitId) => _db.addFavorite(fruitId);

  @override
  Future<void> removeFavorite(String fruitId) => _db.removeFavorite(fruitId);
}

/// Drift 实现的价格仓库
class LocalPriceRepository implements PriceRepository {
  final AppDatabase _db;

  LocalPriceRepository(this._db);

  @override
  Future<Price?> getPrice(String fruitId) => _db.getPrice(fruitId);

  @override
  Future<void> upsertPrice({
    required String fruitId,
    required double avgPrice,
    required String source,
    required String updatedAt,
    required int sampleCount,
  }) => _db.upsertPrice(
        fruitId: fruitId,
        avgPrice: avgPrice,
        source: source,
        updatedAt: updatedAt,
        sampleCount: sampleCount,
      );

  @override
  Future<void> clearAllPrices() => _db.clearPrices();
}

/// Drift 实现的偏好设置仓库
class LocalPreferenceRepository implements PreferenceRepository {
  final AppDatabase _db;

  LocalPreferenceRepository(this._db);

  @override
  Future<String?> getPreference(String key) => _db.getPref(key);

  @override
  Future<void> setPreference(String key, String value) =>
      _db.setPref(key, value);
}
