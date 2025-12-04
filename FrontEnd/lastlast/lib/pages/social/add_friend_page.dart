import 'package:flutter/material.dart';

import '../../controllers/friend_controller.dart';
import '../../models/friend_models.dart';
import '../../services/api_client.dart';
import '../../shared/widgets/mystic_background.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _queryController = TextEditingController();
  List<FriendSearchResult> _results = const [];
  bool _searching = false;
  String? _error;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = FriendScope.of(context);
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
                    Row(
                      children: [
                        _roundButton(
                          icon: Icons.arrow_back,
                          onTap: widget.onBack,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '친구 찾기 🔍',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '닉네임이나 이메일로 친구를 검색해 요청을 보내보세요.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _queryController,
                  onSubmitted: (_) => _search(controller),
                  decoration: InputDecoration(
                    hintText: '예: moon@example.com 또는 문지환',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    suffixIcon: IconButton(
                      icon: _searching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search, color: Colors.white70),
                      onPressed: _searching ? null : () => _search(controller),
                    ),
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
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                Expanded(
                  child: _results.isEmpty && !_searching
                      ? const Center(
                          child: Text(
                            '검색어를 입력해 친구를 찾아보세요.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            return _SearchResultTile(
                              result: result,
                              onSendRequest: () => _sendRequest(controller, result),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _search(FriendController controller) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final query = _queryController.text.trim();
      final results = await controller.searchUsers(query);
      if (mounted) {
        setState(() => _results = results);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _sendRequest(
    FriendController controller,
    FriendSearchResult result,
  ) async {
    try {
      await controller.sendFriendRequest(result.userId);
      await controller.refreshRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result.name}님에게 친구 요청을 보냈습니다.')),
        );
        _search(controller);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    }
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
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.onSendRequest,
  });

  final FriendSearchResult result;
  final VoidCallback onSendRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _buildAvatar(result.name, result.characterType),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.email,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  result.elementLabel,
                  style: const TextStyle(color: Color(0xFFFACC15), fontSize: 12),
                ),
              ],
            ),
          ),
          _actionButton(context),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context) {
    switch (result.status) {
      case FriendRelationStatus.friend:
        return _statusChip('이미 친구', Colors.white24);
      case FriendRelationStatus.incomingPending:
        return _statusChip('상대의 요청 대기 중', Colors.white24);
      case FriendRelationStatus.outgoingPending:
        return _statusChip('요청 보냄', Colors.white24);
      case FriendRelationStatus.none:
        return ElevatedButton(
          onPressed: onSendRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFACC15),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('친구 요청'),
        );
    }
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }

  Widget _buildAvatar(String name, String? characterType) {
    // 오행에 따른 이미지 파일명 매핑
    final characterImageMap = {
      'wood': 'assets/tree.png',
      'fire': 'assets/fire.png',
      'earth': 'assets/land.png',
      'metal': 'assets/gold.png',
      'water': 'assets/water.png',
    };

    final imagePath = characterType != null
        ? characterImageMap[characterType.toLowerCase()]
        : null;

    if (imagePath != null) {
      return ClipOval(
        child: Image.asset(
          imagePath,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar(name);
          },
        ),
      );
    }

    return _buildFallbackAvatar(name);
  }

  Widget _buildFallbackAvatar(String name) {
    final text = name.isEmpty
        ? '?'
        : String.fromCharCode(name.runes.first).toUpperCase();
    return CircleAvatar(
      radius: 26,
      backgroundColor: const Color(0xFFFACC15).withValues(alpha: 0.7),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}


