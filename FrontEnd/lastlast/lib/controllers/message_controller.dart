import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../models/message_models.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';

class MessageController extends ChangeNotifier {
  MessageController(this._api, this._auth) {
    _auth.addListener(_handleAuthChanged);
  }

  final ApiClient _api;
  final AuthController _auth;

  bool _loadingThreads = false;
  bool _loadingConversation = false;
  bool _sending = false;
  String? _error;

  final List<MessageThreadModel> _threads = [];
  final Map<int, List<ChatMessageModel>> _conversations = {};

  UnmodifiableListView<MessageThreadModel> get threads => UnmodifiableListView(_threads);
  bool get isLoadingThreads => _loadingThreads;
  bool get isLoadingConversation => _loadingConversation;
  bool get isSending => _sending;
  String? get error => _error;

  Future<void> ensureThreadsLoaded() async {
    if (_threads.isEmpty && !_loadingThreads) {
      await loadThreads();
    }
  }

  Future<void> loadThreads() async {
    if (!_auth.isLoggedIn) return;
    _loadingThreads = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/messages/threads');
      final items = response['items'] as List<dynamic>? ?? const [];
      _threads
        ..clear()
        ..addAll(
          items
              .whereType<Map<String, dynamic>>()
              .map((item) => _mapThread(item)),
        );
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingThreads = false;
      notifyListeners();
    }
  }

  Future<void> loadConversation(int peerId) async {
    if (!_auth.isLoggedIn) return;
    _loadingConversation = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/messages/conversations/$peerId');
      final items = response['items'] as List<dynamic>? ?? const [];
      final list = items.whereType<Map<String, dynamic>>().map(_mapMessage).toList();
      list.sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return left.compareTo(right);
      });
      _conversations[peerId] = list;
      await _api.post('/messages/conversations/$peerId/read');
      await loadThreads();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingConversation = false;
      notifyListeners();
    }
  }

  List<ChatMessageModel> conversationFor(int peerId) {
    return List.unmodifiable(_conversations[peerId] ?? const []);
  }

  Future<void> sendMessage(int peerId, String content) async {
    if (!_auth.isLoggedIn || content.trim().isEmpty) return;
    _sending = true;
    notifyListeners();
    try {
      final response = await _api.post(
        '/messages',
        data: {'recipient_id': peerId, 'content': content.trim()},
      );
      final message = _mapMessage(response['message'] as Map<String, dynamic>);
      final list = _conversations.putIfAbsent(peerId, () => []);
      list.add(message);
      list.sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return left.compareTo(right);
      });
      await loadThreads();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  MessageThreadModel _mapThread(Map<String, dynamic> json) {
    final peer = json['peer'] as Map<String, dynamic>? ?? const {};
    return MessageThreadModel(
      peerId: peer['user_id'] as int? ?? 0,
      peerName: (peer['username'] ?? peer['email'] ?? '사용자') as String,
      peerEmail: peer['email'] as String?,
      elementLabel: _elementFromCharacter(peer['character_type']),
      lastMessage: (json['content'] ?? '') as String,
      lastSentAt: _parseDate(json['created_at']),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  ChatMessageModel _mapMessage(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['message_id'] as int? ?? 0,
      senderId: json['sender_id'] as int? ?? 0,
      recipientId: json['recipient_id'] as int? ?? 0,
      content: (json['content'] ?? '') as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String _elementFromCharacter(dynamic value) {
    final raw = (value as String?)?.toLowerCase();
    switch (raw) {
      case 'fire':
        return '화의 사람';
      case 'water':
        return '수의 사람';
      case 'wood':
        return '목의 사람';
      case 'metal':
        return '금의 사람';
      case 'earth':
        return '토의 사람';
      default:
        return '화의 사람';
    }
  }

  void _handleAuthChanged() {
    if (!_auth.isLoggedIn) {
      _threads.clear();
      _conversations.clear();
      _error = null;
      notifyListeners();
    } else {
      loadThreads();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthChanged);
    super.dispose();
  }
}

class MessageScope extends InheritedNotifier<MessageController> {
  const MessageScope({
    super.key,
    required MessageController controller,
    required super.child,
  }) : super(notifier: controller);

  static MessageController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MessageScope>();
    assert(scope != null, 'MessageScope is missing in the widget tree');
    return scope!.notifier!;
  }
}


