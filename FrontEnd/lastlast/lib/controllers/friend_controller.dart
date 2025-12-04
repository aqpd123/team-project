import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/friend_models.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';

class FriendController extends ChangeNotifier {
  FriendController(this._api, this._auth) {
    _auth.addListener(_handleAuthChanged);
  }

  final ApiClient _api;
  final AuthController _auth;

  final Map<int, _FriendProfile> _profileCache = {};
  bool _loadingFriends = false;
  bool _loadingRequests = false;
  String? _error;

  List<FriendData> _friends = [];
  List<FriendRequestModel> _inbox = [];
  List<FriendRequestModel> _outbox = [];

  bool get isLoadingFriends => _loadingFriends;
  bool get isLoadingRequests => _loadingRequests;
  String? get error => _error;

  List<FriendData> get friends => List.unmodifiable(_friends);
  List<FriendRequestModel> get inboxRequests => List.unmodifiable(_inbox);
  List<FriendRequestModel> get outboxRequests => List.unmodifiable(_outbox);

  Future<void> ensureLoaded() async {
    if (!_auth.isLoggedIn) return;
    if (_friends.isEmpty && !_loadingFriends) {
      await refreshFriends();
    }
    if (_inbox.isEmpty && _outbox.isEmpty && !_loadingRequests) {
      await refreshRequests();
    }
  }

  Future<void> refreshAll() async {
    if (!_auth.isLoggedIn) return;
    await Future.wait([refreshFriends(), refreshRequests()]);
  }

