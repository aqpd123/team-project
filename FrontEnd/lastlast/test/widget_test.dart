// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_app/main.dart';
import 'package:my_flutter_app/controllers/auth_controller.dart';
import 'package:my_flutter_app/controllers/community_controller.dart';
import 'package:my_flutter_app/services/api_client.dart';

void main() {
  testWidgets('앱이 로그인 화면을 렌더링한다', (tester) async {
    final api = ApiClient(baseUrl: 'http://localhost');
    final auth = AuthController(api);
    final community = CommunityController(api, auth);

    await tester.pumpWidget(
      AuthScope(
        controller: auth,
        child: CommunityScope(
          controller: community,
          child: SajuApp(auth: auth),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('로그인'), findsWidgets);
  });
}
