import 'package:flutter/material.dart';

import '../../controllers/friend_controller.dart';
import '../../models/friend_models.dart';
import '../../services/api_client.dart';
import '../../shared/widgets/mystic_background.dart';

class FriendManagementPage extends StatefulWidget {
  const FriendManagementPage({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<FriendManagementPage> createState() => _FriendManagementPageState();
}

class _FriendManagementPageState extends State<FriendManagementPage> {
  bool _showInbox = true;
  bool _initialized = false;
  bool _processing = false;

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
    final requests = _showInbox ? controller.inboxRequests : controller.outboxRequests;

    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _roundButton(icon: Icons.arrow_back, onTap: widget.onBack),
                            const SizedBox(width: 12),
                            const Text(
                              '친구 관리 ⚙️',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (_processing)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '받은 친구 요청을 확인하고 응답하거나, 내가 보낸 요청을 관리할 수 있습니다.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    _tabSwitch(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: controller.isLoadingRequests && requests.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : requests.isEmpty
                              ? _emptyState()
                              : ListView.separated(
                                  itemCount: requests.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final request = requests[index];
                                    return _RequestTile(
                                      request: request,
                                      onAccept: () => _respond(controller, request, true),
                                      onReject: () => _respond(controller, request, false),
                                      onCancel: () => _cancel(controller, request),
                                    );
                                  },
                                ),
                    ),
                    const SizedBox(height: 12),
                    _blockedInfoCard(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _tabSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _tabButton('받은 요청', _showInbox, () => setState(() => _showInbox = true)),
          _tabButton('보낸 요청', !_showInbox, () => setState(() => _showInbox = false)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool selected, VoidCallback onTap) {
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

  Widget _emptyState() {
    return Center(
      child: Text(
        _showInbox ? '받은 친구 요청이 없습니다.' : '보낸 친구 요청이 없습니다.',
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }

  Widget _blockedInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '차단 관리 준비 중',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '친구 차단 및 해제 기능은 곧 제공될 예정입니다.',
            style: TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Future<void> _respond(
    FriendController controller,
    FriendRequestModel request,
    bool accept,
  ) async {
    if (!request.isInbox) return;
    setState(() => _processing = true);
    try {
      await controller.respondRequest(request.friendshipId, accept: accept);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept
                  ? '${request.name}님과 친구가 되었습니다.'
                  : '${request.name}님의 요청을 거절했습니다.',
            ),
          ),
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
        setState(() => _processing = false);
      }
    }
  }

  Future<void> _cancel(
    FriendController controller,
    FriendRequestModel request,
  ) async {
    if (request.isInbox) return;
    setState(() => _processing = true);
    try {
      await controller.cancelRequest(request.friendshipId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${request.name}님에게 보낸 요청을 취소했습니다.')),
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
        setState(() => _processing = false);
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

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onCancel,
  });

  final FriendRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: request.isInbox
                    ? const Color(0xFF22D3EE).withValues(alpha: 0.6)
                    : const Color(0xFFFACC15).withValues(alpha: 0.6),
                child: Text(
                  request.name.isEmpty
                      ? '?'
                      : String.fromCharCode(request.name.runes.first).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (request.email != null && request.email!.isNotEmpty)
                      Text(
                        request.email!,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      request.elementLabel,
                      style: const TextStyle(color: Color(0xFFFACC15), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (request.isInbox)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22D3EE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('수락'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('거절'),
                  ),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('요청 취소'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
        ],
      ),
    );
  }
}


