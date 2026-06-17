import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

/// 帖子数据仓库
class PostRepository {
  PostRepository(this._api);

  final ApiClient _api;

  /// 获取 Feed 列表
  Future<List<PostModel>> getFeed({
    int page = 1,
    String feedType = 'hot',
    String? cityId,
    String? fruitId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      const pageSize = 20;
      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final query = supabase
          .from('posts')
          .select('''
            id, user_id, type, title, content, fruit_id, city_id,
            like_count, comment_count, bookmark_count, created_at,
            profiles!inner(nickname, avatar_url)
          ''')
          .eq('status', 'approved') as dynamic;

      if (cityId != null) query.eq('city_id', cityId);
      if (fruitId != null) query.eq('fruit_id', fruitId);

      if (feedType == 'hot') {
        query.order('like_count', ascending: false);
      } else {
        query.order('created_at', ascending: false);
      }

      query.range(from, to);

      final result = await query;
      return result.map((j) => _parsePostFromJoined(j)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('获取帖子列表失败', e.toString());
    }
  }

  /// 获取帖子详情
  Future<PostModel> getPostDetail(int postId) async {
    try {
      final data =
          await _api.fetchOne('posts', filters: {'id': postId});
      final images = await Supabase.instance.client
          .from('post_images')
          .select('url')
          .eq('post_id', postId)
          .order('sort_order');
      data['images'] = images.map((i) => i['url'] as String).toList();
      return PostModel.fromJson(data);
    } catch (e) {
      throw ApiException('获取帖子详情失败', e.toString());
    }
  }

  /// 获取评论
  Future<List<CommentModel>> getComments(int postId) async {
    try {
      final supabase = Supabase.instance.client;
      final result = await supabase
          .from('comments')
          .select('''
            id, post_id, user_id, parent_id, content, like_count, created_at,
            profiles!inner(nickname, avatar_url)
          ''')
          .eq('post_id', postId)
          .order('created_at');
      return result.map((j) => _parseCommentFromJoined(j)).toList();
    } catch (e) {
      throw ApiException('获取评论失败', e.toString());
    }
  }

  /// 发布评论
  Future<CommentModel> addComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    try {
      final data = await _api.insert('comments', {
        'post_id': postId,
        'user_id': Supabase.instance.client.auth.currentUser!.id,
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      });
      return CommentModel.fromJson(data);
    } catch (e) {
      throw ApiException('发布评论失败', e.toString());
    }
  }

  /// 切换点赞
  Future<bool> toggleLike(int postId) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final existing = await supabase
          .from('likes')
          .select()
          .eq('user_id', userId)
          .eq('target_type', 'post')
          .eq('target_id', postId)
          .maybeSingle();
      if (existing != null) {
        await supabase.from('likes').delete().eq('user_id', userId).eq(
            'target_type', 'post').eq('target_id', postId);
        return false;
      } else {
        await supabase.from('likes').insert({
          'user_id': userId,
          'target_type': 'post',
          'target_id': postId,
        });
        return true;
      }
    } catch (e) {
      throw ApiException('点赞失败', e.toString());
    }
  }

  /// 切换收藏
  Future<bool> toggleBookmark(int postId) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final existing = await supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();
      if (existing != null) {
        await supabase
            .from('bookmarks')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', postId);
        return false;
      } else {
        await supabase.from('bookmarks').insert({
          'user_id': userId,
          'post_id': postId,
        });
        return true;
      }
    } catch (e) {
      throw ApiException('收藏失败', e.toString());
    }
  }

  PostModel _parsePostFromJoined(Map<String, dynamic> j) {
    final profile = j['profiles'] as Map<String, dynamic>?;
    j['nickname'] = profile?['nickname'] as String? ?? '';
    j['avatar_url'] = profile?['avatar_url'] as String? ?? '';
    j.remove('profiles');
    return PostModel.fromJson(j);
  }

  CommentModel _parseCommentFromJoined(Map<String, dynamic> j) {
    final profile = j['profiles'] as Map<String, dynamic>?;
    j['nickname'] = profile?['nickname'] as String? ?? '';
    j['avatar_url'] = profile?['avatar_url'] as String? ?? '';
    j.remove('profiles');
    return CommentModel.fromJson(j);
  }
}

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(apiClientProvider));
});