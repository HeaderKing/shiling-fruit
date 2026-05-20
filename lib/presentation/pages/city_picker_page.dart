import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class CityPickerPage extends ConsumerWidget {
  const CityPickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(citiesByRegionProvider);
    final selected = ref.watch(selectedCityIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('选择城市')),
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
