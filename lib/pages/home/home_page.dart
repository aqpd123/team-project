import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/bottom_navigation_bar.dart';

/// Flutter 변환 버전의 홈 화면.
/// 외부에서 인증 상태 및 내비게이션 콜백을 주입받아
/// 기존 React `useAuth`/`useNavigate` 동작을 대체한다.
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isLoggedIn,
    this.onNavigateToLogin,
    this.onNavigateToSaju,
    this.onNavigateToBoard,
    this.onNavigateToMore,
  });

  final bool isLoggedIn;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onNavigateToSaju;
  final VoidCallback? onNavigateToBoard;
  final VoidCallback? onNavigateToMore;

  void _handleSajuTap() {
    if (!isLoggedIn) {
      onNavigateToLogin?.call();
      return;
    }
    onNavigateToSaju?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ====== 메인 콘텐츠 ======
      body: Stack(
        children: [
          // 배경 그라데이션
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A), // slate-900
                    Color(0xFF1E1B4B), // indigo-900
                    Color(0xFF2E1065), // purple-900
                  ],
                ),
              ),
            ),
          ),
          // 배경 이미지
          Positioned.fill(
            child: Image.network(
              'https://readdy.ai/api/search-image?query=mystical%20kawaii%20illustration%20style%2C%20traditional%20Korean%20hanok%20village%20at%20peaceful%20night%20scene%2C%20high%20quality%20detailed%20artwork%2C%20soft%20dreamy%20aesthetic%2C%20cozy%20traditional%20houses%20with%20warm%20glowing%20paper%20lanterns%2C%20majestic%20bright%20full%20moon%20illuminating%20the%20dark%20blue%20starry%20sky%2C%20countless%20twinkling%20stars%20scattered%20across%20the%20heavens%2C%20serene%20reflecting%20pond%20with%20elegant%20small%20stone%20bridge%2C%20misty%20ethereal%20atmosphere%2C%20soft%20pastel%20night%20colors%20with%20deep%20blues%20and%20purples%2C%20traditional%20Korean%20architecture%20with%20curved%20rooftops%2C%20gentle%20mist%20rising%20from%20the%20water%2C%20enchanted%20fairy%20tale%20ambiance%2C%20nostalgic%20vintage%20feel%2C%20mobile%20wallpaper%20vertical%20composition%2C%20mystical%20lighting%20effects%2C%20peaceful%20zen%20garden%20elements&width=375&height=812&seq=mystical-hanok-night&orientation=portrait',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // 오버레이
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          // 메인 텍스트 + 버튼 + 설명
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                // 아래에 네비게이션바 들어갈 공간 조금 남겨둠
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 96),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildMainButton(),
                    const SizedBox(height: 32),
                    _buildFooterText(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ====== 하단 네비게이션 바 ======
      bottomNavigationBar: Builder(
        builder: (context) {
          final currentPath = GoRouterState.of(context).uri.path;
          return AppBottomNavigationBar(currentPath: currentPath);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          '운명을 만드는\n공간 ✨',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            height: 1.3,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 6,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text(
          '나의 오행을 찾아서',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFA5F3FC),
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onTap: _handleSajuTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFACC15),
                        Color(0xFFF97316),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text('🔮', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '사주보러가기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '별빛이 알려주는 나의 운명',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return const Text(
      '별빛이 내려앉은 신비로운 밤\n당신만의 특별한 이야기를 찾아보세요 🌙',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white70,
        fontSize: 18,
        height: 1.5,
      ),
    );
  }
}