  Future<void> refreshFriends() async {
    if (!_auth.isLoggedIn) return;
    _loadingFriends = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/friends');
      final items = response['items'] as List<dynamic>? ?? const [];
      final futures = items.whereType<Map<String, dynamic>>().map(_mapFriend);
      _friends = await Future.wait(futures);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingFriends = false;
      notifyListeners();
    }
  }

  Future<void> refreshRequests() async {
    if (!_auth.isLoggedIn) return;
    _loadingRequests = true;
    _error = null;
    notifyListeners();
    try {
      final inboxFuture = _api.get('/friends/requests');
      final outboxFuture =
          _api.get('/friends/requests', queryParameters: {'box': 'outbox'});
      final results = await Future.wait([inboxFuture, outboxFuture]);
      _inbox = await _mapRequests(results[0], true);
      _outbox = await _mapRequests(results[1], false);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingRequests = false;
      notifyListeners();
    }
  }

  Future<void> sendFriendRequest(int targetUserId) async {
    _ensureLoggedIn();
    await _api.post('/friends/requests', data: {'target_id': targetUserId});
    await refreshRequests();
  }

  Future<void> respondRequest(int friendshipId, {required bool accept}) async {
    _ensureLoggedIn();
    await _api.post(
      '/friends/requests/$friendshipId/response',
      data: {'accept': accept},
    );
    await refreshAll();
  }

  Future<void> cancelRequest(int friendshipId) async {
    _ensureLoggedIn();
    await _api.delete('/friends/requests/$friendshipId');
    await refreshRequests();
  }

  Future<void> removeFriend(int friendshipId) async {
    _ensureLoggedIn();
    await _api.delete('/friends/$friendshipId');
    await refreshFriends();
  }

  Future<List<FriendSearchResult>> searchUsers(String query) async {
    _ensureLoggedIn();
    final response =
        await _api.get('/users', queryParameters: {'page_size': 100});
    final items = response['items'] as List<dynamic>? ?? const [];
    final normalized = query.trim().toLowerCase();
    final results = <FriendSearchResult>[];
    for (final item in items.whereType<Map<String, dynamic>>()) {
      final userId = item['user_id'] as int? ?? 0;
      if (userId == 0 || userId == _auth.user?.id) continue;
      final name = (item['username'] ?? item['email'] ?? '사용자') as String;
      final email = (item['email'] ?? '') as String;
      final characterTypeRaw = item['character_type'] as String?;
      final characterTypeEn = _normalizeCharacterType(characterTypeRaw);
      final element = _elementFromCharacter(characterTypeRaw);
      if (normalized.isNotEmpty) {
        final lowerName = name.toLowerCase();
        final lowerEmail = email.toLowerCase();
        if (!lowerName.contains(normalized) &&
            !lowerEmail.contains(normalized)) {
          continue;
        }
      }
      results.add(
        FriendSearchResult(
          userId: userId,
          name: name,
          email: email,
          elementLabel: element,
          status: relationStatusFor(userId),
          characterType: characterTypeEn?.toLowerCase(),
        ),
      );
    }
    return results;
  }

  FriendRelationStatus relationStatusFor(int userId) {
    if (_friends.any((friend) => friend.userId == userId)) {
      return FriendRelationStatus.friend;
    }
    if (_inbox.any((request) => request.userId == userId)) {
      return FriendRelationStatus.incomingPending;
    }
    if (_outbox.any((request) => request.userId == userId)) {
      return FriendRelationStatus.outgoingPending;
    }
    return FriendRelationStatus.none;
  }

  void _ensureLoggedIn() {
    if (!_auth.isLoggedIn || _auth.user == null) {
      throw const ApiException('로그인이 필요합니다.');
    }
  }

  Future<FriendData> _mapFriend(Map<String, dynamic> record) async {
    final friendshipId = record['friendship_id'] as int? ?? 0;
    final requesterId = record['requester_id'] as int? ?? 0;
    final addresseeId = record['addressee_id'] as int? ?? 0;
    final respondedAt = _parseDate(record['responded_at']);
    final createdAt = _parseDate(record['created_at']);
    final currentUserId = _auth.user?.id;
    final otherUserId =
        currentUserId == requesterId ? addresseeId : requesterId;
    final profile = await _getProfile(otherUserId);
    final labelSource = respondedAt ?? createdAt;
    final statusLabel = labelSource != null
        ? '친구가 된 날짜 ${_formatDate(labelSource)}'
        : '응답 대기 중';
    return FriendData(
      friendshipId: friendshipId,
      userId: profile.userId,
      name: profile.name,
      email: profile.email,
      elementLabel: profile.elementLabel,
      statusLabel: statusLabel,
      characterType: profile.characterType,
    );
  }

  Future<List<FriendRequestModel>> _mapRequests(
      Map<String, dynamic> response, bool inbox) async {
    final items = response['items'] as List<dynamic>? ?? const [];
    final result = <FriendRequestModel>[];
    for (final record in items.whereType<Map<String, dynamic>>()) {
      final friendshipId = record['friendship_id'] as int? ?? 0;
      final targetId =
          record[inbox ? 'requester_id' : 'addressee_id'] as int? ?? 0;
      if (friendshipId == 0 || targetId == 0) continue;
      final profile = await _getProfile(targetId);
      result.add(
        FriendRequestModel(
          friendshipId: friendshipId,
          userId: profile.userId,
          name: profile.name,
          email: profile.email,
          elementLabel: profile.elementLabel,
          isInbox: inbox,
          createdAt: _parseDate(record['created_at']),
        ),
      );
    }
    return result;
  }

  Future<_FriendProfile> _getProfile(int userId) async {
    if (_auth.user != null && _auth.user!.id == userId) {
      return _FriendProfile(
        userId: _auth.user!.id,
        name: _auth.user!.name,
        email: _auth.user!.email,
        elementLabel: _auth.user!.elementLabel,
        characterType: _auth.user!.characterType,
      );
    }
    final cached = _profileCache[userId];
    if (cached != null) return cached;
    final response = await _api.get('/users/$userId');
    final characterTypeRaw = response['character_type'] as String?;
    final characterTypeEn = _normalizeCharacterType(characterTypeRaw);
    final profile = _FriendProfile(
      userId: response['user_id'] as int? ?? userId,
      name: (response['username'] ?? response['email'] ?? '사용자') as String,
      email: (response['email'] ?? '') as String,
      elementLabel: _elementFromCharacter(characterTypeRaw),
      characterType: characterTypeEn?.toLowerCase(),
    );
    _profileCache[userId] = profile;
    return profile;
  }

  static String? _normalizeCharacterType(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    // 이미 영어 형식이면 그대로 반환
    if (['wood', 'fire', 'earth', 'metal', 'water'].contains(lower)) {
      return lower;
    }
    // 한글 형식이면 영어로 변환
    if (lower.contains('화')) return 'fire';
    if (lower.contains('수')) return 'water';
    if (lower.contains('목')) return 'wood';
    if (lower.contains('금')) return 'metal';
    if (lower.contains('토')) return 'earth';
    return null;
  }

  void _handleAuthChanged() {
    if (!_auth.isLoggedIn) {
      _friends = [];
      _inbox = [];
      _outbox = [];
      _profileCache.clear();
      _error = null;
      notifyListeners();
    } else {
      unawaited(refreshAll());
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _elementFromCharacter(dynamic value) {
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

  @override
  void dispose() {
    _auth.removeListener(_handleAuthChanged);
    super.dispose();
  }
}

class FriendScope extends InheritedNotifier<FriendController> {
  const FriendScope({
    super.key,
    required FriendController controller,
    required super.child,
  }) : super(notifier: controller);

  static FriendController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FriendScope>();
    assert(scope != null, 'FriendScope is missing in the widget tree');
    return scope!.notifier!;
  }
}

class _FriendProfile {
  const _FriendProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.elementLabel,
    this.characterType,
  });

  final int userId;
  final String name;
  final String email;
  final String elementLabel;
  final String? characterType; // 영어 오행 타입 ('wood', 'fire', etc.)
}
