/// 帖子数据模型
class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.type,
    this.title = '',
    this.content = '',
    this.fruitId,
    this.fruitName,
    this.cityId,
    this.latitude,
    this.longitude,
    this.tags = const [],
    this.status = 'approved',
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.viewCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.nickname = '',
    this.avatarUrl = '',
    this.images = const [],
    this.isLiked = false,
    this.isBookmarked = false,
  });

  final int id;
  final String userId;
  final String type;
  final String title;
  final String content;
  final String? fruitId;
  final String? fruitName;
  final String? cityId;
  final double? latitude;
  final double? longitude;
  final List<String> tags;
  final String status;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String nickname;
  final String avatarUrl;
  final List<String> images;
  final bool isLiked;
  final bool isBookmarked;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      type: json['type'] as String? ?? 'share',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      fruitId: json['fruit_id'] as String?,
      fruitName: json['fruit_name'] as String?,
      cityId: json['city_id'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] as String? ?? 'approved',
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      bookmarkCount: json['bookmark_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      nickname: json['nickname'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      isLiked: json['is_liked'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'title': title,
        'content': content,
        'fruit_id': fruitId,
        'city_id': cityId,
        'tags': tags,
        'status': status,
      };
}