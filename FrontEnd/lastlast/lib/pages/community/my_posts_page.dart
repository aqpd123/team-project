import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/community_controller.dart';
import '../../models/community_post.dart';
import '../../shared/widgets/mystic_background.dart';
import '../../shared/widgets/post_card.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({
    super.key,
    this.onBack,
    this.onWritePost,
    this.fromMore = false,
  });

  final VoidCallback? onBack;
  final VoidCallback? onWritePost;
  final bool fromMore;

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  String _activeTab = 'anonymous';
  List<CommunityPost> _myPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final community = CommunityScope.of(context);
      final posts = await community.getMyPosts();
      if (mounted) {
        setState(() {
          _myPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '게시글을 불러오는 중 오류가 발생했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _myPosts.where((post) {
      if (_activeTab == 'anonymous') {
        return post.category == BoardCategory.anonymous;
      } else {
        return post.category == BoardCategory.ohang;
      }
    }).toList();

    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _circleButton(Icons.arrow_back, widget.onBack),
                    const SizedBox(width: 12),
                    Expanded(
                      child: const Text(
                        '나의 글 관리',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 8),
            const Text(
              '작성한 게시글을 확인하고 관리하세요',
              style: TextStyle(color: Color(0xFFA5F3FC)),
            ),
            const SizedBox(height: 16),
            _tabBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadMyPosts,
                                child: const Text('다시 시도'),
                              ),
                            ],
                          ),
                        )
                      : filtered.isEmpty
                          ? _emptyState()
                          : RefreshIndicator(
                              onRefresh: _loadMyPosts,
                              child: ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final post = filtered[index];
                                  return PostCard(
                                    title: post.title,
                                    content: post.content,
                                    author: '',
                                    dateLabel: post.dateLabel,
                                    likes: post.likeCount,
                                    comments: post.commentCount,
                                    onTap: () {
                                      // 게시글 상세 페이지로 이동 (나의 글 관리에서 왔다는 정보 전달)
                                      final queryParams = widget.fromMore ? '?from=my-posts&fromMore=true' : '?from=my-posts';
                                      context.push('/posts/${post.id}$queryParams');
                                    },
                                  );
                                },
                              ),
                            ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _tabButton('익명 게시판', 'anonymous'),
          _tabButton('오행 게시판', 'ohang'),
        ],
      ),
    );
  }

  Widget _tabButton(String label, String value) {
    final selected = _activeTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFACC15) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.description_outlined,
                color: Colors.white54, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            '작성한 글이 없어요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '첫 번째 글을 작성해보세요!',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onWritePost,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFACC15),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('글쓰기 시작하기'),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

