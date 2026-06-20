import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers/app_providers.dart';
import '../database.dart';
import 'base_repositories.dart';
import 'local_repositories.dart';
import 'remote_repositories.dart';
import 'hybrid_repositories.dart';

/// Repository Providers
///
/// 支持三种模式:
/// - Local: 纯本地 Drift (默认,离线可用)
/// - Remote: 纯 Supabase (需要网络)
/// - Hybrid: 混合模式,离线优先 + 后台同步

/// 数据源模式
enum DataSourceMode {
  local,  // 纯本地
  remote, // 纯远程
  hybrid, // 混合(离线优先)
}

/// 当前数据源模式 (默认本地)
final dataSourceModeProvider = StateProvider<DataSourceMode>((ref) => DataSourceMode.local);

/// 水果仓库 Provider
final fruitRepositoryProvider = Provider<FruitRepository>((ref) {
  final mode = ref.watch(dataSourceModeProvider);
  final db = ref.watch(dbProvider);

  switch (mode) {
    case DataSourceMode.local:
      return LocalFruitRepository(db);

    case DataSourceMode.remote:
      final client = Supabase.instance.client;
      return RemoteFruitRepository(client);

    case DataSourceMode.hybrid:
      final client = Supabase.instance.client;
      final connectivity = Connectivity();
      return HybridFruitRepository(
        LocalFruitRepository(db),
        RemoteFruitRepository(client),
        connectivity,
      );
  }
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
  final mode = ref.watch(dataSourceModeProvider);
  final db = ref.watch(dbProvider);

  switch (mode) {
    case DataSourceMode.local:
      return LocalFavoriteRepository(db);

    case DataSourceMode.remote:
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id ?? '';
      if (userId.isEmpty) {
        // 未登录时降级到本地
        return LocalFavoriteRepository(db);
      }
      return RemoteFavoriteRepository(client, userId);

    case DataSourceMode.hybrid:
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      final connectivity = Connectivity();

      RemoteFavoriteRepository? remote;
      if (userId != null) {
        remote = RemoteFavoriteRepository(client, userId);
      }

      return HybridFavoriteRepository(
        LocalFavoriteRepository(db),
        remote,
        connectivity,
      );
  }
});

final priceRepositoryProvider = Provider<PriceRepository>((ref) {
  final db = ref.watch(dbProvider);
  return LocalPriceRepository(db);
});

final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  final db = ref.watch(dbProvider);
  return LocalPreferenceRepository(db);
});
