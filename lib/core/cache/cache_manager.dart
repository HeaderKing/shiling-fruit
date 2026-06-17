import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 缓存数据包装
class CachedData<T> {
  CachedData({
    required this.value,
    required this.expiresAt,
  });

  final T value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson(Object encodedValue) => {
        'value': encodedValue,
        'expires_at': expiresAt.toIso8601String(),
      };

  factory CachedData.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) decoder,
  ) {
    return CachedData(
      value: decoder(json['value']),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}

/// 离线缓存管理器
class CacheManager {
  CacheManager._();

  static const _feedTTL = Duration(minutes: 30);

  /// 读取缓存
  static Future<CachedData<dynamic>?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final data = CachedData.fromJson(json, (v) => v);
      if (data.isExpired) {
        await prefs.remove(key);
        return null;
      }
      return data;
    } catch (_) {
      await prefs.remove(key);
      return null;
    }
  }

  /// 写入缓存
  static Future<void> set<T>(
    String key,
    Object value, {
    Duration? ttl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = CachedData<Object>(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? _feedTTL),
    );
    await prefs.setString(key, jsonEncode(data.toJson(value as Object)));
  }

  /// 清除所有缓存
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

/// 缓存管理器 Provider
final cacheManagerProvider = Provider<CacheManager>((ref) => CacheManager._());