import 'package:go_router/go_router.dart';

import 'controllers/auth_controller.dart';
import 'models/friend_models.dart';
import 'models/saju_models.dart';
import 'pages/auth/login_page.dart';
import 'models/community_post.dart';
import 'pages/community/board_page.dart';
import 'pages/community/messages_page.dart';
import 'pages/community/my_posts_page.dart';
import 'pages/community/post_detail_page.dart';
import 'pages/community/write_post_page.dart';
import 'pages/home/home_page.dart';
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
import 'pages/social/add_friend_page.dart';
import 'pages/social/friend_management_page.dart';
import 'pages/social/friends_page.dart';
import 'pages/social/send_message_page.dart';
import 'pages/splash/splash_page.dart';
import 'pages/support/app_info_page.dart';
import 'pages/support/feedback_page.dart';
import 'pages/support/help_page.dart';
import 'pages/support/notification_settings_page.dart';
import 'pages/support/terms_page.dart';

class AppRouter {
  AppRouter(this._auth);

  final AuthController _auth;

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
    initialLocation: '/',
    refreshListenable: _auth,
    redirect: (context, state) {
      final path = state.uri.path;
      final loggingIn = path == '/login';
      final needsAuth =
          _guardedPaths.contains(path) || path.startsWith('/posts/');
      if (!_auth.isLoggedIn && needsAuth) return '/login';
      if (_auth.isLoggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashPage(
          onFinished: () => context.go(_auth.isLoggedIn ? '/home' : '/login'),
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
          currentPath: state.uri.path,
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
        builder: (context, state) {
          final extra = state.extra;
          FriendData? friendData;
          if (extra is Map<String, dynamic> && extra['friend'] is FriendData) {
            friendData = extra['friend'] as FriendData;
          }
          return SajuInputPage(
            onBack: () => friendData != null
                ? context.go('/friends')
                : context.go('/saju'),
            friendData: friendData,
          );
        },
      ),
      GoRoute(
        path: '/saju/compatibility',
        builder: (context, state) {
          final extra = state.extra;
          FriendData? friendData;
          SajuCompatibilityResult? result;
          String? person1Name;
          String? person2Name;

          if (extra is Map<String, dynamic>) {
            if (extra['friend'] is FriendData) {
              friendData = extra['friend'] as FriendData;
            }
            if (extra['result'] is SajuCompatibilityResult) {
              result = extra['result'] as SajuCompatibilityResult;
            }
            if (extra['person1Name'] is String) {
              person1Name = extra['person1Name'] as String;
            }
            if (extra['person2Name'] is String) {
              person2Name = extra['person2Name'] as String;
            }
          }

          return SajuCompatibilityPage(
            onBack: () => friendData != null
                ? context.go('/friends')
                : context.go('/saju'),
            friendData: friendData,
            initialResult: result,
            person1Name: person1Name,
            person2Name: person2Name,
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
        builder: (context, state) {
          // 프로필 설정에서 왔는지 확인
          final fromProfile = state.uri.queryParameters['from'] == 'profile';
          final fromMore = state.uri.queryParameters['fromMore'] == 'true';

          // extra에서 분석 결과 받기
          SajuAnalysisResult? initialResult;
          Map<String, String>? initialUserInfo;

          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            if (extra['result'] is SajuAnalysisResult) {
              initialResult = extra['result'] as SajuAnalysisResult;
            }
            if (extra['userInfo'] is Map<String, String>) {
              initialUserInfo = extra['userInfo'] as Map<String, String>;
            }
          }

          return MySajuPage(
            initialResult: initialResult,
            initialUserInfo: initialUserInfo,
            onBack: () {
              if (fromProfile) {
                // 더보기에서 왔으면 더보기로, 아니면 프로필로
                if (fromMore) {
                  context.go('/profile?from=more');
                } else {
                  context.go('/profile');
                }
              } else {
                context.go('/home');
              }
            },
            onNavigateToSaju: () => context.go('/saju'),
          );
        },
      ),
      GoRoute(
        path: '/more',
        builder: (context, state) {
          // characterType을 직접 사용 (이미 영어 오행 타입)
          final characterType = _auth.user?.characterType;

          return MorePage(
            isLoggedIn: _auth.isLoggedIn,
            currentPath: state.uri.path,
            userName: _auth.user?.name,
            userEmail: _auth.user?.email,
            characterType: characterType,
            onNavigateToLogin: () => context.go('/login'),
            onNavigateToProfile: () => context.go('/profile?from=more'),
            onNavigateToNotification: () =>
                context.go('/notification-settings'),
            onNavigateToHelp: () => context.go('/help'),
            onNavigateToTerms: () => context.go('/terms'),
            onNavigateToFeedback: () => context.go('/feedback'),
            onBack: () => context.go('/home'),
          );
        },
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
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          return BoardPage(
            isLoggedIn: _auth.isLoggedIn,
            initialTab:
                tab == 'ohang' ? BoardCategory.ohang : BoardCategory.anonymous,
            onNavigateToLogin: () => context.go('/login'),
            onNavigateToWritePost: () => context.go('/write-post'),
            onNavigateToMessages: () => context.go('/messages'),
            onNavigateToFriends: () => context.go('/friends'),
            onNavigateToOhangFire: () => context.go('/ohang/fire'),
            onNavigateToOhangWater: () => context.go('/ohang/water'),
            onNavigateToOhangWood: () => context.go('/ohang/wood'),
            onNavigateToOhangMetal: () => context.go('/ohang/metal'),
            onNavigateToOhangEarth: () => context.go('/ohang/earth'),
            onOpenPost: (id) => context.go('/posts/$id'),
          );
        },
      ),
      GoRoute(
        path: '/posts/:postId',
        builder: (context, state) {
          final rawId = state.pathParameters['postId'];
          final postId = int.tryParse(rawId ?? '');
          final fromParam = state.uri.queryParameters['from'];
          final fromMyPosts = fromParam == 'my-posts';
          final fromMore = state.uri.queryParameters['fromMore'] == 'true';

          if (postId == null) {
            return BoardPage(
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
              onOpenPost: (id) => context.go('/posts/$id'),
            );
          }

          // 뒤로가기 경로 결정
          void Function()? onBackCallback;
          if (fromMyPosts) {
            onBackCallback = () =>
                context.go('/my-posts${fromMore ? '?fromMore=true' : ''}');
          } else if (fromParam == 'ohang-fire') {
            onBackCallback = () => context.go('/ohang/fire');
          } else if (fromParam == 'ohang-water') {
            onBackCallback = () => context.go('/ohang/water');
          } else if (fromParam == 'ohang-wood') {
            onBackCallback = () => context.go('/ohang/wood');
          } else if (fromParam == 'ohang-metal') {
            onBackCallback = () => context.go('/ohang/metal');
          } else if (fromParam == 'ohang-earth') {
            onBackCallback = () => context.go('/ohang/earth');
          } else {
            onBackCallback = () => context.go('/board');
          }

          return PostDetailPage(
            postId: postId,
            onBack: onBackCallback,
          );
        },
      ),
      GoRoute(
        path: '/write-post',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final postId = extra['postId'];
            // postId가 존재하고 0이 아닌 경우 수정 모드
            if (postId != null && postId is int && postId > 0) {
              // 수정 모드
              return WritePostPage(
                postId: postId,
                initialTitle: extra['title']?.toString(),
                initialContent: extra['content']?.toString(),
                initialBoardType: extra['boardType']?.toString(),
                onBack: () => context.go('/board'),
              );
            }
          }
          // 작성 모드
          return WritePostPage(
            onBack: () => context.go('/board'),
          );
        },
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => MessagesPage(
          onBack: () => context.go('/board'),
          onOpenThread: (thread) => context.go(
            '/send-message',
            extra: {
              'name': thread.peerName,
              'id': thread.peerId,
              'isAnonymous': thread.isAnonymous,
            },
          ),
        ),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => FriendsPage(
          onBack: () => context.go('/board'),
          onNavigateToAddFriend: () => context.go('/add-friend'),
          onNavigateToManagement: () => context.go('/friend-management'),
          onSendMessage: (friend) => context.go(
            '/send-message',
            extra: {'name': friend.name, 'id': friend.userId},
          ),
          onCheckCompatibility: (friend) => context.go(
            '/saju/input',
            extra: {'friend': friend},
          ),
        ),
      ),
      GoRoute(
        path: '/send-message',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final rawId = extra['id'];
            final peerId =
                rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
            if (peerId != null) {
              final isAnonymous = extra['isAnonymous'] as bool? ?? false;
              return SendMessagePage(
                recipientName: (extra['name'] ?? '친구') as String,
                recipientId: peerId,
                isAnonymous: isAnonymous,
                onBack: () =>
                    context.go(isAnonymous ? '/messages' : '/friends'),
              );
            }
          }
          return SendMessagePage(
            recipientName: '친구',
            recipientId: 0,
            isAnonymous: false,
            onBack: () => context.go('/friends'),
          );
        },
      ),
      GoRoute(
        path: '/add-friend',
        builder: (context, state) => AddFriendPage(
          onBack: () => context.go('/friends'),
        ),
      ),
      GoRoute(
        path: '/friend-management',
        builder: (context, state) => FriendManagementPage(
          onBack: () => context.go('/friends'),
        ),
      ),
      GoRoute(
        path: '/my-posts',
        builder: (context, state) {
          // 프로필 설정에서 왔는지 확인
          final fromMore = state.uri.queryParameters['fromMore'] == 'true';

          return MyPostsPage(
            fromMore: fromMore,
            onBack: () {
              // 더보기에서 왔으면 더보기로, 아니면 프로필로
              if (fromMore) {
                context.go('/profile?from=more');
              } else {
                context.go('/profile');
              }
            },
            onWritePost: () => context.go('/write-post'),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          // 더보기에서 왔는지 확인
          final fromMore = state.uri.queryParameters['from'] == 'more';

          // characterType을 직접 사용 (이미 영어 오행 타입)
          final characterType = _auth.user?.characterType;

          return ProfilePage(
            userName: _auth.user?.name ?? '사용자',
            userEmail: _auth.user?.email ?? '',
            characterType: characterType,
            onBack: () {
              // 더보기에서 왔으면 더보기로, 아니면 이전 경로로 또는 홈으로
              if (fromMore) {
                context.go('/more');
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            onNavigateToMyPosts: () =>
                context.go('/my-posts${fromMore ? '?fromMore=true' : ''}'),
            onNavigateToAccountSettings: () => context
                .go('/account-settings${fromMore ? '?fromMore=true' : ''}'),
          );
        },
      ),
      GoRoute(
        path: '/account-settings',
        builder: (context, state) {
          // 프로필 설정에서 왔는지 확인
          final fromMore = state.uri.queryParameters['fromMore'] == 'true';

          return AccountSettingsPage(
            onBack: () {
              // 더보기에서 왔으면 더보기로, 아니면 프로필로
              if (fromMore) {
                context.go('/profile?from=more');
              } else {
                context.go('/profile');
              }
            },
            onSave: (data) async {},
            onLogout: () {
              _auth.logout();
              context.go('/login');
            },
          );
        },
      ),
      GoRoute(
        path: '/ohang/fire',
        builder: (context, state) => OhangFirePage(
          isLoggedIn: _auth.isLoggedIn,
          onBack: () => context.go('/board?tab=ohang'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
          onOpenPost: (id) => context.go('/posts/$id?from=ohang-fire'),
        ),
      ),
      GoRoute(
        path: '/ohang/water',
        builder: (context, state) => OhangWaterPage(
          isLoggedIn: _auth.isLoggedIn,
          onBack: () => context.go('/board?tab=ohang'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
          onOpenPost: (id) => context.go('/posts/$id?from=ohang-water'),
        ),
      ),
      GoRoute(
        path: '/ohang/wood',
        builder: (context, state) => OhangWoodPage(
          isLoggedIn: _auth.isLoggedIn,
          onBack: () => context.go('/board?tab=ohang'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
          onOpenPost: (id) => context.go('/posts/$id?from=ohang-wood'),
        ),
      ),
      GoRoute(
        path: '/ohang/metal',
        builder: (context, state) => OhangMetalPage(
          isLoggedIn: _auth.isLoggedIn,
          onBack: () => context.go('/board?tab=ohang'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
          onOpenPost: (id) => context.go('/posts/$id?from=ohang-metal'),
        ),
      ),
      GoRoute(
        path: '/ohang/earth',
        builder: (context, state) => OhangEarthPage(
          isLoggedIn: _auth.isLoggedIn,
          onBack: () => context.go('/board?tab=ohang'),
          onNavigateToLogin: () => context.go('/login'),
          onWritePost: () => context.go('/write-post'),
          onOpenPost: (id) => context.go('/posts/$id?from=ohang-earth'),
        ),
      ),
    ],
  );
}
