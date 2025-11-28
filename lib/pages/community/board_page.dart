import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/bottom_navigation_bar.dart';
import '../../shared/widgets/mystic_background.dart';
import '../../shared/widgets/post_card.dart';

enum BoardCategory { anonymous, ohang }

class BoardPost {
  const BoardPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.dateLabel,
    required this.likes,
    required this.comments,
    required this.category,
  });

  final String id;
  final String title;
  final String content;
  final String author;
  final String dateLabel;
  final int likes;
  final int comments;
  final BoardCategory category;
}

class BoardPage extends StatefulWidget {
  const BoardPage({
    super.key,
    required this.isLoggedIn,
    this.posts = const [],
    this.onNavigateToLogin,
    this.onNavigateToWritePost,
    this.onNavigateToMessages,
    this.onNavigateToFriends,
    this.onNavigateToOhangFire,
    this.onNavigateToOhangWater,
    this.onNavigateToOhangWood,
    this.onNavigateToOhangMetal,
    this.onNavigateToOhangEarth,
  });

  final bool isLoggedIn;
  final List<BoardPost> posts;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onNavigateToWritePost;
  final VoidCallback? onNavigateToMessages;
  final VoidCallback? onNavigateToFriends;
  final VoidCallback? onNavigateToOhangFire;
  final VoidCallback? onNavigateToOhangWater;
  final VoidCallback? onNavigateToOhangWood;
  final VoidCallback? onNavigateToOhangMetal;
  final VoidCallback? onNavigateToOhangEarth;

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  BoardCategory _activeTab = BoardCategory.anonymous;
  String _searchQuery = '';
  late List<BoardPost> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = _filterPosts();
  }

  @override
  void didUpdateWidget(BoardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.posts != widget.posts) {
      setState(() {
        _filtered = _filterPosts();
      });
    }
  }

  List<BoardPost> _filterPosts() {
    return widget.posts.where((post) {
      if (post.category != _activeTab) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return post.title.toLowerCase().contains(q) ||
          post.content.toLowerCase().contains(q) ||
          post.author.toLowerCase().contains(q);
    }).toList();
  }

  void _setTab(BoardCategory category) {
    setState(() {
      _activeTab = category;
      _searchQuery = '';
      _filtered = _filterPosts();
    });
  }

  void _handleSearch(String value) {
    setState(() {
      _searchQuery = value;
      _filtered = _filterPosts();
    });
  }

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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFACC15), Color(0xFFF97316)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_outlined,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  '로그인이 필요해요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '사주 이야기를 공유하려면 로그인 해주세요.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text('로그인하러 가기'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            const AppBottomNavigationBar(currentPath: '/board'),
      );
    }

    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '사주 이야기 💬',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        _roundButton(
                          icon: Icons.mode_edit_outline,
                          background: const Color(0xFFFACC15),
                          iconColor: Colors.black,
                          onTap: widget.onNavigateToWritePost,
                        ),
                        const SizedBox(width: 8),
                        _roundButton(
                          icon: Icons.mail_outline,
                          onTap: widget.onNavigateToMessages,
                        ),
                        const SizedBox(width: 8),
                        _roundButton(
                          icon: Icons.group_outlined,
                          onTap: widget.onNavigateToFriends,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '사주 경험을 나누고 소통해보세요',
                  style: TextStyle(color: Color(0xFFA5F3FC)),
                ),
                const SizedBox(height: 16),
                _tabSwitch(),
                const SizedBox(height: 16),
                _searchField(),
                const SizedBox(height: 16),
                if (_activeTab == BoardCategory.ohang) ...[
                  _ohangLinks(),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: _filtered.isEmpty
                      ? const SizedBox.shrink()
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final post = _filtered[index];
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
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentPath: '/board'),
    );
  }

  Widget _tabSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _tabButton(
            label: '익명 게시판',
            selected: _activeTab == BoardCategory.anonymous,
            onTap: () => _setTab(BoardCategory.anonymous),
          ),
          _tabButton(
            label: '오행 게시판',
            selected: _activeTab == BoardCategory.ohang,
            onTap: () => _setTab(BoardCategory.ohang),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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

  Widget _searchField() {
    return TextField(
      onChanged: _handleSearch,
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
          borderSide: const BorderSide(color: Color(0xFFFACC15)),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _ohangLinks() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ohangButton(
          label: '화 (火)',
          icon: Icons.local_fire_department_outlined,
          colors: const [Color(0xFFF87171), Color(0xFFF97316)],
          onTap: widget.onNavigateToOhangFire,
        ),
        const SizedBox(height: 8),
        _ohangButton(
          label: '수 (水)',
          icon: Icons.water_drop_outlined,
          colors: const [Color(0xFF38BDF8), Color(0xFF22D3EE)],
          onTap: widget.onNavigateToOhangWater,
        ),
        const SizedBox(height: 8),
        _ohangButton(
          label: '목 (木)',
          icon: Icons.eco_outlined,
          colors: const [Color(0xFF34D399), Color(0xFF10B981)],
          onTap: widget.onNavigateToOhangWood,
        ),
        const SizedBox(height: 8),
        _ohangButton(
          label: '금 (金)',
          icon: Icons.hexagon_outlined,
          colors: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
          onTap: widget.onNavigateToOhangMetal,
        ),
        const SizedBox(height: 8),
        _ohangButton(
          label: '토 (土)',
          icon: Icons.landscape_outlined,
          colors: const [Color(0xFFD97706), Color(0xFFB45309)],
          onTap: widget.onNavigateToOhangEarth,
        ),
      ],
    );
  }

  Widget _ohangButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    Color background = Colors.transparent,
    Color iconColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background.isTransparent()
              ? Colors.white.withOpacity(0.1)
              : background,
          borderRadius: BorderRadius.circular(22),
          border: background.isTransparent()
              ? Border.all(color: Colors.white.withOpacity(0.2))
              : null,
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}

extension on Color {
  bool isTransparent() => alpha == 0;
}

