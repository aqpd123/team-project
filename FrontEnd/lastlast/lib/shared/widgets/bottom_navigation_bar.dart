import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// React `components/layout/BottomNavigation.tsx`를 Flutter로 변환한 위젯.
/// 모든 메인 페이지에서 사용할 수 있는 하단 네비게이션 바입니다.
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentPath,
  });

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(
        path: '/home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: '홈',
      ),
      _NavItem(
        path: '/board',
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: '커뮤니티',
      ),
      _NavItem(
        path: '/more',
        icon: Icons.more_horiz,
        activeIcon: Icons.more_horiz,
        label: '더보기',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.asMap().entries.map((entry) {
              final item = entry.value;
              final isActive = currentPath == item.path;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isActive) {
                      context.go(item.path);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive
                            ? const Color(0xFFFDE047) // yellow-300
                            : Colors.white.withValues(alpha: 0.6),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFFFDE047) // yellow-300
                              : Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

