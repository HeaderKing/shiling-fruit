import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// ===== Tables =====

class Cities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get province => text()();
  TextColumn get region => text()();
  TextColumn get climateZone => text().named('climate_zone')();
  RealColumn get lat => real()();
  RealColumn get lng => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class Fruits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get englishName => text().named('english_name')();
  TextColumn get image => text()();
  TextColumn get colorHex => text().named('color_hex')();
  RealColumn get brixMin => real().named('brix_min')();
  RealColumn get brixMax => real().named('brix_max')();
  IntColumn get calorieKcalPer100g =>
      integer().named('calorie_kcal_per_100g')();
  TextColumn get tcmNature => text().named('tcm_nature')();
  TextColumn get peakSeason => text().named('peak_season')();

  // 列表/对象字段 → JSON 字符串
  TextColumn get aliasJson => text().named('alias_json')();
  TextColumn get vitaminsJson => text().named('vitamins_json')();
  TextColumn get mineralsJson => text().named('minerals_json')();
  TextColumn get benefitsJson => text().named('benefits_json')();
  TextColumn get contraindicationsJson =>
      text().named('contraindications_json')();
  TextColumn get originsJson => text().named('origins_json')();

  @override
  Set<Column> get primaryKey => {id};
}

class Recommendations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cityId => text().named('city_id')();
  IntColumn get month => integer()();
  TextColumn get period => text()(); // 上旬/中旬/下旬
  TextColumn get fruitId => text().named('fruit_id')();
  IntColumn get score => integer()();
  TextColumn get reason => text()();
  TextColumn get locality => text()();
}

class Favorites extends Table {
  TextColumn get fruitId => text().named('fruit_id')();
  TextColumn get addedAt => text().named('added_at')(); // ISO 8601

  @override
  Set<Column> get primaryKey => {fruitId};
}

class UserPrefs extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ===== Database =====

@DriftDatabase(tables: [Cities, Fruits, Recommendations, Favorites, UserPrefs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ----- 查询 API -----

  Future<List<City>> allCities() => select(cities).get();

  Future<List<City>> citiesByRegion(String region) =>
      (select(cities)..where((c) => c.region.equals(region))).get();

  Future<City?> findCity(String id) =>
      (select(cities)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<Fruit?> findFruit(String id) =>
      (select(fruits)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<List<Fruit>> allFruits() => select(fruits).get();

  Future<List<Recommendation>> recommendationsFor(
      String cityId, int month, String period) {
    return (select(recommendations)
          ..where((r) =>
              r.cityId.equals(cityId) &
              r.month.equals(month) &
              r.period.equals(period))
          ..orderBy([(r) => OrderingTerm.desc(r.score)]))
        .get();
  }

  Future<List<Recommendation>> recommendationsForMonth(
      String cityId, int month) {
    return (select(recommendations)
          ..where((r) => r.cityId.equals(cityId) & r.month.equals(month))
          ..orderBy([(r) => OrderingTerm.desc(r.score)]))
        .get();
  }

  // ----- 收藏 -----

  Future<List<Favorite>> allFavorites() => select(favorites).get();

  Stream<List<Favorite>> watchFavorites() => select(favorites).watch();

  Future<bool> isFavorite(String fruitId) async {
    final r = await (select(favorites)..where((f) => f.fruitId.equals(fruitId)))
        .getSingleOrNull();
    return r != null;
  }

  Future<void> addFavorite(String fruitId) async {
    await into(favorites).insertOnConflictUpdate(FavoritesCompanion.insert(
      fruitId: fruitId,
      addedAt: DateTime.now().toIso8601String(),
    ));
  }

  Future<void> removeFavorite(String fruitId) async {
    await (delete(favorites)..where((f) => f.fruitId.equals(fruitId))).go();
  }

  // ----- UserPrefs -----

  Future<String?> getPref(String key) async {
    final r = await (select(userPrefs)..where((p) => p.key.equals(key)))
        .getSingleOrNull();
    return r?.value;
  }

  Future<void> setPref(String key, String value) async {
    await into(userPrefs).insertOnConflictUpdate(UserPrefsCompanion.insert(
      key: key,
      value: value,
    ));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'shiling_fruit.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
