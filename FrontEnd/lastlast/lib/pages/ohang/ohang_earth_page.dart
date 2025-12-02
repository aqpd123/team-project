import 'package:flutter/material.dart';

import 'ohang_detail_page.dart';

class OhangEarthPage extends StatelessWidget {
  const OhangEarthPage({
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
    key: 'earth',
    title: '토 (土)',
    description: '대지의 기운 · 안정과 중심',
    icon: Icons.landscape_outlined,
    gradient: [Color(0xFFD97706), Color(0xFFB45309)],
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

