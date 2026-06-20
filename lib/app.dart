import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_provider.dart';
import 'core/auth/auth_state.dart' as app;
import 'core/navigation/main_shell.dart';
import 'core/providers/app_providers.dart';
import 'features/auth/pages/login_page.dart';
import 'shared/theme/app_theme.dart';

class ShilingFruitApp extends ConsumerWidget {
  const ShilingFruitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: '时令水果',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(app.AuthState authState) {
    return switch (authState) {
      app.AuthInitial() => const _SplashScreen(),
      app.AuthLoading() => const _SplashScreen(),
      app.AuthUnauthenticated() => const LoginPage(),
      app.AuthEmailVerificationSent() => const _EmailVerificationSentPage(),
      app.AuthAuthenticated() => const MainShell(),
      app.AuthError(:final message) => LoginPage(errorMessage: message),
    };
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🍇', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _EmailVerificationSentPage extends StatelessWidget {
  const _EmailVerificationSentPage();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_unread_rounded,
                  size: 64, color: scheme.primary),
              const SizedBox(height: 16),
              const Text(
                '验证邮件已发送',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '请检查你的邮箱并点击验证链接',
                style: TextStyle(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
