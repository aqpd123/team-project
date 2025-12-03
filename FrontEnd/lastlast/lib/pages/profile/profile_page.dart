import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/widgets/mystic_background.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.userName = '사용자',
    this.userEmail = '',
    this.avatarImage,
    this.characterType,
    this.onChangeAvatar,
    this.onNavigateToMyPosts,
    this.onNavigateToAccountSettings,
    this.onBack,
  });

  final String userName;
  final String userEmail;
  final ImageProvider? avatarImage;
  final String? characterType; // 'wood', 'fire', 'earth', 'metal', 'water'
  final VoidCallback? onChangeAvatar;
  final VoidCallback? onNavigateToMyPosts;
  final VoidCallback? onNavigateToAccountSettings;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    // 하단 단축키 투명도 방지
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          MysticBackground(
            padding: EdgeInsets.zero,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                children: [
              Row(
                children: [
                  _circleButton(Icons.arrow_back, onBack),
                  const SizedBox(width: 12),
                  const Text(
                    '프로필 설정',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _profileHeader(),
              const SizedBox(height: 16),
              _menuButton(
                icon: Icons.article_outlined,
                gradient: const [Color(0xFF38BDF8), Color(0xFF22D3EE)],
                title: '나의 글 관리',
                subtitle: '작성한 게시글 확인 및 관리',
                onTap: onNavigateToMyPosts,
              ),
              const SizedBox(height: 12),
              _menuButton(
                icon: Icons.settings_outlined,
                gradient: const [Color(0xFF8B5CF6), Color(0xFFE879F9)],
                title: '계정 설정',
                subtitle: '비밀번호 변경 및 계정 관리',
                onTap: onNavigateToAccountSettings,
              ),
            ],
          ),
        ),
          ),
          // 하단 단축키 영역을 덮는 검정색 배경
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).padding.bottom,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    // 오행에 따른 이미지 파일명 매핑
    final characterImageMap = {
      'wood': 'assets/tree.png',
      'fire': 'assets/fire.png',
      'earth': 'assets/land.png',
      'metal': 'assets/gold.png',
      'water': 'assets/water.png',
    };
    
    final characterImagePath = characterType != null 
        ? characterImageMap[characterType] 
        : null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              avatarImage != null
                  ? CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      backgroundImage: avatarImage,
                    )
                  : (characterImagePath != null
                      ? ClipOval(
                          child: Image.asset(
                            characterImagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                child: const Icon(Icons.person_outline,
                                    color: Colors.white70, size: 36),
                              );
                            },
                          ),
                        )
                      : CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          child: const Icon(Icons.person_outline,
                              color: Colors.white70, size: 36),
                        )),
              if (onChangeAvatar != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: onChangeAvatar,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (userEmail.isNotEmpty)
            Text(
              userEmail,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required List<Color> gradient,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(colors: gradient),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

