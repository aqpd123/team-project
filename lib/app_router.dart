import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'controllers/auth_controller.dart';
import 'pages/auth/login_page.dart';
import 'pages/community/board_page.dart';
import 'pages/community/messages_page.dart';
import 'pages/community/my_posts_page.dart';
import 'pages/community/write_post_page.dart';
import 'pages/more/more_page.dart';
import 'pages/ohang/ohang_earth_page.dart';
import 'pages/ohang/ohang_fire_page.dart';
import 'pages/ohang/ohang_metal_page.dart';
import 'pages/ohang/ohang_water_page.dart';
import 'pages/ohang/ohang_wood_page.dart';
import 'pages/profile/account_settings_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/saju/celebrity_page.dart';
import 'pages/saju/celebrity_result_page.dart';
import 'pages/saju/compatibility_page.dart';
import 'pages/saju/input_page.dart';
import 'pages/saju/my_saju_page.dart';
import 'pages/saju/saju_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/splash/splash_page.dart';
import 'pages/social/add_friend_page.dart' show AddFriendPage, RecommendedFriend;
import 'pages/social/friend_management_page.dart'
    show FriendManagementPage, BlockedUser, FriendRequest;
import 'pages/social/friends_page.dart' show FriendsPage, FriendData;
import 'pages/social/send_message_page.dart';
import 'pages/support/app_info_page.dart';
import 'pages/support/feedback_page.dart';
import 'pages/support/help_page.dart';
import 'pages/support/notification_settings_page.dart';
import 'pages/support/terms_page.dart';
import 'pages/home/home_page.dart';


class AppRouter {
  AppRouter(this._auth);

  final AuthController _auth;

  static const _sampleFriends = [
    FriendData(
      id: 'friend-1',
      name: '김동주',
      elementLabel: '화의 사람',
      statusLabel: '온라인 • 오늘의 운세 공유 중',
    ),
    FriendData(
      id: 'friend-2',
      name: '문지환',
      elementLabel: '수의 사람',
      statusLabel: '오프라인 • 2시간 전 접속',
    ),
    FriendData(
      id: 'friend-3',
      name: '이나경',
      elementLabel: '목의 사람',
      statusLabel: '온라인 • 궁합 보기 대기',
    ),
  ];

  static const _recommendedFriends = [
    RecommendedFriend(
      id: 'rec-1',
      name: '추천 친구 1',
      elementLabel: '금의 사람',
    ),
    RecommendedFriend(
      id: 'rec-2',
      name: '추천 친구 2',
      elementLabel: '토의 사람',
    ),
    RecommendedFriend(
      id: 'rec-3',
      name: '추천 친구 3',
      elementLabel: '화의 사람',
    ),
  ];

  static const _blockedUsers = [
    BlockedUser(
      id: 'blocked-1',
      name: '차단된 사용자',
      elementLabel: '수의 사람',
    ),
  ];

  static const _friendRequests = [
    FriendRequest(
      id: 'request-1',
      name: '친구 요청 사용자',
      elementLabel: '목의 사람',
    ),
  ];

