import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/providers.dart';
import '../../../services/notification_service.dart';
import '../../home/pages/city_picker_page.dart';
import '../../home/pages/fruit_index_page.dart';

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

  Future<void> _checkUpdate() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(
      content: Text('正在检查更新…'),
      duration: Duration(seconds: 2),
    ));
    try {
      final result = await ref.read(dataUpdaterProvider).checkAndDownload();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(result.message)));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('更新出错：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.place_outlined),
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
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.grid_view_outlined),
            title: const Text('全部水果'),
            subtitle: const Text('浏览所有收录的水果'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const FruitIndexPage(),
            )),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, size: 22, color: Colors.grey),
                SizedBox(width: 16),
                Text('外观主题',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(54, 0, 16, 12),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('系统'),
                  icon: Icon(Icons.settings_brightness),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('亮色'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('暗色'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (s) =>
                  ref.read(themeModeProvider.notifier).state = s.first,
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('每周一推送本周时令水果'),
            value: _weeklyNotify ?? false,
            onChanged: _weeklyNotify == null ? null : _setNotify,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('检查数据更新'),
            subtitle: const Text('从 GitHub Releases 拉取最新水果/推荐数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _checkUpdate,
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('关于'),
            subtitle: Text(
                '时令水果 · 开源版\n数据来源：公开农业资料 + 营养数据库整理\n推荐评分仅供参考，实际上市受年景/产地影响'),
            isThreeLine: true,
          ),
          const ListTile(
            leading: Icon(Icons.code_outlined),
            title: Text('源代码'),
            subtitle: Text('github.com/HeaderKing/shiling-fruit'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}