import 'package:flutter/material.dart';

import '../../controllers/friend_controller.dart';
import '../../models/friend_models.dart';
import '../../services/api_client.dart';
import '../../shared/widgets/friend_tile.dart';
import '../../shared/widgets/mystic_background.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({
    super.key,
    this.onNavigateToAddFriend,
    this.onNavigateToManagement,
    this.onSendMessage,
    this.onCheckCompatibility,
    this.onBack,
  });

  final VoidCallback? onNavigateToAddFriend;
  final VoidCallback? onNavigateToManagement;
  final ValueChanged<FriendData>? onSendMessage;
  final ValueChanged<FriendData>? onCheckCompatibility;
  final VoidCallback? onBack;

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  String _search = '';
  FriendData? _selected;
  bool _initialized = false;
  bool _removing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      FriendScope.of(context).ensureLoaded();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = FriendScope.of(context);
    return Scaffold(
      body: MysticBackground(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final filtered = controller.friends.where((friend) {
              final query = _search.trim().toLowerCase();
              if (query.isEmpty) return true;
              return friend.name.toLowerCase().contains(query) ||
                  (friend.email ?? '').toLowerCase().contains(query);
            }).toList();

            return Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                        const SizedBox(height: 12),
                        const Text(
                          '친구와 메시지를 주고받거나 궁합을 확인해보세요.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          onChanged: (value) => setState(() => _search = value),
                          decoration: InputDecoration(
                            hintText: '이름이나 이메일로 검색...',
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
                              borderSide: const BorderSide(color: Color(0xFFA5F3FC)),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        if (controller.error != null)
                          _errorBanner(controller.error!, Theme.of(context)),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: controller.refreshFriends,
                            child: controller.isLoadingFriends && controller.friends.isEmpty
                                ? const Center(child: CircularProgressIndicator())
                                : filtered.isEmpty
                                    ? const SingleChildScrollView(
                                        physics: AlwaysScrollableScrollPhysics(),
                                        child: SizedBox(
                                          height: 280,
                                          child: Center(
                                            child: Text(
                                              '등록된 친구가 없습니다.',
                                              style: TextStyle(color: Colors.white54),
                                            ),
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        physics: const AlwaysScrollableScrollPhysics(),
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
                                              onPressed: () => widget.onSendMessage?.call(friend),
                                              icon: const Icon(
                                                Icons.chat_bubble_outline,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selected != null) _friendModal(controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _errorBanner(String message, ThemeData theme) {
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
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent),
      ),
    );
  }

  Widget _friendModal(FriendController controller) {
    final friend = _selected!;
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _selected = null),
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),
        Center(
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxHeight: 320),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1B4B), Color(0xFF2E1065), Color(0xFF1E1B4B)],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _avatar(friend.name),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            friend.elementLabel,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          if (friend.email != null && friend.email!.isNotEmpty)
                            Text(
                              friend.email!,
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _verticalModalButton(
                    label: '쪽지 보내기',
                    icon: Icons.mail_outline,
                    color: const Color(0xFFFACC15),
                    onTap: () {
                      widget.onSendMessage?.call(friend);
                      setState(() => _selected = null);
                    },
                  ),
                  const SizedBox(height: 8),
                  _verticalModalButton(
                    label: '궁합 보기',
                    icon: Icons.favorite_border,
                    color: const Color(0xFF22D3EE),
                    onTap: () {
                      widget.onCheckCompatibility?.call(friend);
                      setState(() => _selected = null);
                    },
                  ),
                  const SizedBox(height: 8),
                  _verticalModalButton(
                    label: _removing ? '삭제 중...' : '친구 삭제',
                    icon: Icons.person_remove_alt_1_outlined,
                    color: const Color(0xFFFB7185),
                    onTap: _removing ? null : () => _removeFriend(controller, friend),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _selected = null),
                      child: const Text(
                        '닫기',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _removeFriend(FriendController controller, FriendData friend) async {
    setState(() => _removing = true);
    try {
      await controller.removeFriend(friend.friendshipId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${friend.name}님과의 친구 관계를 삭제했습니다.')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _removing = false;
          _selected = null;
        });
      }
    }
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _roundButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _avatar(String name) {
    final text = name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFACC15), Color(0xFF22D3EE)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFACC15).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


