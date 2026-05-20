import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../services/location_service.dart';
import '../utils/date_utils.dart';

// Database
final dbProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override in main()');
});

// Services
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(ref.watch(dbProvider));
});

// 选中的城市 id（启动时从 user prefs 或定位填入；UI 切换城市改它）
final selectedCityIdProvider = StateProvider<String>((ref) => 'beijing');

// 当前日期相关
final nowProvider = Provider<DateTime>((ref) => DateTime.now());
final monthProvider =
    Provider<int>((ref) => currentMonth(ref.watch(nowProvider)));
final periodProvider =
    Provider<String>((ref) => currentPeriod(ref.watch(nowProvider)));

// 城市列表
final allCitiesProvider = FutureProvider<List<City>>((ref) async {
  return ref.watch(dbProvider).allCities();
});

final citiesByRegionProvider =
    FutureProvider<Map<String, List<City>>>((ref) async {
  final all = await ref.watch(allCitiesProvider.future);
  const order = ['华北', '东北', '华东', '华中', '华南', '西南', '西北'];
  final map = <String, List<City>>{for (final r in order) r: []};
  for (final c in all) {
    map.putIfAbsent(c.region, () => []).add(c);
  }
  return map;
});

// 当前选中城市
final selectedCityProvider = FutureProvider<City?>((ref) async {
  final id = ref.watch(selectedCityIdProvider);
  return ref.watch(dbProvider).findCity(id);
});

// 当前城市/月份/旬段 的推荐
final currentRecommendationsProvider =
    FutureProvider<List<Recommendation>>((ref) async {
  final cityId = ref.watch(selectedCityIdProvider);
  final m = ref.watch(monthProvider);
  final p = ref.watch(periodProvider);
  return ref.watch(dbProvider).recommendationsFor(cityId, m, p);
});

// 某月推荐（用于 calendar_page）
final monthRecommendationsProvider =
    FutureProvider.family<List<Recommendation>, int>((ref, month) async {
  final cityId = ref.watch(selectedCityIdProvider);
  return ref.watch(dbProvider).recommendationsForMonth(cityId, month);
});

// 单个水果详情
final fruitProvider =
    FutureProvider.family<Fruit?, String>((ref, id) async {
  return ref.watch(dbProvider).findFruit(id);
});

// 全部水果（索引页）
final allFruitsProvider = FutureProvider<List<Fruit>>((ref) async {
  return ref.watch(dbProvider).allFruits();
});

// 收藏 stream
final favoritesProvider = StreamProvider<List<Favorite>>((ref) {
  return ref.watch(dbProvider).watchFavorites();
});
