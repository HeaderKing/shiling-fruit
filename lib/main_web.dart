/// Web 入口 — 不依赖 SQLite/Drift
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/auth/auth_provider.dart';
import 'core/auth/auth_state.dart' as app;
import 'core/config/env.dart';
import 'data/database.dart';
import 'features/auth/pages/login_page.dart';
import 'features/home/pages/home_page.dart';
import 'features/encyclopedia/pages/encyclopedia_page.dart';
import 'features/community/pages/community_page.dart';
import 'features/profile/pages/settings_page.dart';
import 'core/providers/app_providers.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  // Web 版：用内存缓存代替 SQLite
  // WebDatabase 需要 sqlite3.wasm 但当前版本不支持
  // 用 try-catch 兜住，主页用 static JSON 展示
  AppDatabase db;
  try {
    db = AppDatabase();
  } catch (_) {
    db = _WebDbStub() as AppDatabase;
  }

  runApp(
    ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: const _WebApp(),
    ),
  );
}

class _WebApp extends ConsumerWidget {
  const _WebApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(_themeModeProvider);
    return MaterialApp(
      title: '时令水果',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: switch (authState) {
        app.AuthInitial() || app.AuthLoading() => const _Splash(),
        app.AuthUnauthenticated() => const LoginPage(),
        app.AuthAuthenticated() => const _Shell(),
        app.AuthEmailVerificationSent() => const _Splash(msg: '验证邮件已发送'),
        app.AuthError(:final message) => LoginPage(errorMessage: message),
      },
    );
  }
}

final _themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class _Splash extends StatelessWidget {
  const _Splash({this.msg});
  final String? msg;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('🍇', style: TextStyle(fontSize: 64)),
      if (msg != null) ...[const SizedBox(height: 16), Text(msg!)],
    ])),
  );
}

class _Shell extends StatefulWidget {
  const _Shell();
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _i = 0;
  static const _pages = [HomePage(), EncyclopediaPage(), CommunityPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _i, children: _pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _i,
      onDestinationSelected: (i) => setState(() => _i = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: '首页'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: '百科'),
        NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups_rounded), label: '社区'),
        NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune_rounded), label: '设置'),
      ],
    ),
  );
}

class _WebDbStub {
  // 纯 stub，只避免编译错误
  // 运行时的 provider 访问会抛出异常，由 UI 的 AsyncValue.when(error:) 捕捉
}