import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AuthUser {
  const AuthUser({
    required this.name,
    required this.email,
    this.elementLabel = '화의 사람',
  });

  final String name;
  final String email;
  final String elementLabel;
}

class AuthController extends ChangeNotifier {
  AuthUser? _user;

  bool get isLoggedIn => _user != null;
  AuthUser? get user => _user;

  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _user = AuthUser(name: '사용자', email: email);
    notifyListeners();
    return true;
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    String nickname,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _user = AuthUser(name: nickname, email: email);
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    notifyListeners();
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

