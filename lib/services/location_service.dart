import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../data/database.dart';

class LocationService {
  LocationService(this._db);
  final AppDatabase _db;

  /// 尝试获取设备位置，返回最近的城市 id。
  /// 失败（无权限、定位关闭、桌面平台不支持等）时返回 null，UI 应降级到上次选中或默认。
  Future<String?> currentCityId() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          return null;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return nearestCityId(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// 用大圆距离近似（Haversine），从 cities 表里找最近的城市。
  Future<String?> nearestCityId(double lat, double lng) async {
    final cities = await _db.allCities();
    if (cities.isEmpty) return null;
    City best = cities.first;
    double bestDist = _distKm(lat, lng, best.lat, best.lng);
    for (final c in cities.skip(1)) {
      final d = _distKm(lat, lng, c.lat, c.lng);
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    return best.id;
  }

  static double _distKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double d) => d * (math.pi / 180.0);
}
