import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.dateLabel,
    this.likes = 0,
    this.comments = 0,
    this.onTap,
    this.authorCharacterType,
    this.showAvatar = false,
  });

  final String title;
  final String content;
  final String author;
  final String dateLabel;
  final int likes;
  final int comments;
  final VoidCallback? onTap;
  final String? authorCharacterType; // 작성자의 오행 캐릭터 타입
  final bool showAvatar; // 프로필 사진 표시 여부

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  dateLabel,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            if (showAvatar && authorCharacterType != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildAvatar(authorCharacterType!),
                  const SizedBox(width: 8),
                  Text(
                    author,
                    style: const TextStyle(
                      color: Color(0xFFA5F3FC),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(color: Colors.white70, height: 1.5),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _iconStat(Icons.favorite_border, likes),
                const SizedBox(width: 12),
                _iconStat(Icons.chat_bubble_outline, comments),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconStat(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildAvatar(String characterType) {
    // 오행에 따른 이미지 파일명 매핑
    final characterImageMap = {
      'wood': 'assets/tree.png',
      'fire': 'assets/fire.png',
      'earth': 'assets/land.png',
      'metal': 'assets/gold.png',
      'water': 'assets/water.png',
    };
    
    final imagePath = characterImageMap[characterType.toLowerCase()];
    
    return ClipOval(
      child: imagePath != null
          ? Image.asset(
              imagePath,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 32,
                  height: 32,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white70,
                    size: 20,
                  ),
                );
              },
            )
          : Container(
              width: 32,
              height: 32,
              color: Colors.white.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white70,
                size: 20,
              ),
            ),
    );
  }
}

