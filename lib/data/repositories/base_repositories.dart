import '../database.dart';

/// 水果数据仓库接口
abstract class FruitRepository {
  /// 获取所有水果
  Future<List<Fruit>> getAllFruits();

  /// 根据ID查找水果
  Future<Fruit?> getFruitById(String id);

  /// 搜索水果(按名称/英文名/产地)
  Future<List<Fruit>> searchFruits(String query);
}

/// 城市数据仓库接口
abstract class CityRepository {
  /// 获取所有城市
  Future<List<City>> getAllCities();

  /// 根据ID查找城市
  Future<City?> getCityById(String id);

  /// 按地区查找城市
  Future<List<City>> getCitiesByRegion(String region);

  /// 按地区分组获取城市
  Future<Map<String, List<City>>> getCitiesGroupedByRegion();
}

/// 推荐数据仓库接口
abstract class RecommendationRepository {
  /// 获取指定城市/月份/旬段的推荐
  Future<List<Recommendation>> getRecommendations({
    required String cityId,
    required int month,
    required String period,
  });

  /// 获取指定城市/月份的所有推荐
  Future<List<Recommendation>> getRecommendationsForMonth({
    required String cityId,
    required int month,
  });
}

/// 收藏数据仓库接口
abstract class FavoriteRepository {
  /// 获取所有收藏
  Future<List<Favorite>> getAllFavorites();

  /// 监听收藏变化
  Stream<List<Favorite>> watchFavorites();

  /// 检查是否已收藏
  Future<bool> isFavorite(String fruitId);

  /// 添加收藏
  Future<void> addFavorite(String fruitId);

  /// 移除收藏
  Future<void> removeFavorite(String fruitId);
}

/// 价格数据仓库接口
abstract class PriceRepository {
  /// 获取水果价格
  Future<Price?> getPrice(String fruitId);

  /// 更新价格
  Future<void> upsertPrice({
    required String fruitId,
    required double avgPrice,
    required String source,
    required String updatedAt,
    required int sampleCount,
  });

  /// 清空所有价格数据
  Future<void> clearAllPrices();
}

/// 用户偏好设置仓库接口
abstract class PreferenceRepository {
  /// 获取偏好设置
  Future<String?> getPreference(String key);

  /// 设置偏好
  Future<void> setPreference(String key, String value);
}
