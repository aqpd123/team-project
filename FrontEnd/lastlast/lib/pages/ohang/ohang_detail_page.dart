import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/community_controller.dart';
import '../../models/community_post.dart';
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

class OhangDetailPage extends StatefulWidget {
  const OhangDetailPage({
    super.key,
    required this.element,
    required this.isLoggedIn,
    this.onBack,
    this.onNavigateToBoard,
    this.onNavigateToLogin,
    this.onWritePost,
    this.onOpenPost,
  });

  final OhangElementData element;
  final bool isLoggedIn;
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToBoard;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onWritePost;
  final ValueChanged<int>? onOpenPost;

  @override
  State<OhangDetailPage> createState() => _OhangDetailPageState();
}

class _OhangDetailPageState extends State<OhangDetailPage> {
  String _search = '';
  bool _requestedFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeFetchInitial();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return _buildLoginRequired();
    }

    final community = CommunityScope.of(context);
    return AnimatedBuilder(
      animation: community,
      builder: (context, _) {
        final posts = community.posts
            .where((post) => post.ohangKey == widget.element.key)
            .toList();
        final filtered = posts.where(_matchesSearch).toList();
        return Scaffold(
          body: MysticBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),
                _searchField(),
                const SizedBox(height: 16),
                if (community.error != null)
                  _errorBanner(community.error!),
                Expanded(
                  child: community.isLoading && posts.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : filtered.isEmpty
                          ? const Center(
                              child: Text(
                                '아직 게시글이 없습니다.',
                                style:
                                    TextStyle(color: Colors.white70),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: community.refreshPosts,
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final post = filtered[index];
                                  return PostCard(
                                    title: post.title,
                                    content: post.content,
                                    author: post.authorLabel,
                                    dateLabel: post.dateLabel,
                                    likes: post.likeCount,
                                    comments: post.commentCount,
                                    onTap: () => widget.onOpenPost?.call(post.id),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginRequired() {
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

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
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
          _circleButton(
            Icons.mode_edit_outline,
            widget.onWritePost,
            background: const Color(0xFFFACC15),
            iconColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        onChanged: (value) => setState(() => _search = value),
        decoration: InputDecoration(
          hintText: '게시글을 검색해보세요...',
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                BorderSide(color: widget.element.gradient.first),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
        ),
      ),
    );
  }

  bool _matchesSearch(CommunityPost post) {
    if (_search.isEmpty) return true;
    final query = _search.toLowerCase();
    return post.title.toLowerCase().contains(query) ||
        post.content.toLowerCase().contains(query) ||
        post.authorLabel.toLowerCase().contains(query);
  }

  void _maybeFetchInitial() {
    if (_requestedFetch || !widget.isLoggedIn) return;
    final community = CommunityScope.of(context);
    _requestedFetch = true;
    unawaited(community.ensureLoaded());
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
              ? Colors.white.withValues(alpha: 0.1)
              : background,
          borderRadius: BorderRadius.circular(22),
          border: background == Colors.transparent
              ? Border.all(color: Colors.white.withValues(alpha: 0.2))
              : null,
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}

