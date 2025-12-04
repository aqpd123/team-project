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
  final Map<String, List<ChatMessageModel>> _conversations =
      {}; // 키를 String으로 변경 (익명 여부 포함)

  UnmodifiableListView<MessageThreadModel> get threads =>
      UnmodifiableListView(_threads);
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
    if (!_auth.isLoggedIn) {
      print('loadThreads: User not logged in');
      return;
    }
    _loadingThreads = true;
    _error = null;
    notifyListeners();
    try {
      print('loadThreads: Fetching threads from API...');
      final response = await _api.get('/messages/threads');
      print('loadThreads: API response: $response');
      final items = response['items'] as List<dynamic>? ?? const [];
      print('loadThreads: Found ${items.length} items');
      _threads.clear();
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          try {
            print('loadThreads: Mapping item: $item');
            final thread = _mapThread(item);
            print(
                'loadThreads: Mapped thread: peerId=${thread.peerId}, peerName=${thread.peerName}');
            _threads.add(thread);
          } catch (e, stackTrace) {
            // 매핑 오류가 발생한 경우 해당 항목을 건너뛰고 계속 진행
            print('Error mapping thread: $e');
            print('Stack trace: $stackTrace');
            print('Item: $item');
          }
        }
      }
      print('loadThreads: Total threads after mapping: ${_threads.length}');
    } on ApiException catch (e) {
      _error = e.message;
      print('Error loading threads (ApiException): ${e.message}');
      print('Status code: ${e.statusCode}');
    } catch (e, stackTrace) {
      _error = '쪽지함을 불러오는 중 오류가 발생했습니다.';
      print('Unexpected error loading threads: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _loadingThreads = false;
      notifyListeners();
    }
  }

  Future<void> loadConversation(int peerId, {bool isAnonymous = false}) async {
    if (!_auth.isLoggedIn) return;
    _loadingConversation = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get(
        '/messages/conversations/$peerId',
        queryParameters: {'is_anonymous': isAnonymous.toString()},
      );
      final items = response['items'] as List<dynamic>? ?? const [];
      final list =
          items.whereType<Map<String, dynamic>>().map(_mapMessage).toList();
      list.sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return left.compareTo(right);
      });
      // 익명 여부를 키에 포함하여 별도로 저장
      final conversationKey =
          isAnonymous ? 'anonymous:$peerId' : peerId.toString();
      _conversations[conversationKey] = list;
      await _api.post(
        '/messages/conversations/$peerId/read',
        queryParameters: {'is_anonymous': isAnonymous.toString()},
      );
      await loadThreads();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingConversation = false;
      notifyListeners();
    }
  }

  List<ChatMessageModel> conversationFor(int peerId,
      {bool isAnonymous = false}) {
    final conversationKey =
        isAnonymous ? 'anonymous:$peerId' : peerId.toString();
    return List.unmodifiable(_conversations[conversationKey] ?? const []);
  }

  Future<void> sendMessage(int peerId, String content,
      {bool isAnonymous = false}) async {
    if (!_auth.isLoggedIn || content.trim().isEmpty) return;
    _sending = true;
    notifyListeners();
    try {
      final response = await _api.post(
        '/messages',
        data: {
          'recipient_id': peerId,
          'content': content.trim(),
          'is_anonymous': isAnonymous,
        },
      );
      final message = _mapMessage(response['message'] as Map<String, dynamic>);
      final conversationKey =
          isAnonymous ? 'anonymous:$peerId' : peerId.toString();
      final list = _conversations.putIfAbsent(conversationKey, () => []);
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
    print('_mapThread: Input json: $json');
    final peer = json['peer'] as Map<String, dynamic>?;
    if (peer == null) {
      print('_mapThread: Warning - peer is null');
    }
    final isAnonymous = json['is_anonymous'] as bool? ?? false;
    
    // user_id를 안전하게 파싱 (문자열 또는 숫자 모두 처리)
    final peerIdRaw = peer?['user_id'];
    final peerId = peerIdRaw is int
        ? peerIdRaw
        : (peerIdRaw is String
            ? int.tryParse(peerIdRaw) ?? 0
            : 0);
    
    final peerName = (peer?['username'] ?? peer?['email'] ?? '사용자') as String;
    final peerEmail = peer?['email'] as String?;
    final content = (json['content'] ?? '') as String;
    final createdAt = json['created_at'];
    
    // unread_count를 안전하게 파싱 (문자열 또는 숫자 모두 처리)
    final unreadCountRaw = json['unread_count'];
    final unreadCount = unreadCountRaw is int
        ? unreadCountRaw
        : (unreadCountRaw is String
            ? int.tryParse(unreadCountRaw) ?? 0
            : 0);

    print(
        '_mapThread: peerId=$peerId, peerName=$peerName, isAnonymous=$isAnonymous, content=$content, unreadCount=$unreadCount');

    return MessageThreadModel(
      peerId: peerId,
      peerName: peerName,
      peerEmail: peerEmail,
      elementLabel:
          isAnonymous ? '익명' : _elementFromCharacter(peer?['character_type']),
      lastMessage: content,
      lastSentAt: _parseDate(createdAt),
      unreadCount: unreadCount,
      isAnonymous: isAnonymous,
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
