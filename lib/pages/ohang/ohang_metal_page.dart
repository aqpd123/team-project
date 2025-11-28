import 'package:flutter/material.dart';

import 'ohang_detail_page.dart';

class OhangMetalPage extends StatelessWidget {
  const OhangMetalPage({
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
      posts: posts,
      onBack: onBack,
      onNavigateToBoard: onNavigateToBoard,
      onNavigateToLogin: onNavigateToLogin,
      onWritePost: onWritePost,
    );
  }
}

