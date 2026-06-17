import 'package:flutter/material.dart';

import '../../../data/models/post_model.dart';
import '../../../shared/widgets/network_image.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onBookmark,
  });

  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    if (diff.inDays < 30) return '${diff.inDays} 天前';
    return '${diff.inDays ~/ 30} 个月前';
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'guide': return '攻略';
      case 'experience': return '心得';
      case 'question': return '求助';
      default: return '晒图';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage: post.avatarUrl.isNotEmpty
                        ? NetworkImage(post.avatarUrl) : null,
                    child: post.avatarUrl.isEmpty
                        ? Text(post.nickname.isNotEmpty ? post.nickname[0] : '?')
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.nickname,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('${_timeAgo(post.createdAt)} · ${_typeLabel(post.type)}',
                          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    ],
                  )),
                  if (post.type == 'guide')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('精选',
                          style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600)),
                    ),
                ]),
                const SizedBox(height: 10),
                if (post.fruitName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('🍑 ${post.fruitName}',
                        style: TextStyle(fontSize: 12, color: scheme.onPrimaryContainer)),
                  ),
                if (post.fruitName != null) const SizedBox(height: 8),
                if (post.title.isNotEmpty) ...[
                  Text(post.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                ],
                if (post.content.isNotEmpty)
                  Text(post.content,
                      style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                if (post.content.isNotEmpty) const SizedBox(height: 8),
                if (post.images.isNotEmpty) _buildImageGrid(context, post.images),
                const SizedBox(height: 10),
                Row(children: [
                  _InteractionButton(
                    icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    color: post.isLiked ? Colors.red.shade400 : null,
                    count: post.likeCount, onTap: onLike,
                  ),
                  const SizedBox(width: 16),
                  _InteractionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    count: post.commentCount, onTap: onComment,
                  ),
                  const SizedBox(width: 16),
                  _InteractionButton(
                    icon: post.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: post.isBookmarked ? scheme.primary : null,
                    count: post.bookmarkCount, onTap: onBookmark,
                  ),
                  const Spacer(),
                  Icon(Icons.share_outlined, size: 18, color: scheme.onSurfaceVariant),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<String> images) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AppNetworkImage(url: images[0], height: 200, width: double.infinity, fit: BoxFit.cover),
      );
    }
    if (images.length == 2) {
      return Row(children: [
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12),
            child: AppNetworkImage(url: images[0], height: 150))),
        const SizedBox(width: 4),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12),
            child: AppNetworkImage(url: images[1], height: 150))),
      ]);
    }
    return SizedBox(
      height: (MediaQuery.of(context).size.width - 60) / 3,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4,
        ),
        itemCount: images.length > 9 ? 9 : images.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AppNetworkImage(url: images[i], fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  const _InteractionButton({required this.icon, this.count = 0, this.color, this.onTap});
  final IconData icon;
  final int count;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: color),
        if (count > 0) ...[const SizedBox(width: 3), Text('$count', style: TextStyle(fontSize: 12, color: color))],
      ]),
    );
  }
}