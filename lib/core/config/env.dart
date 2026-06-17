/// 环境配置
///
/// 开发时填入 Supabase 项目凭证。
/// 请勿提交真实值到 git — 使用 .env 或环境变量注入。
class Env {
  Env._();

  /// Supabase 项目 URL（Dashboard → Settings → API → Project URL）
  static const supabaseUrl = 'https://your-project.supabase.co';

  /// Supabase anon/public key（Dashboard → Settings → API → anon public）
  static const supabaseAnonKey = 'your-anon-key';
}