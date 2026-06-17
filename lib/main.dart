import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'data/database.dart';
import 'data/seed_loader.dart';
import 'presentation/providers.dart';
import 'services/data_updater.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Supabase（认证 + 数据库 + 存储）
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  // 初始化离线数据库（原有逻辑保留）
  final db = AppDatabase();
  final updater = DataUpdater();
  await updater.ensureLocalCopy();
  await SeedLoader(db, updater).ensureLoaded();
  await NotificationService.instance.init();

  // 初始城市：优先 user_pref last_city；否则尝试定位；否则 beijing
  String initialCity = 'beijing';
  final lastCity = await db.getPref('last_city');
  if (lastCity != null) {
    initialCity = lastCity;
  } else {
    try {
      final guess = await LocationService(db).currentCityId();
      if (guess != null) initialCity = guess;
    } catch (_) {}
  }

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        dataUpdaterProvider.overrideWithValue(updater),
        selectedCityIdProvider.overrideWith((ref) => initialCity),
      ],
      child: const ShilingFruitApp(),
    ),
  );
}
