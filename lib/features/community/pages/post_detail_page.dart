import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/network_image.dart';
import '../providers/community_providers.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.postId});
  final int postId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    return Scaffold(
      appBar: AppBar(title: const Text('帖子'), actions: [
        IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
      ]),
      body: postAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (post) {
          if (post == null) return const ErrorView(message: '帖子不存在');
          return ListView(padding: const EdgeInsets.all(16), children: [
            _UserHeader(post: post),
            if (post.title.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 8),
            Text(post.content, style: const TextStyle(fontSize: 15, height: 1.6)),
            const SizedBox(height: 12),
            if (post.images.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: post.images.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppNetworkImage(url: post.images[i], fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(children: [
              _StatButton(Icons.favorite_rounded, post.likeCount, () => _toggleLike(post)),
              const SizedBox(width: 20),
              _StatButton(Icons.chat_bubble_outline_rounded, post.commentCount, null),
              const SizedBox(width: 20),
              _StatButton(Icons.bookmark_outline_rounded, post.bookmarkCount, () => _toggleBookmark(post)),
            ]),
            const Divider(height: 32),
            const Text('评论', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _CommentList(postId: widget.postId),
          ]);
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _commentCtrl,
            decoration: const InputDecoration(hintText: '写评论…', border: InputBorder.none, contentPadding: EdgeInsets.zero),
          )),
          IconButton(icon: const Icon(Icons.send_rounded), onPressed: _submitComment),
        ]),
      ),
    );
  }

  Future<void> _submitComment() async {
    final content = _commentCtrl.text.trim();
    if (content.isEmpty) return;
    try {
      await ref.read(postRepositoryProvider).addComment(postId: widget.postId, content: content);
      _commentCtrl.clear();
      ref.invalidate(postDetailProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('评论失败：$e')));
    }
  }

  Future<void> _toggleLike(PostModel post) async {
    await ref.read(postRepositoryProvider).toggleLike(post.id);
    ref.invalidate(postDetailProvider);
  }

  Future<void> _toggleBookmark(PostModel post) async {
    await ref.read(postRepositoryProvider).toggleBookmark(post.id);
    ref.invalidate(postDetailProvider);
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.post});
  final PostModel post;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: scheme.primaryContainer,
        backgroundImage: post.avatarUrl.isNotEmpty ? NetworkImage(post.avatarUrl) : null,
        child: post.avatarUrl.isEmpty ? Text(post.nickname.isNotEmpty ? post.nickname[0] : '?') : null,
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(post.nickname, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('${post.createdAt.month}/${post.createdAt.day} ${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
      ]),
    ]);
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton(this.icon, this.count, this.onTap);
  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 20), const SizedBox(width: 4), Text('$count'),
      ]),
    );
  }
}

class _CommentList extends ConsumerWidget {
  const _CommentList({required this.postId});
  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(_commentsProvider(postId));
    return commentsAsync.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
      error: (_, __) => const Text('评论加载失败'),
      data: (comments) {
        if (comments.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('暂无评论'));
        return Column(children: comments.map((c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 14,
                child: Text(c.nickname.isNotEmpty ? c.nickname[0] : '?', style: const TextStyle(fontSize: 12))),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.nickname, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(c.content, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text(_timeAgo(c.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ])),
          ]),
        )).toList());
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    return '${diff.inDays} 天前';
  }
}

final _commentsProvider = FutureProvider.family<List<CommentModel>, int>((ref, postId) {
  return ref.watch(postRepositoryProvider).getComments(postId);
});