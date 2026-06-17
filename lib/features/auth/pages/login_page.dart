import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🍇', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 8),
                  Text(
                    '时令水果',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '知时节，食好果',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 48),

                  if (widget.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.errorMessage!,
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '邮箱',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v?.contains('@') == true ? null : '请输入有效邮箱',
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _pwdCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      prefixIcon: Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v?.length ?? 0) >= 6 ? null : '密码至少 6 位',
                  ),
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _onLogin,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('登录'),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: _onRegister,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('注册账号'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).signInWithEmail(
          _emailCtrl.text.trim(),
          _pwdCtrl.text,
        );
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).signUpWithEmail(
          _emailCtrl.text.trim(),
          _pwdCtrl.text,
        );
  }
}