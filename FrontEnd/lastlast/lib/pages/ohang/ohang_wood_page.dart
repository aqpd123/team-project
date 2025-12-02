import 'package:flutter/material.dart';

import 'ohang_detail_page.dart';

class OhangWoodPage extends StatelessWidget {
  const OhangWoodPage({
    super.key,
    required this.isLoggedIn,
    this.onBack,
    this.onNavigateToBoard,
    this.onNavigateToLogin,
    this.onWritePost,
    this.onOpenPost,
  });

  final bool isLoggedIn;
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToBoard;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onWritePost;
  final ValueChanged<int>? onOpenPost;

  static const _element = OhangElementData(
    key: 'wood',
    title: '목 (木)',
    description: '나무의 기운 · 성장과 확장',
    icon: Icons.eco,
    gradient: [Color(0xFF34D399), Color(0xFF10B981)],
  );

  @override
  Widget build(BuildContext context) {
    return OhangDetailPage(
      element: _element,
      isLoggedIn: isLoggedIn,
      onBack: onBack,
      onNavigateToBoard: onNavigateToBoard,
      onNavigateToLogin: onNavigateToLogin,
      onWritePost: onWritePost,
      onOpenPost: onOpenPost,
    );
  }
}

