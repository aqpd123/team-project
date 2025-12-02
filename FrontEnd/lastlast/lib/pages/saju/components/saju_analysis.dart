import 'package:flutter/material.dart';

import '../../../models/saju_models.dart';

const _elementDisplay = [
  ('wood', '목', '🌳', Color(0xFF34D399)),
  ('fire', '화', '🔥', Color(0xFFF87171)),
  ('earth', '토', '🏔️', Color(0xFFFCD34D)),
  ('metal', '금', '⚡', Color(0xFFE5E7EB)),
  ('water', '수', '💧', Color(0xFF38BDF8)),
];

const Map<String, String> _traitLabels = {
  'passion': '열정',
  'intuition': '직감',
  'mood_swing': '감정 기복',
  'courage': '용기',
  'responsibility': '책임감',
  'conflict': '갈등 에너지',
  'charisma': '카리스마',
  'independence': '독립성',
};

const Map<String, String> _characterLabels = {
  'wood': '목의 사람',
  'fire': '화의 사람',
  'earth': '토의 사람',
  'metal': '금의 사람',
  'water': '수의 사람',
  'unknown': '분류되지 않음',
};

const List<String> _stems = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
const List<String> _branches = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'];
const Map<String, int> _hourStartMap = {
  '갑': 1,
  '을': 1,
  '병': 3,
  '정': 3,
  '무': 5,
  '기': 5,
  '경': 7,
  '신': 7,
  '임': 9,
  '계': 9,
};

class SajuSummary {
  SajuSummary({
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.saju,
  });

  final String name;
  final String birthDate;
  final String gender;
  final Map<String, String> saju;
}

class SajuAnalysisView extends StatelessWidget {
  const SajuAnalysisView({
    super.key,
    required this.summary,
    required this.result,
    required this.onBack,
  });

  final SajuSummary summary;
  final SajuAnalysisResult result;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final saju = _normalizedSaju();
    final character = _characterLabels[result.character] ?? result.character;

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
                    _buildCharacterCard(character),
                            const SizedBox(height: 16),
                            _buildInfoCard(),
                            const SizedBox(height: 16),
                            _buildPillarsCard(saju),
                            const SizedBox(height: 16),
                            _buildElementsCard(),
                            const SizedBox(height: 16),
                            _buildTraitsCard(),
                            const SizedBox(height: 16),
                            _buildFlagsCard(),
                            const SizedBox(height: 16),
                            _buildReportCard(),
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
            color: Colors.black.withValues(alpha: 0.2),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleButton(
          icon: Icons.arrow_back,
          onTap: onBack,
        ),
        Expanded(
          child: Center(
            child: Text(
              '${summary.name.isEmpty ? '사용자' : summary.name}님의 사주 ✨',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 6,
                    color: Colors.black54,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 48), // 왼쪽 버튼과 대칭을 위한 공간
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildCharacterCard(String characterLabel) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대표 캐릭터 타입',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            characterLabel.isEmpty ? '분류되지 않음' : characterLabel,
            style: const TextStyle(
              color: Color(0xFFFDE047),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '오행 균형과 성향을 바탕으로 계산된 대표 성격 유형입니다.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('기본 정보 📋'),
          const SizedBox(height: 12),
          _infoRow('이름', summary.name.isEmpty ? '미입력' : summary.name),
          _infoRow('생년월일', summary.birthDate.isEmpty ? '미입력' : summary.birthDate),
          _infoRow('성별', summary.gender.isEmpty ? '미입력' : summary.gender),
        ],
      ),
    );
  }

  Widget _buildPillarsCard(Map<String, String> saju) {
    return _buildCard(
      child: Column(
        children: [
          _sectionTitle('사주팔자 🔮'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _PillarTile(
                label: '년주',
                gan: saju['year_gan'],
                ji: saju['year_ji'],
              ),
              _PillarTile(
                label: '월주',
                gan: saju['month_gan'],
                ji: saju['month_ji'],
              ),
              _PillarTile(
                label: '일주',
                gan: saju['day_gan'],
                ji: saju['day_ji'],
              ),
              _PillarTile(
                label: '시주',
                gan: saju['time_gan'],
                ji: saju['time_ji'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElementsCard() {
    final elements = _elementDisplay
        .map(
          (item) => _ElementInfo(
            label: item.$2,
            emoji: item.$3,
            color: item.$4,
            value: result.fiveElements[item.$1] ?? 0,
          ),
        )
        .toList();

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('오행 균형 🌿'),
          const SizedBox(height: 12),
          ...elements.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ElementTile(
                label: e.label,
                emoji: e.emoji,
                color: e.color,
                value: e.value,
              ),
            ),
          ),
          const Text(
            '값은 0~1 범위이며 높을수록 해당 기운이 강합니다.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: '성격 특성 🎭'),
          const SizedBox(height: 12),
          ...result.traits.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProgressTile(
                label: _traitLabels[entry.key] ?? entry.key,
                value: entry.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagsCard() {
    if (result.flags.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: '특이 기운 ⚡'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.flags
                .map(
                  (flag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      flag,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard() {
    final entries = result.traits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(3).map((entry) {
      final label = _traitLabels[entry.key] ?? entry.key;
      final percent = (entry.value * 100).round();
      return '$label $percent%';
    }).toList();
    final description = top.isEmpty
        ? '분석 정보를 찾을 수 없습니다.'
        : '${top.join(", ")} 특성이 두드러집니다.';

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: '분석 리포트 💡'),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, height: 1.6),
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
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Map<String, String> _normalizedSaju() {
    final map = Map<String, String>.from(summary.saju);
    final hasTime =
        (map['time_gan']?.isNotEmpty ?? false) && (map['time_ji']?.isNotEmpty ?? false);
    if (!hasTime) {
      map.addAll(_fallbackTime(map));
    }
    return map;
  }

  Map<String, String> _fallbackTime(Map<String, String> saju) {
    final dayGan = saju['day_gan'];
    final start = dayGan != null ? _hourStartMap[dayGan] : null;
    if (start == null) return {};
    const hourBranchIndex = 7; // 정오(오시)
    final branch = _branches[hourBranchIndex - 1];
    final stemIndex = ((start + (hourBranchIndex - 1) * 2) - 1) % 10;
    final stem = _stems[stemIndex];
    return {'time_gan': stem, 'time_ji': branch};
  }
}

class _PillarTile extends StatelessWidget {
  const _PillarTile({
    required this.label,
    this.gan,
    this.ji,
  });

  final String label;
  final String? gan;
  final String? ji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
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
          const SizedBox(height: 4),
          Text(
            gan ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ji ?? '-',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
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
    required this.value,
  });

  final String label;
  final String emoji;
  final Color color;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 40,
              child: Text(
                (value * 100).toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
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

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              (normalized * 100).toStringAsFixed(0),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: normalized,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFA5F3FC),
                    Color(0xFF6366F1),
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ElementInfo {
  _ElementInfo({
    required this.label,
    required this.emoji,
    required this.color,
    required this.value,
  });

  final String label;
  final String emoji;
  final Color color;
  final double value;
}

