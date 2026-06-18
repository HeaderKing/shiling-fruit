import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_state.dart' as app;

/// 认证状态管理
class AuthNotifier extends StateNotifier<app.AuthState> {
  AuthNotifier() : super(const app.AuthInitial()) {
    _subscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((event) {
      final session = event.session;
      if (session != null) {
        state = app.AuthAuthenticated(
          userId: session.user.id,
          email: session.user.email,
          phone: session.user.phone,
        );
      } else {
        state = const app.AuthUnauthenticated();
      }
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const app.AuthLoading();
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      state = app.AuthError(e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const app.AuthLoading();
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      state = const app.AuthEmailVerificationSent();
    } catch (e) {
      state = app.AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, app.AuthState>((ref) {
  return AuthNotifier();
});

/// 是否已登录（只读）
final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(authProvider);
  return state is app.AuthAuthenticated;
});

/// 当前用户 ID（只读）
final currentUserIdProvider = Provider<String?>((ref) {
  final state = ref.watch(authProvider);
  if (state is app.AuthAuthenticated) return state.userId;
  return null;
});