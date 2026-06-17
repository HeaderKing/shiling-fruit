/// 评论数据模型
class CommentModel {
  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    this.likeCount = 0,
    required this.createdAt,
    this.nickname = '',
    this.avatarUrl = '',
    this.replies = const [],
  });

  final int id;
  final int postId;
  final String userId;
  final int? parentId;
  final String content;
  final int likeCount;
  final DateTime createdAt;
  final String nickname;
  final String avatarUrl;
  final List<CommentModel> replies;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as int?,
      content: json['content'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      nickname: json['nickname'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}