import 'package:drift/drift.dart';

/// Web 版 —— sqlite3 没有 web 平台的 wasm 支持
/// 所有数据通过 Supabase API 提供
QueryExecutor openDbConnection() {
  throw UnsupportedError('Web 不使用本地数据库');
}