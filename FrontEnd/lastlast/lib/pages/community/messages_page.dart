import 'package:flutter/material.dart';

import '../../controllers/message_controller.dart';
import '../../models/message_models.dart';
import '../../shared/widgets/mystic_background.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({
    super.key,
    this.onBack,
    this.onOpenThread,
  });

  final VoidCallback? onBack;
  final ValueChanged<MessageThreadModel>? onOpenThread;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      MessageScope.of(context).loadThreads();
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    // 페이지가 표시될 때마다 쪽지함 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        MessageScope.of(context).loadThreads();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = MessageScope.of(context);
    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final threads = controller.threads;
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _backButton(),
                        const Text(
                          '쪽지함 💌',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        controller.isLoadingThreads
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.loadThreads,
                        child: threads.isEmpty
                            ? _emptyState()
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: threads.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final thread = threads[index];
                                  return _ThreadTile(
                                    thread: thread,
                                    onTap: () =>
                                        widget.onOpenThread?.call(thread),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white24,
                child:
                    Icon(Icons.mail_outline, color: Colors.white60, size: 48),
              ),
              SizedBox(height: 24),
              Text(
                '주고 받은 쪽지가 없어요',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '친구들과 쪽지를 주고받으며 소통해보세요.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: widget.onBack,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, this.onTap});

  final MessageThreadModel thread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = thread.lastSentAt != null
        ? '${thread.lastSentAt!.month.toString().padLeft(2, '0')}/${thread.lastSentAt!.day.toString().padLeft(2, '0')}'
        : '';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        thread.peerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        dateLabel,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    thread.lastMessage,
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (thread.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFACC15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${thread.unreadCount}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // 익명인 경우 기본 아바타
    if (thread.isAnonymous) {
      final initial = thread.peerName.isEmpty
          ? '?'
          : String.fromCharCode(thread.peerName.runes.first).toUpperCase();
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        child: Text(initial, style: const TextStyle(color: Colors.white)),
      );
    }

    // 오행에 따른 이미지 파일명 매핑
    final characterImageMap = {
      'wood': 'assets/tree.png',
      'fire': 'assets/fire.png',
      'earth': 'assets/land.png',
      'metal': 'assets/gold.png',
      'water': 'assets/water.png',
    };

    final imagePath = thread.characterType != null
        ? characterImageMap[thread.characterType!.toLowerCase()]
        : null;

    final initial = thread.peerName.isEmpty
        ? '?'
        : String.fromCharCode(thread.peerName.runes.first).toUpperCase();

    return ClipOval(
      child: imagePath != null
          ? Image.asset(
              imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackAvatar(initial);
              },
            )
          : _buildFallbackAvatar(initial),
    );
  }

  Widget _buildFallbackAvatar(String initial) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
