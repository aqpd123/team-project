import 'package:flutter/material.dart';

import '../../shared/widgets/friend_tile.dart';
import '../../shared/widgets/mystic_background.dart';

class FriendData {
  const FriendData({
    required this.id,
    required this.name,
    required this.elementLabel,
    required this.statusLabel,
    this.isFriend = true,
  });

  final String id;
  final String name;
  final String elementLabel;
  final String statusLabel;
  final bool isFriend;
}

class FriendsPage extends StatefulWidget {
  const FriendsPage({
    super.key,
    this.friends = const [],
    this.onNavigateToAddFriend,
    this.onNavigateToManagement,
    this.onSendMessage,
    this.onCheckCompatibility,
    this.onRemoveFriend,
    this.onBlockFriend,
    this.onSendFriendRequest,
    this.onBack,
  });

  final List<FriendData> friends;
  final VoidCallback? onNavigateToAddFriend;
  final VoidCallback? onNavigateToManagement;
  final ValueChanged<FriendData>? onSendMessage;
  final ValueChanged<FriendData>? onCheckCompatibility;
  final ValueChanged<FriendData>? onRemoveFriend;
  final ValueChanged<FriendData>? onBlockFriend;
  final ValueChanged<FriendData>? onSendFriendRequest;
  final VoidCallback? onBack;

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  String _search = '';
  FriendData? _selected;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.friends.where((friend) {
      return friend.name.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          MysticBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (widget.onBack != null) ...[
                          _roundButton(
                            icon: Icons.arrow_back,
                            onTap: widget.onBack,
                          ),
                          const SizedBox(width: 12),
                        ],
                        const Text(
                          '친구 목록 👥',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _roundButton(
                          icon: Icons.person_add_alt_1_outlined,
                          onTap: widget.onNavigateToAddFriend,
                        ),
                        const SizedBox(width: 8),
                        _roundButton(
                          icon: Icons.settings_outlined,
                          onTap: widget.onNavigateToManagement,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    hintText: '친구 검색...',
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
                      borderSide: const BorderSide(color: Color(0xFFA5F3FC)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            '검색 결과가 없습니다',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final friend = filtered[index];
                            return FriendTile(
                              name: friend.name,
                              elementLabel: friend.elementLabel,
                              statusLabel: friend.statusLabel,
                              onTap: () => setState(() => _selected = friend),
                              trailing: IconButton(
                                onPressed: () {
                                  widget.onSendMessage?.call(friend);
                                },
                                icon: const Icon(Icons.chat_bubble_outline,
                                    color: Colors.white70),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (_selected != null) _friendModal(),
        ],
      ),
    );
  }

  Widget _friendModal() {
    final friend = _selected!;
    final isOnline = friend.statusLabel.contains('온라인');
    return Stack(
      children: [
        // 배경 오버레이 (클릭 시 닫기)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _selected = null),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        // 모달
        Center(
          child: GestureDetector(
            onTap: () {}, // 모달 내부 클릭 시 배경 클릭 이벤트 차단
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E1B4B),
                    Color(0xFF2E1065),
                    Color(0xFF1E1B4B),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 왼쪽: 프로필 정보
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            // 프로필 아바타
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFACC15).withOpacity(0.3),
                                    const Color(0xFF22D3EE).withOpacity(0.3),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFACC15).withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  friend.name.characters.first,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // 온라인 상태 표시
                            if (isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1E1B4B),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          friend.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFACC15).withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            friend.elementLabel,
                            style: const TextStyle(
                              color: Color(0xFFFACC15),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          friend.statusLabel,
                          style: TextStyle(
                            color: isOnline
                                ? const Color(0xFF10B981)
                                : Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // 오른쪽: 버튼들
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (friend.isFriend) ...[
                            _verticalModalButton(
                              label: '쪽지',
                              icon: Icons.mail_outline,
                              color: const Color(0xFFFACC15),
                              onTap: () {
                                widget.onSendMessage?.call(friend);
                                setState(() => _selected = null);
                              },
                            ),
                            const SizedBox(height: 6),
                            _verticalModalButton(
                              label: '궁합 보기',
                              icon: Icons.favorite_border,
                              color: const Color(0xFF22D3EE),
                              onTap: () {
                                widget.onCheckCompatibility?.call(friend);
                                setState(() => _selected = null);
                              },
                            ),
                            const SizedBox(height: 6),
                            _verticalModalButton(
                              label: '친구 삭제',
                              icon: Icons.person_remove_alt_1_outlined,
                              color: const Color(0xFFFB7185),
                              onTap: () {
                                widget.onRemoveFriend?.call(friend);
                                setState(() => _selected = null);
                              },
                            ),
                            const SizedBox(height: 6),
                            _verticalModalButton(
                              label: '친구 차단',
                              icon: Icons.block,
                              color: const Color(0xFFEF4444),
                              onTap: () {
                                widget.onBlockFriend?.call(friend);
                                setState(() => _selected = null);
                              },
                            ),
                          ] else
                            _friendRequestButton(friend),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() => _selected = null),
                            child: Text(
                              '닫기',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _friendRequestButton(FriendData friend) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          widget.onSendFriendRequest?.call(friend);
          setState(() => _selected = null);
        },
        icon: const Icon(Icons.person_add_alt_1, size: 14),
        label: const Text(
          '친구 요청 보내기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFACC15),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: const Color(0xFFFACC15).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _modalButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _verticalModalButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: color.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

