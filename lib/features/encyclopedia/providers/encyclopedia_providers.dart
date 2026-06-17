import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 百科搜索历史
final recentSearchesProvider = StateProvider<List<String>>((ref) => []);