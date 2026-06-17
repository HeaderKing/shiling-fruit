import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database.dart';
import '../../../presentation/providers.dart';

/// 月度推荐（用于 calendar_page）
final monthRecommendationsProvider =
    FutureProvider.family<List<Recommendation>, int>((ref, month) async {
  final cityId = ref.watch(selectedCityIdProvider);
  return ref.watch(dbProvider).recommendationsForMonth(cityId, month);
});