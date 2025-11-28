import 'package:flutter/material.dart';

class SajuData {
  SajuData({
    required this.name,
    required this.birthDate,
    required this.gender,
  });

  final String name;
  final String birthDate;
  final String gender;
}

/// React `pages/saju/components/SajuAnalysis.tsx`의 Flutter 버전.
/// 아직 실제 분석 데이터가 없어 placeholder 텍스트로 구성한다.
class SajuAnalysisView extends StatelessWidget {
  const SajuAnalysisView({
    super.key,
    required this.sajuData,
    required this.onBack,
  });

  final SajuData sajuData;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildInfoCard(),
                            const SizedBox(height: 16),
                            _buildPillarsCard(),
                            const SizedBox(height: 16),
                            _buildElementsCard(),
                            const SizedBox(height: 16),
                            _buildPersonalityCard(),
                            const SizedBox(height: 16),
                            _buildFortuneCard(),
                            const SizedBox(height: 16),
                            _buildAdviceCard(),
                          ],
                        ),
                      ),
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

  Widget _buildBackground() {
    return Stack(
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
            color: Colors.black.withOpacity(0.2),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x330F172A),
                  Color(0x331E1B4B),
                  Color(0x332E1065),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _circleButton(
            icon: Icons.arrow_back,
            onTap: onBack,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            '${sajuData.name.isEmpty ? '사용자' : sajuData.name}님의 사주 ✨',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
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
      ],
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('기본 정보 📋'),
          const SizedBox(height: 12),
          _infoRow('이름', sajuData.name.isEmpty ? '미입력' : sajuData.name),
          _infoRow('생년월일', sajuData.birthDate.isEmpty ? '미입력' : sajuData.birthDate),
          _infoRow('성별', sajuData.gender.isEmpty ? '미입력' : sajuData.gender),
        ],
      ),
    );
  }

  Widget _buildPillarsCard() {
    return _buildCard(
      child: Column(
        children: [
          _sectionTitle('사주팔자 🔮'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: const [
              _PillarTile(label: '년주'),
              _PillarTile(label: '월주'),
              _PillarTile(label: '일주'),
              _PillarTile(label: '시주'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElementsCard() {
    const elements = [
      ('목', '🌳', Colors.green),
      ('화', '🔥', Colors.red),
      ('토', '🏔️', Colors.yellow),
      ('금', '⚡', Colors.grey),
      ('수', '💧', Colors.blue),
    ];

    return _buildCard(
      child: Column(
        children: [
          _sectionTitle('오행 분석 🌿'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: elements
                .map(
                  (e) => _ElementTile(
                    label: e.$1,
                    emoji: e.$2,
                    color: e.$3,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            '오행 분석 결과가 여기에 표시됩니다',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityCard() {
    return _buildCard(
      child: Column(
        children: const [
          _SectionHeader(
            title: '성격 분석 🎭',
          ),
          SizedBox(height: 8),
          Text(
            '성격 분석 결과가 여기에 표시됩니다',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(title: '운세 🌟'),
          SizedBox(height: 12),
          _FortuneTile(title: '연애운'),
          SizedBox(height: 8),
          _FortuneTile(title: '재물운'),
          SizedBox(height: 8),
          _FortuneTile(title: '건강운'),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    return _buildCard(
      child: Column(
        children: const [
          _SectionHeader(title: '조언 💡'),
          SizedBox(height: 8),
          Text(
            '개인 맞춤 조언이 여기에 표시됩니다',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFDE047), // yellow-300
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _PillarTile extends StatelessWidget {
  const _PillarTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA5F3FC),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '-',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementTile extends StatelessWidget {
  const _ElementTile({
    required this.label,
    required this.emoji,
    required this.color,
  });

  final String label;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade200,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '-',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFDE047), // yellow-300
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _FortuneTile extends StatelessWidget {
  const _FortuneTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFA5F3FC),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '분석 결과가 여기에 표시됩니다',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

