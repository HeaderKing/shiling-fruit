import 'package:connectivity_plus/connectivity_plus.dart';

import '../database.dart';
import 'base_repositories.dart';
import 'local_repositories.dart';
import 'remote_repositories.dart';

/// 混合 Repository: 离线优先,有网络时同步
///
/// 策略:
/// - 读取: 优先读本地,后台同步远程到本地
/// - 写入: 先写本地,有网络时同步到远程
class HybridFruitRepository implements FruitRepository {
  final LocalFruitRepository _local;
  final RemoteFruitRepository _remote;
  final Connectivity _connectivity;

  HybridFruitRepository(this._local, this._remote, this._connectivity);

  Future<bool> _hasNetwork() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
           result.contains(ConnectivityResult.wifi);
  }

  @override
  Future<List<Fruit>> getAllFruits() async {
    // 优先返回本地数据
    final localFruits = await _local.getAllFruits();

    // 后台同步远程数据
    if (await _hasNetwork()) {
      _syncFromRemote();
    }

    return localFruits;
  }

  @override
  Future<Fruit?> getFruitById(String id) async {
    return _local.getFruitById(id);
  }

  @override
  Future<List<Fruit>> searchFruits(String query) async {
    return _local.searchFruits(query);
  }

  /// 后台同步: 从远程拉取最新数据到本地
  Future<void> _syncFromRemote() async {
    try {
      final remoteFruits = await _remote.getAllFruits();
      // TODO: 批量更新本地数据库
      // 当前 Drift 实现没有批量 upsert,这里暂时跳过
    } catch (e) {
      // 网络错误静默失败,不影响本地使用
    }
  }
}

/// 混合收藏仓库: 离线优先 + 云端同步
class HybridFavoriteRepository implements FavoriteRepository {
  final LocalFavoriteRepository _local;
  final RemoteFavoriteRepository? _remote;
  final Connectivity _connectivity;

  HybridFavoriteRepository(this._local, this._remote, this._connectivity);

  Future<bool> _hasNetwork() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
           result.contains(ConnectivityResult.wifi);
  }

  @override
  Future<List<Favorite>> getAllFavorites() async {
    // 优先返回本地
    final localFavorites = await _local.getAllFavorites();

    // 后台同步远程
    if (await _hasNetwork() && _remote != null) {
      _syncFromRemote();
    }

    return localFavorites;
  }

  @override
  Stream<List<Favorite>> watchFavorites() {
    // 监听本地变化
    return _local.watchFavorites();
  }

  @override
  Future<bool> isFavorite(String fruitId) {
    return _local.isFavorite(fruitId);
  }

  @override
  Future<void> addFavorite(String fruitId) async {
    // 先写本地
    await _local.addFavorite(fruitId);

    // 有网络时同步到远程
    if (await _hasNetwork() && _remote != null) {
      try {
        await _remote.addFavorite(fruitId);
      } catch (e) {
        // 失败不影响本地,后续可以重试
      }
    }
  }

  @override
  Future<void> removeFavorite(String fruitId) async {
    // 先删本地
    await _local.removeFavorite(fruitId);

    // 有网络时同步到远程
    if (await _hasNetwork() && _remote != null) {
      try {
        await _remote.removeFavorite(fruitId);
      } catch (e) {
        // 失败不影响本地
      }
    }
  }

  /// 后台同步: 从远程拉取收藏到本地
  Future<void> _syncFromRemote() async {
    if (_remote == null) return;

    try {
      final remoteFavorites = await _remote.getAllFavorites();
      final localFavorites = await _local.getAllFavorites();

      // 合并逻辑: 远程有但本地没有的,添加到本地
      for (final remote in remoteFavorites) {
        final exists = localFavorites.any((local) => local.fruitId == remote.fruitId);
        if (!exists) {
          await _local.addFavorite(remote.fruitId);
        }
      }
    } catch (e) {
      // 网络错误静默失败
    }
  }
}
