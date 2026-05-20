import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/notification_service.dart';
import '../providers.dart';
import 'city_picker_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool? _weeklyNotify;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await ref.read(dbProvider).getPref('weekly_notify');
    if (mounted) setState(() => _weeklyNotify = v == '1');
  }

  Future<void> _setNotify(bool on) async {
    setState(() => _weeklyNotify = on);
    await ref.read(dbProvider).setPref('weekly_notify', on ? '1' : '0');
    if (on) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleWeeklyReminder();
    } else {
      await NotificationService.instance.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text('默认城市'),
            subtitle: city.maybeWhen(
              data: (c) => Text(c?.name ?? '未设置'),
              orElse: () => const Text('加载中…'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const CityPickerPage(),
            )),
          ),
          const Divider(height: 0),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('每周一推送本周时令水果'),
            value: _weeklyNotify ?? false,
            onChanged: _weeklyNotify == null ? null : _setNotify,
          ),
          const Divider(height: 0),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('关于'),
            subtitle: Text(
                '时令水果 · 开源版\n数据来源：公开农业资料 + 营养数据库整理\n推荐评分仅供参考，实际上市受年景/产地影响'),
            isThreeLine: true,
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('源代码'),
            subtitle: Text('github.com/<your-username>/shiling-fruit'),
          ),
        ],
      ),
    );
  }
}