  static final _guardedPaths = <String>{
    '/saju/input',
    '/saju/compatibility',
    '/celebrity-saju',
    '/celebrity-result',
    '/my-saju',
    '/board',
    '/write-post',
    '/messages',
    '/friends',
    '/add-friend',
    '/friend-management',
    '/my-posts',
    '/profile',
    '/settings',
    '/notification-settings',
    '/help',
    '/terms',
    '/feedback',
    '/app-info',
    '/more',
    '/ohang/fire',
    '/ohang/water',
    '/ohang/wood',
    '/ohang/metal',
    '/ohang/earth',
  };

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    refreshListenable: _auth,
    redirect: (context, state) {
      final loggingIn = state.uri.path == '/login';
      final needsAuth = _guardedPaths.contains(state.uri.path);
      if (!_auth.isLoggedIn && needsAuth) return '/login';
      if (_auth.isLoggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashPage(
          onFinished: () =>
              context.go(_auth.isLoggedIn ? '/home' : '/login'),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(
          onBack: () => context.go('/home'),
          onLogin: (email, password) => _auth.login(email, password),
          onRegister: (email, password, name, nickname) =>
              _auth.register(email, password, name, nickname),
          onNavigateAfterSuccess: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomePage(
          isLoggedIn: _auth.isLoggedIn,
          onNavigateToLogin: () => context.go('/login'),
          onNavigateToSaju: () => context.go('/saju'),
          onNavigateToBoard: () => context.go('/board'),
          onNavigateToMore: () => context.go('/more'),
        ),
      ),
      GoRoute(
        path: '/saju',
        builder: (context, state) => SajuPage(
          onBack: () => context.go('/home'),
          onNavigateToInput: () => context.go('/saju/input'),
          onNavigateToCompatibility: () => context.go('/saju/compatibility'),
          onNavigateToCelebrity: () => context.go('/celebrity-saju'),
        ),
      ),
      GoRoute(
        path: '/saju/input',
        builder: (context, state) => SajuInputPage(
          onBack: () => context.go('/saju'),
        ),
      ),
      GoRoute(
        path: '/saju/compatibility',
        builder: (context, state) {
          final extra = state.extra;
          FriendData? friendData;
          if (extra is Map<String, dynamic> && extra['friend'] is FriendData) {
            friendData = extra['friend'] as FriendData;
          }
          return SajuCompatibilityPage(
            onBack: () => friendData != null ? context.go('/friends') : context.go('/saju'),
            friendData: friendData,
          );
        },
      ),
      GoRoute(
        path: '/celebrity-saju',
        builder: (context, state) => CelebritySajuPage(
          onBackToRoot: () => context.go('/saju'),
          onCelebritySelected: (celebrity) =>
              context.go('/celebrity-result', extra: celebrity),
        ),
      ),
      GoRoute(
        path: '/celebrity-result',
        builder: (context, state) {
          final celebrity = state.extra;
          if (celebrity is! CelebrityData) {
            return CelebritySajuPage(
              onBackToRoot: () => context.go('/saju'),
            );
          }
          return CelebrityResultPage(
            celebrity: celebrity,
            onBack: () => context.go('/celebrity-saju'),
            onStartCompatibility: () => context.go('/saju/compatibility'),
          );
        },
      ),
      GoRoute(
        path: '/my-saju',
        builder: (context, state) => MySajuPage(
          onBack: () => context.go('/home'),
          onNavigateToSaju: () => context.go('/saju'),
        ),
      ),
      GoRoute(
        path: '/more',
        builder: (context, state) => MorePage(
          isLoggedIn: _auth.isLoggedIn,
          userName: _auth.user?.name,
          userEmail: _auth.user?.email,
          onNavigateToLogin: () => context.go('/login'),
          onNavigateToProfile: () => context.go('/profile'),
          onNavigateToNotification: () => context.go('/notification-settings'),
          onNavigateToHelp: () => context.go('/help'),
          onNavigateToTerms: () => context.go('/terms'),
          onNavigateToFeedback: () => context.go('/feedback'),
          onBack: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsPage(
          userName: _auth.user?.name ?? '사용자',
          userElementLabel: _auth.user?.elementLabel ?? '화의 사람',
          onEditProfile: () => context.go('/profile'),
          onLogout: () {
            _auth.logout();
            context.go('/login');
          },
        ),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => NotificationSettingsPage(
          onBack: () => context.go('/more'),
        ),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => HelpPage(
          onBack: () => context.go('/more'),
        ),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => TermsPage(
          onBack: () => context.go('/more'),
        ),
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => FeedbackPage(
          onBack: () => context.go('/more'),
        ),
      ),
      GoRoute(
        path: '/app-info',
        builder: (context, state) => AppInfoPage(
          onBack: () => context.go('/more'),
        ),
      ),
      GoRoute(
        path: '/board',
        builder: (context, state) => BoardPage(
          isLoggedIn: _auth.isLoggedIn,
          onNavigateToLogin: () => context.go('/login'),
          onNavigateToWritePost: () => context.go('/write-post'),
          onNavigateToMessages: () => context.go('/messages'),
          onNavigateToFriends: () => context.go('/friends'),
          onNavigateToOhangFire: () => context.go('/ohang/fire'),
          onNavigateToOhangWater: () => context.go('/ohang/water'),
          onNavigateToOhangWood: () => context.go('/ohang/wood'),
          onNavigateToOhangMetal: () => context.go('/ohang/metal'),
          onNavigateToOhangEarth: () => context.go('/ohang/earth'),
          posts: const [],
        ),
      ),
      GoRoute(
        path: '/write-post',
        builder: (context, state) => WritePostPage(
          onBack: () => context.go('/board'),
          onSubmit: (payload) async {
            // 게시글 업로드 로직
            await Future<void>.delayed(const Duration(seconds: 1));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('게시글이 성공적으로 업로드되었습니다!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
              context.go('/board');
            }
          },
        ),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => MessagesPage(
          onBack: () => context.go('/board'),
          threads: const [],
        ),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => FriendsPage(
          friends: _sampleFriends,
          onBack: () => context.go('/board'),
          onNavigateToAddFriend: () => context.go('/add-friend'),
          onNavigateToManagement: () => context.go('/friend-management'),
          onSendMessage: (friend) => context.go(
            '/send-message',
            extra: {'name': friend.name, 'id': friend.id},
          ),
          onCheckCompatibility: (friend) => context.go(
            '/saju/compatibility',
            extra: {'friend': friend},
          ),
        ),
      ),
      GoRoute(
        path: '/send-message',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, String>) {
            return SendMessagePage(
              recipientName: extra['name'] ?? '친구',
              recipientId: extra['id'] ?? '',
              onBack: () => context.go('/friends'),
              onSend: (message) async {
                // 쪽지 전송 로직
                await Future<void>.delayed(const Duration(seconds: 1));
              },
            );
          }
          return SendMessagePage(
            recipientName: '친구',
            recipientId: '',
            onBack: () => context.go('/friends'),
          );
        },
      ),
      GoRoute(
        path: '/add-friend',
        builder: (context, state) => AddFriendPage(
          onBack: () => context.go('/friends'),
          recommendedFriends: _recommendedFriends,
          onSubmitRequest: (query) async {
            // 친구 요청 전송 로직
            await Future<void>.delayed(const Duration(seconds: 1));
          },
        ),
      ),
      GoRoute(
        path: '/friend-management',
        builder: (context, state) => FriendManagementPage(
          onBack: () => context.go('/friends'),
          blockedUsers: _blockedUsers,
          friendRequests: _friendRequests,
          onUnblock: (user) {
            // 차단 해제 로직
          },
          onAcceptRequest: (request) {
            // 친구 요청 수락 로직
          },
          onViewProfile: (request) {
            // 프로필 보기 로직 (친구 요청 모달에서 사용)
          },
        ),
      ),
      GoRoute(
        path: '/my-posts',
        builder: (context, state) => MyPostsPage(
          posts: const [],
          onBack: () => context.go('/profile'),
          onWritePost: () => context.go('/write-post'),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfilePage(
          userName: _auth.user?.name ?? '사용자',
          userEmail: _auth.user?.email ?? '',
          onBack: () => context.go('/home'),
          onNavigateToMySaju: () => context.go('/my-saju'),
          onNavigateToMyPosts: () => context.go('/my-posts'),
          onNavigateToAccountSettings: () => context.go('/account-settings'),
        ),
      ),
      GoRoute(
        path: '/account-settings',
        builder: (context, state) => AccountSettingsPage(
          onBack: () => context.go('/profile'),
          onSave: (data) async {},
        ),
      ),
      GoRoute(
        path: '/ohang/fire',
        builder: (context, state) => OhangFirePage(
          isLoggedIn: _auth.isLoggedIn,
          posts: const [],
          onBack: () => context.go('/board'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
        ),
      ),
      GoRoute(
        path: '/ohang/water',
        builder: (context, state) => OhangWaterPage(
          isLoggedIn: _auth.isLoggedIn,
          posts: const [],
          onBack: () => context.go('/board'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
        ),
      ),
      GoRoute(
        path: '/ohang/wood',
        builder: (context, state) => OhangWoodPage(
          isLoggedIn: _auth.isLoggedIn,
          posts: const [],
          onBack: () => context.go('/board'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
        ),
      ),
      GoRoute(
        path: '/ohang/metal',
        builder: (context, state) => OhangMetalPage(
          isLoggedIn: _auth.isLoggedIn,
          posts: const [],
          onBack: () => context.go('/board'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
        ),
      ),
      GoRoute(
        path: '/ohang/earth',
        builder: (context, state) => OhangEarthPage(
          isLoggedIn: _auth.isLoggedIn,
          posts: const [],
          onBack: () => context.go('/board'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
        ),
      ),
    ],
  );
}

