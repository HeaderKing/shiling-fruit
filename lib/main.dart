import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/seed_loader.dart';
import 'presentation/providers.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await SeedLoader(db).ensureLoaded();
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
        selectedCityIdProvider.overrideWith((ref) => initialCity),
      ],
      child: const ShilingFruitApp(),
    ),
  );
}
