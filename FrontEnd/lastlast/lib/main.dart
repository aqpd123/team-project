import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_router.dart';
import 'controllers/auth_controller.dart';
import 'controllers/celebrity_controller.dart';
import 'controllers/community_controller.dart';
import 'controllers/friend_controller.dart';
import 'controllers/message_controller.dart';
import 'controllers/saju_controller.dart';
import 'services/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = ApiClient();
  final auth = AuthController(apiClient);
  // 토큰 만료 시 자동 로그아웃 처리
  apiClient.onTokenExpired = () async {
    await auth.logout();
  };
  await auth.restoreSession();
  final community = CommunityController(apiClient, auth);
  final friend = FriendController(apiClient, auth);
  final message = MessageController(apiClient, auth);
  final saju = SajuController(apiClient);
  final celebrity = CelebrityController(apiClient);
  runApp(
    AuthScope(
      controller: auth,
      child: CommunityScope(
        controller: community,
        child: FriendScope(
          controller: friend,
          child: MessageScope(
            controller: message,
            child: SajuScope(
              controller: saju,
              child: CelebrityScope(
                controller: celebrity,
                child: SajuApp(auth: auth),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SajuApp extends StatelessWidget {
  SajuApp({super.key, required this.auth});

  final AuthController auth;
  late final AppRouter _router = AppRouter(auth);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '신비한 사주',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6366F1),
        fontFamily: 'Pretendard',
      ),
      locale: const Locale('ko'),
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: _router.router,
    );
  }
}

