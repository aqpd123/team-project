import 'dart:ui';

import 'package:flutter/material.dart';

class CompatibilityPerson {
  CompatibilityPerson({
    this.nameController,
    this.birthDate,
    this.gender,
  });

  final TextEditingController? nameController;
  final DateTime? birthDate;
  final String? gender;

  CompatibilityPerson copyWith({
    TextEditingController? nameController,
    DateTime? birthDate,
    String? gender,
  }) {
    return CompatibilityPerson(
      nameController: nameController ?? this.nameController,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
    );
  }
}

class SajuCompatibilityPage extends StatefulWidget {
  const SajuCompatibilityPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<SajuCompatibilityPage> createState() => _SajuCompatibilityPageState();
}

class _SajuCompatibilityPageState extends State<SajuCompatibilityPage> {
  late TextEditingController _nameCtrl1;
  late TextEditingController _nameCtrl2;
  DateTime? _birthDate1;
  DateTime? _birthDate2;
  String? _gender1;
  String? _gender2;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl1 = TextEditingController();
    _nameCtrl2 = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl1.dispose();
    _nameCtrl2.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate(int personIndex) async {
    final now = DateTime.now();
    final initial = (personIndex == 1 ? _birthDate1 : _birthDate2) ??
        DateTime(now.year - 20, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('ko'),
      helpText: '생년월일 선택',
    );
    if (selected == null) return;
    setState(() {
      if (personIndex == 1) {
        _birthDate1 = selected;
      } else {
        _birthDate2 = selected;
      }
    });
  }

  void _handleSubmit() {
    if (_nameCtrl1.text.trim().isEmpty ||
        _nameCtrl2.text.trim().isEmpty ||
        _birthDate1 == null ||
        _birthDate2 == null ||
        _gender1 == null ||
        _gender2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('두 사람의 정보를 모두 입력해주세요.')),
      );
      return;
    }
    setState(() {
      _showResult = true;
    });
  }

  void _handleResultBack() {
    setState(() {
      _showResult = false;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return CompatibilityResultView(
        person1Name: _nameCtrl1.text.trim(),
        person2Name: _nameCtrl2.text.trim(),
        onBack: _handleResultBack,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildIntroCard(),
                    const SizedBox(height: 24),
                    Form(
                      child: Column(
                        children: [
                          _buildPersonCard(
                            title: '첫 번째 사람',
                            accentColor: const Color(0xFFF472B6),
                            indexLabel: '1',
                            nameController: _nameCtrl1,
                            birthDate: _birthDate1,
                            onPickDate: () => _pickBirthDate(1),
                            gender: _gender1,
                            onGenderChanged: (value) {
                              setState(() => _gender1 = value);
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildPersonCard(
                            title: '두 번째 사람',
                            accentColor: const Color(0xFF8B5CF6),
                            indexLabel: '2',
                            nameController: _nameCtrl2,
                            birthDate: _birthDate2,
                            onPickDate: () => _pickBirthDate(2),
                            gender: _gender2,
                            onGenderChanged: (value) {
                              setState(() => _gender2 = value);
                            },
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: const Color(0xFFF472B6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 10,
                              ),
                              child: const Text(
                                '궁합 분석하기 💕',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleButton(icon: Icons.arrow_back, onTap: widget.onBack),
        const Text(
          '사주궁합보기 💕',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Text(
        '두 분의 생년월일을 입력하시면 연애, 우정, 사업 궁합을 알려드려요',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildPersonCard({
    required String title,
    required String indexLabel,
    required Color accentColor,
    required TextEditingController nameController,
    required DateTime? birthDate,
    required VoidCallback onPickDate,
    required String? gender,
    required ValueChanged<String> onGenderChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    indexLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel('이름'),
          _buildInputContainer(
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('이름을 입력해주세요'),
            ),
          ),
          const SizedBox(height: 16),
          _buildLabel('생년월일'),
          _buildInputContainer(
            child: GestureDetector(
              onTap: onPickDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    birthDate == null ? '생년월일을 선택하세요' : _formatDate(birthDate),
                    style: TextStyle(
                      color: birthDate == null ? Colors.white54 : Colors.white,
                    ),
                  ),
                  Icon(Icons.calendar_today, color: accentColor, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLabel('성별'),
          Row(
            children: [
              Expanded(
                child: _genderButton(
                  label: '남성',
                  isSelected: gender == '남성',
                  accentColor: accentColor,
                  onTap: () => onGenderChanged('남성'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _genderButton(
                  label: '여성',
                  isSelected: gender == '여성',
                  accentColor: accentColor,
                  onTap: () => onGenderChanged('여성'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration.collapsed(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
    );
  }

  Widget _genderButton({
    required String label,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, VoidCallback? onTap}) {
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

class CompatibilityResultView extends StatelessWidget {
  const CompatibilityResultView({
    super.key,
    required this.person1Name,
    required this.person2Name,
    required this.onBack,
  });

  final String person1Name;
  final String person2Name;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildScoreCard(),
                            const SizedBox(height: 16),
                            _buildAnalysisCard(
                              title: '💖 연애 궁합',
                              description:
                                  '두 분은 서로의 감정을 잘 이해하고 공감하는 능력이 뛰어납니다. '
                                  '서로 다른 성격이지만 그것이 오히려 매력으로 작용하여 좋은 관계를 유지할 수 있어요.',
                            ),
                            const SizedBox(height: 12),
                            _buildAnalysisCard(
                              title: '🤝 우정 궁합',
                              description:
                                  '평생 친구로 지낼 수 있는 좋은 궁합입니다. 서로를 믿고 의지하며, '
                                  '어려운 일이 있을 때 힘이 되어줄 수 있는 관계예요.',
                            ),
                            const SizedBox(height: 12),
                            _buildAnalysisCard(
                              title: '💼 사업 궁합',
                              description:
                                  '서로의 장점을 살려 시너지를 낼 수 있는 관계입니다. '
                                  '한 분은 아이디어를, 다른 분은 실행력을 담당하면 좋은 결과를 얻을 수 있어요.',
                            ),
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

  Widget _background() {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const Text(
          '궁합 결과 💕',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildScoreCard() {
    final name1 = person1Name.isEmpty ? 'A' : person1Name;
    final name2 = person2Name.isEmpty ? 'B' : person2Name;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF472B6),
                  Color(0xFF8B5CF6),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '85',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '매우 좋은 궁합!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$name1님과 $name2님은 서로를 잘 이해하고 보완하는 관계입니다.',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard({required String title, required String description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF472B6),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '✨ 관계 발전을 위한 조언',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '서로의 차이점을 인정하고 존중하는 것이 중요합니다. '
            '소통을 자주 하고 서로의 의견을 경청하는 자세를 유지하세요.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

