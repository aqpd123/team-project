import 'package:flutter/material.dart';

import 'ohang_detail_page.dart';

class OhangFirePage extends StatelessWidget {
  const OhangFirePage({
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
    key: 'fire',
    title: '화 (火)',
    description: '불의 기운 · 뜨거운 열정',
    icon: Icons.local_fire_department,
    gradient: [Color(0xFFF87171), Color(0xFFF97316)],
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

