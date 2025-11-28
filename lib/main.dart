import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_router.dart';
import 'controllers/auth_controller.dart';

void main() {
  final auth = AuthController();
  runApp(AuthScope(
    controller: auth,
    child: SajuApp(auth: auth),
  ));
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

