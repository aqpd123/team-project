import 'package:flutter/material.dart';

import '../../shared/widgets/blur_card.dart';
import '../../shared/widgets/mystic_background.dart';

class SettingItemData {
  const SettingItemData({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.userName,
    required this.userElementLabel,
    this.onEditProfile,
    this.onLogout,
    this.items = const [],
  });

  final String userName;
  final String userElementLabel;
  final VoidCallback? onEditProfile;
  final VoidCallback? onLogout;
  final List<SettingItemData> items;

  List<SettingItemData> get _defaultItems => [
        SettingItemData(
          icon: Icons.person_outline,
          title: '프로필 설정',
          description: '개인정보 및 프로필 관리',
          onTap: onEditProfile,
        ),
        SettingItemData(
          icon: Icons.notifications_active_outlined,
          title: '알림 설정',
          description: '푸시 알림 및 소리 설정',
        ),
        SettingItemData(
          icon: Icons.palette_outlined,
          title: '테마 설정',
          description: '앱 테마 및 색상 변경',
        ),
        SettingItemData(
          icon: Icons.shield_outlined,
          title: '개인정보 보호',
          description: '데이터 보안 및 개인정보 설정',
        ),
        SettingItemData(
          icon: Icons.help_outline,
          title: '도움말',
          description: '사용법 및 FAQ',
        ),
        SettingItemData(
          icon: Icons.info_outline,
          title: '앱 정보',
          description: '버전 정보 및 업데이트',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final listItems = items.isEmpty ? _defaultItems : items;

    return Scaffold(
      body: MysticBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                '설정 ⚙️',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            BlurCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userElementLabel,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA855F7),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('프로필 편집'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: listItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = listItems[index];
                  return GestureDetector(
                    onTap: item.onTap,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon,
                                color: const Color(0xFFFACC15)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
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
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.08),
                foregroundColor: const Color(0xFFF87171),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}

