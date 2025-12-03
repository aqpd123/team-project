import 'package:flutter/material.dart';

/// React `pages/saju/page.tsx` 대응 Flutter 위젯.
/// 외부에서 라우팅 콜백을 주입받아 버튼 클릭 시 원하는 화면으로 이동하도록 했다.
class SajuPage extends StatelessWidget {
  const SajuPage({
    super.key,
    this.onBack,
    this.onNavigateToInput,
    this.onNavigateToCompatibility,
    this.onNavigateToCelebrity,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNavigateToInput;
  final VoidCallback? onNavigateToCompatibility;
  final VoidCallback? onNavigateToCelebrity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E1B4B),
                    Color(0xFF2E1065),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.network(
              'https://readdy.ai/api/search-image?query=mystical%20kawaii%20illustration%20style%2C%20traditional%20Korean%20hanok%20village%20at%20peaceful%20night%20scene%2C%20high%20quality%20detailed%20artwork%2C%20soft%20dreamy%20aesthetic%2C%20cozy%20traditional%20houses%20with%20warm%20glowing%20paper%20lanterns%2C%20majestic%20bright%20full%20moon%20illuminating%20the%20dark%20blue%20starry%20sky%2C%20countless%20twinkling%20stars%20scattered%20across%20the%20heavens%2C%20serene%20reflecting%20pond%20with%20elegant%20small%20stone%20bridge%2C%20misty%20ethereal%20atmosphere%2C%20soft%20pastel%20night%20colors%20with%20deep%20blues%20and%20purples%2C%20traditional%20Korean%20architecture%20with%20curved%20rooftops%2C%20gentle%20mist%20rising%20from%20the%20water%2C%20enchanted%20fairy%20tale%20ambiance%2C%20nostalgic%20vintage%20feel%2C%20mobile%20wallpaper%20vertical%20composition%2C%20mystical%20lighting%20effects%2C%20peaceful%20zen%20garden%20elements&width=375&height=812&seq=mystical-hanok-night&orientation=portrait',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.black.withValues(alpha: 0.2),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildOptionButton(
                      label: '사주보기',
                      description: '나의 운명과 성격을 알아보세요',
                      emoji: '🌟',
                      gradientColors: const [
                        Color(0xFFFACC15),
                        Color(0xFFF97316),
                      ],
                      onTap: onNavigateToInput,
                    ),
                    const SizedBox(height: 16),
                    _buildOptionButton(
                      label: '사주궁합보기',
                      description: '두 사람의 궁합을 확인해보세요',
                      emoji: '💕',
                      gradientColors: const [
                        Color(0xFFF472B6),
                        Color(0xFFFB7185),
                      ],
                      onTap: onNavigateToCompatibility,
                    ),
                    const SizedBox(height: 16),
                    _buildOptionButton(
                      label: '유명인과 사주보기',
                      description: '유명인과 나의 궁합을 확인해보세요',
                      emoji: '⭐',
                      gradientColors: const [
                        Color(0xFF8B5CF6),
                        Color(0xFF6366F1),
                      ],
                      onTap: onNavigateToCelebrity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CircleButton(
          icon: Icons.arrow_back,
          onTap: onBack,
        ),
        Expanded(
          child: Center(
            child: const Text(
              '사주보기 🔮',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 6,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildOptionButton({
    required String label,
    required String description,
    required String emoji,
    required List<Color> gradientColors,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
