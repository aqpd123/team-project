import 'package:flutter/material.dart';

import '../../shared/widgets/blur_card.dart';
import '../../shared/widgets/bottom_navigation_bar.dart';
import '../../shared/widgets/menu_tile.dart';
import '../../shared/widgets/mystic_background.dart';

class MorePage extends StatelessWidget {
  const MorePage({
    super.key,
    required this.isLoggedIn,
    this.currentPath = '/more',
    this.userName,
    this.userEmail,
    this.onNavigateToLogin,
    this.onNavigateToProfile,
    this.onNavigateToNotification,
    this.onNavigateToHelp,
    this.onNavigateToTerms,
    this.onNavigateToFeedback,
    this.onBack,
  });

  final bool isLoggedIn;
  final String currentPath;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToNotification;
  final VoidCallback? onNavigateToHelp;
  final VoidCallback? onNavigateToTerms;
  final VoidCallback? onNavigateToFeedback;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        body: MysticBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFACC15), Color(0xFFF97316)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🌙', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '로그인이 필요해요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '더 많은 기능을 사용하려면 로그인해주세요.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onNavigateToLogin,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    backgroundColor: const Color(0xFFFACC15),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '로그인하기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: MysticBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '더보기 ⚙️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlurCard(
                  child: Row(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFACC15), Color(0xFFF97316)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName ?? '사용자',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail ?? '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MenuTile(
                          icon: Icons.person_outline,
                          title: '프로필 설정',
                          subtitle: '개인정보 및 계정 관리',
                          onTap: onNavigateToProfile,
                          iconColors: const [Color(0xFF8B5CF6), Color(0xFFE879F9)],
                        ),
                        const SizedBox(height: 12),
                        MenuTile(
                          icon: Icons.notifications_none,
                          title: '알림 설정',
                          subtitle: '푸시 알림 및 소리 설정',
                          onTap: onNavigateToNotification,
                          iconColors: const [Color(0xFF38BDF8), Color(0xFF22D3EE)],
                        ),
                        const SizedBox(height: 12),
                        MenuTile(
                          icon: Icons.help_outline,
                          title: '도움말',
                          subtitle: '사용법 및 자주 묻는 질문',
                          onTap: onNavigateToHelp,
                          iconColors: const [Color(0xFF34D399), Color(0xFF10B981)],
                        ),
                        const SizedBox(height: 12),
                        MenuTile(
                          icon: Icons.description_outlined,
                          title: '서비스 약관',
                          subtitle: '이용약관 및 개인정보방침',
                          onTap: onNavigateToTerms,
                          iconColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        const SizedBox(height: 12),
                        MenuTile(
                          icon: Icons.feedback_outlined,
                          title: '피드백 보내기',
                          subtitle: '개발자에게 의견 전달하기',
                          onTap: onNavigateToFeedback,
                          iconColors: const [Color(0xFFF472B6), Color(0xFFFB7185)],
                        ),
                        // 하단 여백 추가 (네비게이션 바와 겹치도록)
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 80,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          AppBottomNavigationBar(currentPath: currentPath),
    );
  }
}

