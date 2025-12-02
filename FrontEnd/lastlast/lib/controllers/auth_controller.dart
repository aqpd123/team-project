import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.elementLabel = '화의 사람',
    this.saju,
  });

  final int id;
  final String name;
  final String email;
  final String elementLabel;
  final Map<String, dynamic>? saju;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['user_id'] as int? ?? json['id'] as int? ?? 0,
      name: (json['username'] ??
              json['name'] ??
              json['email'] ??
              '사용자') as String,
      email: json['email'] as String? ?? '',
      elementLabel: _elementFromCharacter(json['character_type']),
      saju: json['saju'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'username': name,
        'email': email,
        'character_type': elementLabel,
        if (saju != null) 'saju': saju,
      };

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
}

class AuthController extends ChangeNotifier {
  AuthController(this._api);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final ApiClient _api;
  AuthUser? _user;
  bool _restoring = false;

  bool get isLoggedIn => _user != null;
  AuthUser? get user => _user;
  bool get isRestoring => _restoring;

  Future<void> restoreSession() async {
    _restoring = true;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token != null && userJson != null) {
      try {
        final data =
            jsonDecode(userJson) as Map<String, dynamic>;
        _user = AuthUser.fromJson(data);
        _api.updateToken(token);
      } catch (_) {
        await prefs.remove(_tokenKey);
        await prefs.remove(_userKey);
      }
    }
    _restoring = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final response = await _api.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    final token = response['token'] as String?;
    final userMap =
        response['user'] as Map<String, dynamic>? ?? const {};
    if (token == null || userMap.isEmpty) {
      throw const ApiException('잘못된 로그인 응답입니다.');
    }
    final user = AuthUser.fromJson(userMap);
    await _persistSession(token, user);
    _api.updateToken(token);
    _user = user;
    notifyListeners();
    return true;
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    String nickname,
  ) async {
    await _api.post(
      '/auth/register',
      data: {
        'username': nickname.isNotEmpty ? nickname : name,
        'email': email,
        'password': password,
      },
    );
    return login(email, password);
  }

  Future<void> logout() async {
    _user = null;
    _api.updateToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }

  Future<void> _persistSession(String token, AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope is missing in the widget tree');
    return scope!.notifier!;
  }
}

