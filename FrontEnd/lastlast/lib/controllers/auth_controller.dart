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
        final restoredUser = AuthUser.fromJson(data);
        final restoredUserId = restoredUser.id;
        
        // 복원된 사용자의 사주 데이터만 남기고 나머지 삭제
        final allKeys = prefs.getKeys();
        for (final key in allKeys) {
          if (key.startsWith('my_saju_result_') || 
              key.startsWith('my_saju_user_info_') || 
              key.startsWith('last_saju_analysis_')) {
            // 복원된 사용자의 키가 아니면 삭제
            if (!key.endsWith('_$restoredUserId')) {
              await prefs.remove(key);
            }
          }
        }
        
        _user = restoredUser;
        _api.updateToken(token);
      } catch (_) {
        await prefs.remove(_tokenKey);
        await prefs.remove(_userKey);
      }
    } else {
      // 세션이 없으면 모든 사주 데이터 삭제 (로그아웃 상태)
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('my_saju_result_') || 
            key.startsWith('my_saju_user_info_') || 
            key.startsWith('last_saju_analysis_')) {
          await prefs.remove(key);
        }
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
    
    // 로그인 시 이전 사용자의 사주 데이터 정리 (강화)
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().toList(); // Set을 List로 변환하여 안전하게 순회
    final currentUserId = user.id;
    
    // 이전 사용자의 사주 데이터 키 찾아서 삭제
    for (final key in allKeys) {
      if (key.startsWith('my_saju_result_') || 
          key.startsWith('my_saju_user_info_') || 
          key.startsWith('last_saju_analysis_')) {
        // 현재 사용자의 키가 아니면 삭제
        final expectedSuffix = '_$currentUserId';
        if (!key.endsWith(expectedSuffix)) {
          await prefs.remove(key);
        }
      }
    }
    
    // 기존 키(사용자 ID 없이)도 삭제 (마이그레이션)
    await prefs.remove('my_saju_result');
    await prefs.remove('my_saju_user_info');
    await prefs.remove('last_saju_analysis');
    
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
    // 회원가입 전에 모든 이전 사용자 사주 데이터 삭제
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('my_saju_result_') || 
          key.startsWith('my_saju_user_info_') || 
          key.startsWith('last_saju_analysis_')) {
        await prefs.remove(key);
      }
    }
    
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
    final userId = _user?.id ?? 0;
    _user = null;
    _api.updateToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    
    // 이전 사용자의 사주 데이터 삭제 (선택적 - 보안을 위해)
    // 주의: 이렇게 하면 로그아웃 시 사주 데이터가 삭제됩니다
    // 데이터를 유지하려면 이 부분을 주석 처리하세요
    if (userId > 0) {
      await prefs.remove('last_saju_analysis_$userId');
      await prefs.remove('my_saju_result_$userId');
      await prefs.remove('my_saju_user_info_$userId');
    }
    
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

