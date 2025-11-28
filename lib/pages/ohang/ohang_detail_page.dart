import 'package:flutter/material.dart';

import '../../shared/widgets/mystic_background.dart';
import '../../shared/widgets/post_card.dart';

class OhangElementData {
  const OhangElementData({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });

  final String key; // fire, water, ...
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
}

class OhangPost {
  const OhangPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.dateLabel,
    required this.likes,
    required this.comments,
  });

  final String id;
  final String title;
  final String content;
  final String author;
  final String dateLabel;
  final int likes;
  final int comments;
}

class OhangDetailPage extends StatefulWidget {
  const OhangDetailPage({
    super.key,
    required this.element,
    required this.isLoggedIn,
    this.posts = const [],
    this.onBack,
    this.onNavigateToBoard,
    this.onNavigateToLogin,
    this.onWritePost,
  });

  final OhangElementData element;
  final bool isLoggedIn;
  final List<OhangPost> posts;
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToBoard;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onWritePost;

  @override
  State<OhangDetailPage> createState() => _OhangDetailPageState();
}

class _OhangDetailPageState extends State<OhangDetailPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return Scaffold(
        body: MysticBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: widget.element.gradient),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.element.icon,
                      color: Colors.white, size: 42),
                ),
                const SizedBox(height: 16),
                const Text(
                  '로그인이 필요해요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '오행 게시판을 보려면 로그인해주세요.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.onNavigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFACC15),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('로그인하러 가기'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filtered = widget.posts.where((post) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return post.title.toLowerCase().contains(q) ||
          post.content.toLowerCase().contains(q) ||
          post.author.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: MysticBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(Icons.arrow_back, widget.onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.element.gradient,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.element.icon, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.element.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.element.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _circleButton(Icons.edit_outlined, widget.onWritePost,
                    background: const Color(0xFFFACC15),
                    iconColor: Colors.black),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: '게시글을 검색해보세요...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: widget.element.gradient.first),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        '아직 게시글이 없습니다.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final post = filtered[index];
                        return PostCard(
                          title: post.title,
                          content: post.content,
                          author: post.author,
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

  Widget _circleButton(IconData icon, VoidCallback? onTap,
      {Color background = Colors.transparent, Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background == Colors.transparent
              ? Colors.white.withOpacity(0.1)
              : background,
          borderRadius: BorderRadius.circular(22),
          border: background == Colors.transparent
              ? Border.all(color: Colors.white.withOpacity(0.2))
              : null,
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}

