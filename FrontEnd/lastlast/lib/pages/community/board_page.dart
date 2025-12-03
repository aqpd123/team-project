import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/community_controller.dart';
import '../../models/community_post.dart';
import '../../shared/widgets/bottom_navigation_bar.dart';
import '../../shared/widgets/mystic_background.dart';
import '../../shared/widgets/post_card.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({
    super.key,
    required this.isLoggedIn,
    this.initialTab = BoardCategory.anonymous,
    this.onNavigateToLogin,
    this.onNavigateToWritePost,
    this.onNavigateToMessages,
    this.onNavigateToFriends,
    this.onNavigateToOhangFire,
    this.onNavigateToOhangWater,
    this.onNavigateToOhangWood,
    this.onNavigateToOhangMetal,
    this.onNavigateToOhangEarth,
    this.onOpenPost,
  });

  final bool isLoggedIn;
  final BoardCategory initialTab;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onNavigateToWritePost;
  final VoidCallback? onNavigateToMessages;
  final VoidCallback? onNavigateToFriends;
  final VoidCallback? onNavigateToOhangFire;
  final VoidCallback? onNavigateToOhangWater;
  final VoidCallback? onNavigateToOhangWood;
  final VoidCallback? onNavigateToOhangMetal;
  final VoidCallback? onNavigateToOhangEarth;
  final ValueChanged<int>? onOpenPost;

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  late BoardCategory _activeTab;
  String _searchQuery = '';
  bool _requestedFetch = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeFetchInitial();
  }

  @override
  void didUpdateWidget(BoardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLoggedIn && widget.isLoggedIn) {
      _requestedFetch = false;
      _maybeFetchInitial();
    }
  }

  List<CommunityPost> _filterPosts(List<CommunityPost> posts) {
    return posts.where((post) {
      // 오행 게시판 탭에서는 게시글을 보여주지 않음 (오행 선택 링크만 보여줌)
      if (_activeTab == BoardCategory.ohang) return false;
      if (post.category != _activeTab) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return post.title.toLowerCase().contains(q) ||
          post.content.toLowerCase().contains(q);
    }).toList();
  }

  void _setTab(BoardCategory category) {
    setState(() {
      _activeTab = category;
      _searchQuery = '';
    });
    _refreshPostsForCategory();
  }

  void _handleSearch(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _maybeFetchInitial() {
    if (_requestedFetch || !widget.isLoggedIn) return;
    final community = CommunityScope.of(context);
    _requestedFetch = true;
    unawaited(community.ensureLoaded());
  }

  void _refreshPostsForCategory() {
    final community = CommunityScope.of(context);
    String? boardType;
    if (_activeTab == BoardCategory.ohang) {
      // 오행 게시판일 때는 모든 오행 게시글을 가져오기 위해 null 전달
      // (클라이언트 측에서 필터링)
      boardType = null;
    } else {
      // 익명 게시판일 때는 general 또는 null
      boardType = null;
    }
    unawaited(community.refreshPosts(boardType: boardType));
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

    final community = CommunityScope.of(context);
    return Scaffold(
      body: AnimatedBuilder(
        animation: community,
        builder: (context, _) {
          final posts = _filterPosts(community.posts);
          return MysticBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 8),
                    const Text(
                      '사주 경험을 나누고 소통해보세요',
                      style: TextStyle(color: Color(0xFFA5F3FC)),
                    ),
                    const SizedBox(height: 16),
                    _tabSwitch(),
                    const SizedBox(height: 16),
                    // 오행 게시판 탭에서는 검색 필드 숨김
                    if (_activeTab != BoardCategory.ohang) ...[
                      _searchField(),
                      const SizedBox(height: 16),
                    ],
                    if (_activeTab == BoardCategory.ohang) ...[
                      _ohangLinks(),
                      const SizedBox(height: 16),
                    ],
                    if (community.error != null) _errorBanner(community.error!),
                    Expanded(
                      child: community.isLoading && posts.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : posts.isEmpty && _activeTab != BoardCategory.ohang
                              ? _emptyState()
                              : _activeTab == BoardCategory.ohang
                                  ? const SizedBox.shrink() // 오행 게시판 탭에서는 빈 상태 메시지 숨김
                                  : RefreshIndicator(
                                  onRefresh: community.refreshPosts,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final screenHeight = MediaQuery.of(context).size.height;
                                      return ListView.separated(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemCount: posts.length + 1, // 마지막에 여백 추가
                                        separatorBuilder: (_, index) {
                                          // 마지막 아이템 전에는 구분선, 마지막에는 여백
                                          if (index < posts.length - 1) {
                                            return const SizedBox(height: 12);
                                          }
                                          return const SizedBox.shrink();
                                        },
                                        itemBuilder: (context, index) {
                                          if (index < posts.length) {
                                            final post = posts[index];
                                            return PostCard(
                                              title: post.title,
                                              content: post.content,
                                              author: post.authorLabel,
                                              dateLabel: post.dateLabel,
                                              likes: post.likeCount,
                                              comments: post.commentCount,
                                              onTap: () =>
                                                  widget.onOpenPost?.call(post.id),
                                            );
                                          }
                                          // 마지막 아이템: 최소 높이를 위한 여백
                                          return SizedBox(
                                            height: screenHeight * 0.3,
                                          );
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
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentPath: '/board'),
    );
  }

  Widget _header() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면이 좁을 때 버튼 크기와 간격 조정
        final isNarrow = constraints.maxWidth < 400;
        final buttonSize = isNarrow ? 36.0 : 40.0;
        final buttonSpacing = isNarrow ? 4.0 : 6.0;
        final fontSize = isNarrow ? 22.0 : 26.0;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '사주 이야기 💬',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: buttonSpacing),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _roundButton(
                  icon: Icons.mode_edit_outline,
                  background: const Color(0xFFFACC15),
                  iconColor: Colors.black,
                  onTap: widget.onNavigateToWritePost,
                  size: buttonSize,
                ),
                SizedBox(width: buttonSpacing),
                _roundButton(
                  icon: Icons.mail_outline,
                  onTap: widget.onNavigateToMessages,
                  size: buttonSize,
                ),
                SizedBox(width: buttonSpacing),
                _roundButton(
                  icon: Icons.group_outlined,
                  onTap: widget.onNavigateToFriends,
                  size: buttonSize,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _tabSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
    double size = 40,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background.isTransparent()
              ? Colors.white.withValues(alpha: 0.1)
              : background,
          borderRadius: BorderRadius.circular(size / 2),
          border: background.isTransparent()
              ? Border.all(color: Colors.white.withValues(alpha: 0.2))
              : null,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }

  Widget _emptyState() {
    return RefreshIndicator(
      onRefresh: CommunityScope.of(context).refreshPosts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 빈 상태일 때도 화면 높이만큼 공간을 확보하여 배경이 채워지도록 함
          final minHeight = constraints.maxHeight > 0 
              ? constraints.maxHeight 
              : MediaQuery.of(context).size.height * 0.6;
          
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      '아직 게시글이 없습니다.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
    );
  }
}

extension on Color {
  bool isTransparent() => a == 0.0;
}
