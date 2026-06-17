import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/community_providers.dart';
import '../widgets/post_card.dart';
import 'new_post_page.dart';
import 'post_detail_page.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  String _feedType = 'hot';
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _openSearch(context),
          ),
        ],
      ),
      body: Column(children: [
        _FeedTypeBar(
          current: _feedType,
          onChanged: (t) => setState(() { _feedType = t; _page = 1; }),
        ),
        Expanded(child: _FeedList(feedType: _feedType, page: _page)),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const NewPostPage())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('发布'),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('搜索功能开发中')));
  }
}

class _FeedTypeBar extends StatelessWidget {
  const _FeedTypeBar({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final types = [('hot', '🔥 推荐'), ('new', '🕐 最新'), ('share', '📷 晒图'), ('guide', '📝 攻略')];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: types.map((t) {
          final selected = current == t.$1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(t.$2, style: TextStyle(
                fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              )),
              selected: selected,
              onSelected: (_) => onChanged(t.$1),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeedList extends ConsumerWidget {
  const _FeedList({required this.feedType, required this.page});
  final String feedType;
  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(feedProvider(FeedQuery(page: page, feedType: feedType)));

    return posts.when(
      loading: () => const LoadingOverlay(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(feedProvider)),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(emoji: '🌱', title: '还没有帖子', subtitle: '来分享你的水果经验吧');
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(feedProvider),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: list.length + 1,
            itemBuilder: (context, i) {
              if (i == list.length) return const SizedBox(height: 8);
              final post = list[i];
              return PostCard(
                post: post,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id))),
                onLike: () { ref.read(postRepositoryProvider).toggleLike(post.id); ref.invalidate(feedProvider); },
                onComment: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id))),
                onBookmark: () { ref.read(postRepositoryProvider).toggleBookmark(post.id); ref.invalidate(feedProvider); },
              );
            },
          ),
        );
      },
    );
  }
}