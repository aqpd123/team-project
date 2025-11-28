import 'package:flutter/material.dart';

import 'ohang_detail_page.dart';

class OhangWaterPage extends StatelessWidget {
  const OhangWaterPage({
    super.key,
    required this.isLoggedIn,
    this.posts = const [],
    this.onBack,
    this.onNavigateToBoard,
    this.onNavigateToLogin,
    this.onWritePost,
  });

  final bool isLoggedIn;
  final List<OhangPost> posts;
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToBoard;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onWritePost;

  static const _element = OhangElementData(
    key: 'water',
    title: '수 (水)',
    description: '물의 기운 · 흐르는 지혜',
    icon: Icons.water_drop,
    gradient: [Color(0xFF38BDF8), Color(0xFF22D3EE)],
  );

  @override
  Widget build(BuildContext context) {
    return OhangDetailPage(
      element: _element,
      isLoggedIn: isLoggedIn,
      posts: posts,
      onBack: onBack,
      onNavigateToBoard: onNavigateToBoard,
      onNavigateToLogin: onNavigateToLogin,
      onWritePost: onWritePost,
    );
  }
}

