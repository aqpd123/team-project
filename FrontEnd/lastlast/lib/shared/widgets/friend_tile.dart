import 'package:flutter/material.dart';

class FriendTile extends StatelessWidget {
  const FriendTile({
    super.key,
    required this.name,
    required this.elementLabel,
    required this.statusLabel,
    this.characterType,
    this.onTap,
    this.trailing,
  });

  final String name;
  final String elementLabel;
  final String statusLabel;
  final String? characterType; // 영어 오행 타입 ('wood', 'fire', etc.)
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isOnline = statusLabel.contains('온라인');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                _buildAvatar(),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.greenAccent : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    elementLabel,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: isOnline ? Colors.greenAccent : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // 오행에 따른 이미지 파일명 매핑
    final characterImageMap = {
      'wood': 'assets/tree.png',
      'fire': 'assets/fire.png',
      'earth': 'assets/land.png',
      'metal': 'assets/gold.png',
      'water': 'assets/water.png',
    };

    final imagePath = characterType != null
        ? characterImageMap[characterType!.toLowerCase()]
        : null;

    return ClipOval(
      child: imagePath != null
          ? Image.asset(
              imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackAvatar();
              },
            )
          : _buildFallbackAvatar(),
    );
  }

  Widget _buildFallbackAvatar() {
    final initial = name.isEmpty
        ? '?'
        : String.fromCharCode(name.runes.first).toUpperCase();
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
