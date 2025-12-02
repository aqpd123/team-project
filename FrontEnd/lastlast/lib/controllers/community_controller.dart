import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/comment_model.dart';
import '../models/community_post.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';

class CommunityController extends ChangeNotifier {
  CommunityController(this._api, this._auth) {
    _auth.addListener(_handleAuthChanged);
  }

  final ApiClient _api;
  final AuthController _auth;

  final List<CommunityPost> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<CommunityPost> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> refreshPosts({String? boardType}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final queryParams = <String, dynamic>{'page_size': 50};
      if (boardType != null && boardType.isNotEmpty) {
        queryParams['board_type'] = boardType;
      }
      final response = await _api.get(
        '/posts',
        queryParameters: queryParams,
      );
      final items = response['items'] as List<dynamic>? ?? const [];
      _posts
        ..clear()
        ..addAll(
          items
              .whereType<Map<String, dynamic>>()
              .map(CommunityPost.fromJson),
        );
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
    String? boardType,
  }) async {
    if (!_auth.isLoggedIn || _auth.user == null) {
      throw const ApiException('로그인이 필요합니다.', statusCode: 401);
    }
    await _api.post(
      '/posts',
      data: {
        'title': title,
        'content': content,
        'board_type': boardType,
        'author_id': _auth.user!.id,
      },
    );
    await refreshPosts();
  }

  List<CommunityPost> postsByOhang(String key) {
    return _posts.where((post) => post.ohangKey == key).toList();
  }

  Future<List<CommunityPost>> getMyPosts() async {
    if (!_auth.isLoggedIn || _auth.user == null) {
      return [];
    }
    try {
      final response = await _api.get(
        '/posts',
        queryParameters: {
          'author_id': _auth.user!.id,
          'page_size': 100,
        },
      );
      final items = response['items'] as List<dynamic>? ?? const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(CommunityPost.fromJson)
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<void> ensureLoaded() async {
    if (_posts.isEmpty && !_isLoading) {
      await refreshPosts();
    }
  }

  Future<CommunityPostDetail> fetchPostDetail(int postId) async {
    try {
      final response = await _api.get('/posts/$postId');
      final postJson = (response['post'] as Map<String, dynamic>? ?? const {});
      final comments = (response['comments'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CommentModel.fromJson)
          .toList();
      final detail = CommunityPostDetail(
        post: CommunityPost.fromJson(postJson),
        comments: comments,
      );
      return detail;
    } on ApiException {
      rethrow;
    }
  }

  Future<CommentModel> addComment({
    required int postId,
    required String content,
  }) async {
    if (!_auth.isLoggedIn || _auth.user == null) {
      throw const ApiException('로그인이 필요합니다.', statusCode: 401);
    }
    final response = await _api.post(
      '/posts/$postId/comments',
      data: {
        'content': content,
        'author_id': _auth.user!.id,
      },
    );
    final commentJson = (response['comment'] as Map<String, dynamic>? ?? const {});
    final comment = CommentModel.fromJson(commentJson);
    await refreshPosts();
    return comment;
  }

  void _handleAuthChanged() {
    if (!_auth.isLoggedIn) {
      _posts.clear();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthChanged);
    super.dispose();
  }
}

class CommunityScope extends InheritedNotifier<CommunityController> {
  const CommunityScope({
    super.key,
    required CommunityController controller,
    required super.child,
  }) : super(notifier: controller);

  static CommunityController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<CommunityScope>();
    assert(scope != null, 'CommunityScope is missing in the widget tree');
    return scope!.notifier!;
  }
}


