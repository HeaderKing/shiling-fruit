import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_exception.dart';

/// 统一 API 客户端
///
/// 封装 Supabase 客户端，提供泛型 CRUD 操作和统一错误处理。
class ApiClient {
  ApiClient(this._supabase);

  final SupabaseClient _supabase;

  /// 获取单条记录
  Future<Map<String, dynamic>> fetchOne(
    String table, {
    String select = '*',
    Map<String, dynamic>? filters,
  }) async {
    try {
      final query = _supabase.from(table).select(select) as dynamic;
      if (filters != null) {
        for (final entry in filters.entries) {
          query.eq(entry.key, entry.value);
        }
      }
      final result = await query.single();
      return result as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('获取 $table 失败', e.toString());
    }
  }

  /// 获取列表
  Future<List<Map<String, dynamic>>> fetchList(
    String table, {
    String select = '*',
    int? limit,
    int? offset,
    String? order,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final query = _supabase.from(table).select(select) as dynamic;
      if (filters != null) {
        for (final entry in filters.entries) {
          query.eq(entry.key, entry.value);
        }
      }
      if (order != null) {
        final parts = order.split(' ');
        final ascending = parts.length > 1 && parts[1] == 'asc';
        query.order(parts[0], ascending: ascending);
      }
      if (limit != null) {
        final start = offset ?? 0;
        query.range(start, start + limit - 1);
      }
      final result = await query;
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw ApiException('列表查询失败', e.toString());
    }
  }

  /// 插入记录
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final result =
          await _supabase.from(table).insert(data).select().single();
      return result as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('创建失败', e.toString());
    }
  }

  /// 更新记录
  Future<void> update(
    String table,
    Map<String, dynamic> data,
    Map<String, dynamic> filters,
  ) async {
    try {
      final query = _supabase.from(table).update(data) as dynamic;
      for (final entry in filters.entries) {
        query.eq(entry.key, entry.value);
      }
      await query;
    } catch (e) {
      throw ApiException('更新失败', e.toString());
    }
  }

  /// 删除记录
  Future<void> delete(String table, Map<String, dynamic> filters) async {
    try {
      final query = _supabase.from(table).delete() as dynamic;
      for (final entry in filters.entries) {
        query.eq(entry.key, entry.value);
      }
      await query;
    } catch (e) {
      throw ApiException('删除失败', e.toString());
    }
  }
}

/// API 客户端 Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(Supabase.instance.client);
});