import 'package:flutter/material.dart';

import '../../shared/widgets/mystic_background.dart';
import '../../shared/widgets/post_card.dart';

class MyPost {
  const MyPost({
    required this.id,
    required this.title,
    required this.content,
    required this.dateLabel,
    required this.likes,
    required this.comments,
    required this.category,
  });

  final String id;
  final String title;
  final String content;
  final String dateLabel;
  final int likes;
  final int comments;
  final String category; // anonymous or ohang
}

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({
    super.key,
    this.posts = const [],
    this.onBack,
    this.onWritePost,
  });

  final List<MyPost> posts;
  final VoidCallback? onBack;
  final VoidCallback? onWritePost;

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  String _activeTab = 'anonymous';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.posts
        .where((post) => post.category == _activeTab)
        .toList(growable: false);

    return Scaffold(
      body: MysticBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _circleButton(Icons.arrow_back, widget.onBack),
                const SizedBox(width: 12),
                const Text(
                  '나의 글 관리',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
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
              child: filtered.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final post = filtered[index];
                        return PostCard(
                          title: post.title,
                          content: post.content,
                          author:
                              post.category == 'anonymous' ? '익명' : '오행 게시판',
                          dateLabel: post.dateLabel,
                          likes: post.likes,
                          comments: post.comments,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
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
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
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
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

