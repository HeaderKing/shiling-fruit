import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database.dart';

/// 时令地图页面
class SeasonalMapPage extends ConsumerWidget {
  const SeasonalMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsync = ref.watch(allCitiesProvider);
    final month = ref.watch(monthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('$month 月时令地图'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showMapLegend(context),
          ),
        ],
      ),
      body: citiesAsync.when(
        data: (cities) => _MapView(cities: cities, month: month),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('加载失败: $e')),
      ),
    );
  }

  void _showMapLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('地图图例'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(color: Colors.red.shade400, label: '当季水果丰富 (5+ 种)'),
            _LegendItem(color: Colors.orange.shade400, label: '当季水果较多 (3-4 种)'),
            _LegendItem(color: Colors.blue.shade300, label: '当季水果较少 (1-2 种)'),
            _LegendItem(color: Colors.grey.shade400, label: '暂无数据'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _MapView extends ConsumerStatefulWidget {
  const _MapView({required this.cities, required this.month});
  final List<City> cities;
  final int month;

  @override
  ConsumerState<_MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<_MapView> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(35.0, 105.0), // 中国中心
        initialZoom: 4.5,
        minZoom: 3.0,
        maxZoom: 10.0,
      ),
      children: [
        // 地图底图 (使用 OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.shiling.fruit',
        ),

        // 城市标记
        MarkerLayer(
          markers: widget.cities.map((city) {
            return Marker(
              point: LatLng(city.lat, city.lng),
              width: 40,
              height: 40,
              child: _CityMarker(
                city: city,
                month: widget.month,
                onTap: () => _showCityDetail(city),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showCityDetail(City city) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _CityDetailSheet(
        city: city,
        month: widget.month,
      ),
    );
  }
}

/// 城市标记
class _CityMarker extends ConsumerWidget {
  const _CityMarker({
    required this.city,
    required this.month,
    required this.onTap,
  });

  final City city;
  final int month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取该城市当月的推荐数量
    final recommendationsAsync = ref.watch(
      monthRecommendationsProvider(month),
    );

    return recommendationsAsync.when(
      data: (recommendations) {
        final cityRecs = recommendations.where((r) => r.cityId == city.id).toList();
        final color = _getMarkerColor(cityRecs.length);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                cityRecs.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          shape: BoxShape.circle,
        ),
      ),
      error: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Color _getMarkerColor(int count) {
    if (count >= 5) return Colors.red.shade400;
    if (count >= 3) return Colors.orange.shade400;
    if (count >= 1) return Colors.blue.shade300;
    return Colors.grey.shade400;
  }
}

/// 城市详情底部抽屉
class _CityDetailSheet extends ConsumerWidget {
  const _CityDetailSheet({required this.city, required this.month});
  final City city;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(monthRecommendationsProvider(month));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                city.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(city.region),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$month 月时令水果:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          recommendationsAsync.when(
            data: (recommendations) {
              final cityRecs = recommendations
                  .where((r) => r.cityId == city.id)
                  .toList();

              if (cityRecs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('暂无时令水果数据'),
                  ),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cityRecs.map((rec) {
                  return FutureBuilder<Fruit?>(
                    future: ref.read(dbProvider).findFruit(rec.fruitId),
                    builder: (context, snapshot) {
                      final fruit = snapshot.data;
                      if (fruit == null) return const SizedBox.shrink();

                      return Chip(
                        avatar: Text(
                          fruit.emoji.isNotEmpty ? fruit.emoji : '🍎',
                          style: const TextStyle(fontSize: 16),
                        ),
                        label: Text(fruit.name),
                      );
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('加载失败'),
          ),
        ],
      ),
    );
  }
}
