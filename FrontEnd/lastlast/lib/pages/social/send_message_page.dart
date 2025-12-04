import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/message_controller.dart';
import '../../models/message_models.dart';

class SendMessagePage extends StatefulWidget {
  const SendMessagePage({
    super.key,
    required this.recipientName,
    required this.recipientId,
    this.isAnonymous = false,
    this.onBack,
  });

  final String recipientName;
  final int recipientId;
  final bool isAnonymous; // 익명 게시판에서 보낸 쪽지 여부
  final VoidCallback? onBack;

  @override
  State<SendMessagePage> createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      MessageScope.of(context).loadConversation(widget.recipientId,
          isAnonymous: widget.isAnonymous);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    final scope = MessageScope.of(context);
    await scope.sendMessage(widget.recipientId, text,
        isAnonymous: widget.isAnonymous);
    if (!mounted) return;
    await scope.loadConversation(widget.recipientId,
        isAnonymous: widget.isAnonymous);
    if (!mounted) return;
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 하단 단축키 투명도 방지
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    final auth = AuthScope.of(context);
    final controller = MessageScope.of(context);
    final currentUserId = auth.user?.id ?? 0;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          SafeArea(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final messages = controller.conversationFor(widget.recipientId,
                    isAnonymous: widget.isAnonymous);
                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMine = message.senderId == currentUserId;
                          final timeLabel = message.createdAt != null
                              ? '${message.createdAt!.hour.toString().padLeft(2, '0')}:${message.createdAt!.minute.toString().padLeft(2, '0')}'
                              : '';
                          return Align(
                            alignment: isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMine
                                    ? const Color(0xFFFACC15)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isMine ? 18 : 6),
                                  bottomRight: Radius.circular(isMine ? 6 : 18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isMine
                                          ? Colors.black
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeLabel,
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _inputBar(controller),
                  ],
                );
              },
            ),
          ),
          // 하단 단축키 영역을 덮는 검정색 배경
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).padding.bottom,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // recipientId로부터 characterType 가져오기
    final controller = MessageScope.of(context);
    final threads = controller.threads;
    final thread = threads.firstWhere(
      (t) => t.peerId == widget.recipientId && t.isAnonymous == widget.isAnonymous,
      orElse: () => MessageThreadModel(
        peerId: widget.recipientId,
        peerName: widget.recipientName,
        peerEmail: null,
        elementLabel: '',
        lastMessage: '',
        lastSentAt: null,
        unreadCount: 0,
        isAnonymous: widget.isAnonymous,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          _buildAvatar(thread),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.recipientName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                '오프라인',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(MessageThreadModel thread) {
    // 익명인 경우 기본 아바타
    if (thread.isAnonymous) {
      final initial = widget.recipientName.isEmpty
          ? '?'
          : String.fromCharCode(widget.recipientName.runes.first).toUpperCase();
      return CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFFACC15).withValues(alpha: 0.3),
        child: Text(
          initial,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold),
        ),
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

    final initial = widget.recipientName.isEmpty
        ? '?'
        : String.fromCharCode(widget.recipientName.runes.first).toUpperCase();

    return ClipOval(
      child: imagePath != null
          ? Image.asset(
              imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackAvatar(initial);
              },
            )
          : _buildFallbackAvatar(initial),
    );
  }

  Widget _buildFallbackAvatar(String initial) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFFACC15).withValues(alpha: 0.3),
      child: Text(
        initial,
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _inputBar(MessageController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요...',
                hintStyle: const TextStyle(color: Colors.black38),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: controller.isSending ? null : _handleSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: controller.isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, size: 18),
          ),
        ],
      ),
    );
  }
}
