import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';

/// Feed 查询参数
class FeedQuery {
  const FeedQuery({this.page = 1, this.feedType = 'hot', this.cityId});
  final int page;
  final String feedType;
  final String? cityId;

  @override
  bool operator ==(Object o) =>
      o is FeedQuery &&
      o.page == page &&
      o.feedType == feedType &&
      o.cityId == cityId;

  @override
  int get hashCode => Object.hash(page, feedType, cityId);
}

/// Feed Provider（分页）
final feedProvider =
    FutureProvider.family<List<PostModel>, FeedQuery>((ref, query) {
  return ref.watch(postRepositoryProvider).getFeed(
        page: query.page,
        feedType: query.feedType,
        cityId: query.cityId,
      );
});

/// 帖子详情 Provider
final postDetailProvider =
    FutureProvider.family<PostModel?, int>((ref, postId) async {
  try {
    return await ref.watch(postRepositoryProvider).getPostDetail(postId);
  } catch (_) {
    return null;
  }
});