/// 用户资料模型
class ProfileModel {
  const ProfileModel({
    required this.id,
    this.nickname = '',
    this.avatarUrl = '',
    this.bio = '',
    this.cityId = '',
    this.level = 1,
    this.score = 0,
    this.postCount = 0,
    this.likeReceived = 0,
  });

  final String id;
  final String nickname;
  final String avatarUrl;
  final String bio;
  final String cityId;
  final int level;
  final int score;
  final int postCount;
  final int likeReceived;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      cityId: json['city_id'] as String? ?? '',
      level: json['level'] as int? ?? 1,
      score: json['score'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
      likeReceived: json['like_received'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'avatar_url': avatarUrl,
        'bio': bio,
        'city_id': cityId,
      };
}