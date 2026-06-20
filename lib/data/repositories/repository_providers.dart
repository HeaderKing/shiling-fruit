import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../database.dart';
import 'base_repositories.dart';
import 'local_repositories.dart';

/// Repository Providers
///
/// 这些 Provider 提供统一的数据访问接口
/// 当前使用本地 Drift 实现,未来可切换到 Supabase 或混合模式

final fruitRepositoryProvider = Provider<FruitRepository>((ref) {
  final db = ref.watch(dbProvider);
  return LocalFruitRepository(db);
});

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  final db = ref.watch(dbProvider);
  return LocalCityRepository(db);
});

final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  final db = ref.watch(dbProvider);
  return LocalRecommendationRepository(db);
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  final db = ref.watch(dbProvider);
  return LocalFavoriteRepository(db);
});

final priceRepositoryProvider = Provider<PriceRepository>((ref) {
  final db = ref.watch(dbProvider);
  return LocalPriceRepository(db);
});

final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  final db = ref.watch(dbProvider);
  return LocalPreferenceRepository(db);
});
