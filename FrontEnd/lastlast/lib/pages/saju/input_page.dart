import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/saju_controller.dart';
import '../../models/saju_models.dart';
import '../../services/api_client.dart';
import 'components/saju_analysis.dart';

/// React `pages/saju-input/page.tsx`를 Flutter로 옮긴 화면.
/// 이름/생년월일/성별 입력 후 분석 카드를 보여주며,
/// 분석 화면에서 뒤로 가면 다시 폼으로 복귀한다.
class SajuInputPage extends StatefulWidget {
  const SajuInputPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<SajuInputPage> createState() => _SajuInputPageState();
}

class _SajuInputPageState extends State<SajuInputPage> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _birthDate;
  String? _gender; // '남성' or '여성'

  bool _showAnalysis = false;
  bool _submitting = false;
  SajuAnalysisResult? _result;
  Map<String, String>? _selectedSaju;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? DateTime(now.year - 20, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: '생년월일 선택',
      locale: const Locale('ko'),
    );
    if (selected != null) {
      setState(() {
        _birthDate = selected;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_nameCtrl.text.trim().isEmpty || _birthDate == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름, 생년월일, 성별을 모두 입력해주세요.')),
      );
      return;
    }

    final controller = SajuScope.of(context);
    final request = SajuBirthTraitsRequest(
      year: _birthDate!.year,
      month: _birthDate!.month,
      day: _birthDate!.day,
      gender: _gender == '남성' ? 1 : 0,
    );

    setState(() {
      _submitting = true;
    });

    try {
      final result = await controller.analyzeTraits(request);
      if (!mounted) return;
      
      // 사주 분석 결과를 SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_saju_analysis', jsonEncode(result.saju));
      
      setState(() {
        _result = result;
        _selectedSaju = result.saju;
        _showAnalysis = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _handleBackFromAnalysis() {
    setState(() {
      _showAnalysis = false;
    });
  }

  String _formattedBirthDate() {
    if (_birthDate == null) return '';
    return '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_showAnalysis && _result != null && _selectedSaju != null) {
      return SajuAnalysisView(
        summary: SajuSummary(
          name: _nameCtrl.text.trim(),
          birthDate: _formattedBirthDate(),
          gender: _gender ?? '',
          saju: _selectedSaju!,
        ),
        result: _result!,
        onBack: _handleBackFromAnalysis,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildIntroCard(),
                      const SizedBox(height: 24),
                      _buildForm(),
                    ],
                  ),
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
        _CircleButton(
          icon: Icons.arrow_back,
          onTap: widget.onBack,
        ),
        Expanded(
          child: Center(
            child: const Text(
              '사주보기 🌟',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '나의 사주 분석',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '생년월일을 입력하시면 당신의 운명과 성격, 미래를 알려드려요',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('이름'),
        _buildInputContainer(
          child: TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('이름을 입력해주세요'),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel('생년월일'),
        _buildInputContainer(
          child: GestureDetector(
            onTap: _pickBirthDate,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _birthDate == null ? '생년월일을 선택하세요' : _formattedBirthDate(),
                  style: TextStyle(
                    color: _birthDate == null ? Colors.white54 : Colors.white,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel('성별'),
        Row(
          children: [
            Expanded(
              child: _genderButton(label: '남성'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _genderButton(label: '여성'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFFACC15),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 10,
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black87,
                    ),
                  )
                : const Text(
                    '사주 분석하기 ✨',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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

  Widget _genderButton({required String label}) {
    final isSelected = _gender == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFACC15) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFACC15) : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0F172A) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
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

