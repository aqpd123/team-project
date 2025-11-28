import 'package:flutter/material.dart';

import 'ohang_detail_page.dart';

class OhangFirePage extends StatelessWidget {
  const OhangFirePage({
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
      posts: posts,
      onBack: onBack,
      onNavigateToBoard: onNavigateToBoard,
      onNavigateToLogin: onNavigateToLogin,
      onWritePost: onWritePost,
    );
  }
}

