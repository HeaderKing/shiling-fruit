import 'package:supabase_flutter/supabase_flutter.dart';

import '../database.dart';
import 'base_repositories.dart';

/// Supabase (远程 PostgreSQL) 实现的水果仓库
class RemoteFruitRepository implements FruitRepository {
  final SupabaseClient _client;

  RemoteFruitRepository(this._client);

  @override
  Future<List<Fruit>> getAllFruits() async {
    final response = await _client.from('fruits').select();
    return response.map((json) => Fruit(
      id: json['id'] as String,
      name: json['name'] as String,
      englishName: json['english_name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      image: json['image'] as String? ?? '',
      colorHex: json['color_hex'] as String? ?? '#CCCCCC',
      brixMin: (json['brix_min'] as num?)?.toDouble() ?? 0,
      brixMax: (json['brix_max'] as num?)?.toDouble() ?? 0,
      calorieKcalPer100g: json['calorie_kcal_per_100g'] as int? ?? 0,
      tcmNature: json['tcm_nature'] as String? ?? '平',
      pickingTips: json['picking_tips'] as String? ?? '',
      storageTips: json['storage_tips'] as String? ?? '',
      bestEatMethod: json['best_eat_method'] as String? ?? '',
      varietyJson: json['variety_json'] as String? ?? '[]',
      gradeStd: json['grade_std'] as String? ?? '',
      aliasJson: json['alias_json'] as String? ?? '[]',
      vitaminsJson: json['vitamins_json'] as String? ?? '{}',
      mineralsJson: json['minerals_json'] as String? ?? '{}',
      benefitsJson: json['benefits_json'] as String? ?? '[]',
      contraindicationsJson: json['contraindications_json'] as String? ?? '[]',
      originsJson: json['origins_json'] as String? ?? '[]',
      peakSeason: json['peak_season'] as String? ?? '',
    )).toList();
  }

  @override
  Future<Fruit?> getFruitById(String id) async {
    final response = await _client.from('fruits').select().eq('id', id).maybeSingle();
    if (response == null) return null;

    return Fruit(
      id: response['id'] as String,
      name: response['name'] as String,
      englishName: response['english_name'] as String? ?? '',
      emoji: response['emoji'] as String? ?? '',
      image: response['image'] as String? ?? '',
      colorHex: response['color_hex'] as String? ?? '#CCCCCC',
      brixMin: (response['brix_min'] as num?)?.toDouble() ?? 0,
      brixMax: (response['brix_max'] as num?)?.toDouble() ?? 0,
      calorieKcalPer100g: response['calorie_kcal_per_100g'] as int? ?? 0,
      tcmNature: response['tcm_nature'] as String? ?? '平',
      pickingTips: response['picking_tips'] as String? ?? '',
      storageTips: response['storage_tips'] as String? ?? '',
      bestEatMethod: response['best_eat_method'] as String? ?? '',
      varietyJson: response['variety_json'] as String? ?? '[]',
      gradeStd: response['grade_std'] as String? ?? '',
      aliasJson: response['alias_json'] as String? ?? '[]',
      vitaminsJson: response['vitamins_json'] as String? ?? '{}',
      mineralsJson: response['minerals_json'] as String? ?? '{}',
      benefitsJson: response['benefits_json'] as String? ?? '[]',
      contraindicationsJson: response['contraindications_json'] as String? ?? '[]',
      originsJson: response['origins_json'] as String? ?? '[]',
      peakSeason: response['peak_season'] as String? ?? '',
    );
  }

  @override
  Future<List<Fruit>> searchFruits(String query) async {
    final q = query.toLowerCase();
    final response = await _client.from('fruits').select()
        .or('name.ilike.%$q%,english_name.ilike.%$q%,peak_season.ilike.%$q%');

    return response.map((json) => Fruit(
      id: json['id'] as String,
      name: json['name'] as String,
      englishName: json['english_name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      image: json['image'] as String? ?? '',
      colorHex: json['color_hex'] as String? ?? '#CCCCCC',
      brixMin: (json['brix_min'] as num?)?.toDouble() ?? 0,
      brixMax: (json['brix_max'] as num?)?.toDouble() ?? 0,
      calorieKcalPer100g: json['calorie_kcal_per_100g'] as int? ?? 0,
      tcmNature: json['tcm_nature'] as String? ?? '平',
      pickingTips: json['picking_tips'] as String? ?? '',
      storageTips: json['storage_tips'] as String? ?? '',
      bestEatMethod: json['best_eat_method'] as String? ?? '',
      varietyJson: json['variety_json'] as String? ?? '[]',
      gradeStd: json['grade_std'] as String? ?? '',
      aliasJson: json['alias_json'] as String? ?? '[]',
      vitaminsJson: json['vitamins_json'] as String? ?? '{}',
      mineralsJson: json['minerals_json'] as String? ?? '{}',
      benefitsJson: json['benefits_json'] as String? ?? '[]',
      contraindicationsJson: json['contraindications_json'] as String? ?? '[]',
      originsJson: json['origins_json'] as String? ?? '[]',
      peakSeason: json['peak_season'] as String? ?? '',
    )).toList();
  }
}

/// Supabase 实现的收藏仓库
class RemoteFavoriteRepository implements FavoriteRepository {
  final SupabaseClient _client;
  final String _userId;

  RemoteFavoriteRepository(this._client, this._userId);

  @override
  Future<List<Favorite>> getAllFavorites() async {
    final response = await _client.from('favorites')
        .select()
        .eq('user_id', _userId);

    return response.map((json) => Favorite(
      fruitId: json['fruit_id'] as String,
      addedAt: json['added_at'] as String,
    )).toList();
  }

  @override
  Stream<List<Favorite>> watchFavorites() {
    return _client.from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .map((list) => list.map((json) => Favorite(
          fruitId: json['fruit_id'] as String,
          addedAt: json['added_at'] as String,
        )).toList());
  }

  @override
  Future<bool> isFavorite(String fruitId) async {
    final response = await _client.from('favorites')
        .select()
        .eq('user_id', _userId)
        .eq('fruit_id', fruitId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<void> addFavorite(String fruitId) async {
    await _client.from('favorites').insert({
      'user_id': _userId,
      'fruit_id': fruitId,
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeFavorite(String fruitId) async {
    await _client.from('favorites')
        .delete()
        .eq('user_id', _userId)
        .eq('fruit_id', fruitId);
  }
}
