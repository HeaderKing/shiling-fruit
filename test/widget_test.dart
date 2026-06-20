import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shiling_fruit/app.dart';
import 'package:shiling_fruit/data/database.dart';
import 'package:shiling_fruit/core/providers/app_providers.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 创建一个 mock 数据库
    final db = AppDatabase();

    // 构建应用
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
        ],
        child: const ShilingFruitApp(),
      ),
    );

    // 验证应用能正常启动
    expect(find.text('🍇 时令水果'), findsWidgets);
  });
}
