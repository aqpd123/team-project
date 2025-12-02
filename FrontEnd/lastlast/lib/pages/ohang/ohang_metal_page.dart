import 'package:flutter/material.dart';

import 'ohang_detail_page.dart';

class OhangMetalPage extends StatelessWidget {
  const OhangMetalPage({
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
    key: 'metal',
    title: '금 (金)',
    description: '금속의 기운 · 결단과 규율',
    icon: Icons.hexagon_outlined,
    gradient: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
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

