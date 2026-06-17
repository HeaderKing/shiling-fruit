/// 认证状态模型
sealed class AuthState {
  const AuthState();
}

/// 初始状态（尚未检查登录状态）
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// 未登录
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// 登录中
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// 邮箱验证已发送
class AuthEmailVerificationSent extends AuthState {
  const AuthEmailVerificationSent();
}

/// 已登录
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.userId,
    this.email,
    this.phone,
  });

  final String userId;
  final String? email;
  final String? phone;
}

/// 认证出错
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  String toString() => message;
}