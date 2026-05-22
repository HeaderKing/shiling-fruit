import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class CityPickerPage extends ConsumerWidget {
  const CityPickerPage({super.key});

  Future<void> _locate(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(
      content: Text('正在定位…'),
      duration: Duration(seconds: 2),
    ));
    final cityId = await ref.read(locationServiceProvider).currentCityId();
    if (!context.mounted) return;
    if (cityId == null) {
      messenger.showSnackBar(const SnackBar(
        content: Text('定位失败：请检查权限或开启位置服务'),
      ));
      return;
    }
    ref.read(selectedCityIdProvider.notifier).state = cityId;
    await ref.read(dbProvider).setPref('last_city', cityId);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(citiesByRegionProvider);
    final selected = ref.watch(selectedCityIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择城市'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: '使用当前定位',
            onPressed: () => _locate(context, ref),
          ),
        ],
      ),
      body: regions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
        data: (map) => ListView(
          children: [
            for (final region in map.keys)
              ExpansionTile(
                title: Text('$region  (${map[region]!.length})'),
                initiallyExpanded: map[region]!.any((c) => c.id == selected),
                children: [
                  for (final c in map[region]!)
                    ListTile(
                      title: Text(c.name),
                      subtitle: Text(c.province),
                      trailing: c.id == selected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () async {
                        ref.read(selectedCityIdProvider.notifier).state = c.id;
                        await ref.read(dbProvider).setPref('last_city', c.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
