class MessageThreadModel {
  MessageThreadModel({
    required this.peerId,
    required this.peerName,
    required this.peerEmail,
    required this.elementLabel,
    required this.lastMessage,
    required this.lastSentAt,
    required this.unreadCount,
  });

  final int peerId;
  final String peerName;
  final String? peerEmail;
  final String elementLabel;
  final String lastMessage;
  final DateTime? lastSentAt;
  final int unreadCount;
}

class ChatMessageModel {
  ChatMessageModel({
    required this.messageId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  final int messageId;
  final int senderId;
  final int recipientId;
  final String content;
  final bool isRead;
  final DateTime? createdAt;
}


