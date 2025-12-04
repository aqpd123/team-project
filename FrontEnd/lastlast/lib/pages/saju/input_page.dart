import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/saju_controller.dart';
import '../../models/friend_models.dart';
import '../../models/saju_models.dart';
import '../../shared/widgets/mystic_background.dart';
import '../../services/api_client.dart';

/// 사주 입력 페이지
///
/// - 경로: `/saju/input`
/// - 생년월일 + 성별을 입력 받아 개인 사주 분석을 실행한다.
/// - 친구 데이터가 있으면 궁합 계산을 실행한다.
/// - 분석이 성공하면
///   1) 백엔드에 사주 정보가 저장되고
///   2) 로컬(SharedPreferences)에 마지막 사주 분석 결과가 저장되며
///   3) 친구 데이터가 있으면 궁합 결과 페이지로, 없으면 `/my-saju` 화면으로 이동
class SajuInputPage extends StatefulWidget {
  const SajuInputPage({
    super.key,
    required this.onBack,
    this.friendData,
  });

  final VoidCallback onBack;
  final FriendData? friendData;

  @override
  State<SajuInputPage> createState() => _SajuInputPageState();
}

class _SajuInputPageState extends State<SajuInputPage> {
  DateTime? _birthDate;
  int _gender = 1; // 1 = 남성, 0 = 여성
  bool _isSubmitting = false;
  final ApiClient _api = ApiClient();

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 20, now.month, now.day);
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
      _birthDate = selected;
    });
  }

  Future<void> _submit() async {
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일을 선택해 주세요.')),
      );
      return;
    }

    final auth = AuthScope.of(context);
    final sajuController = SajuScope.of(context);
    final userId = auth.user?.id ?? 0;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 친구 데이터가 있으면 궁합 계산, 없으면 개인 사주 분석
      if (widget.friendData != null) {
        // 친구의 사주 데이터 가져오기
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          _api.updateToken(token);
        }

        final friendUserData =
            await _api.get('/users/${widget.friendData!.userId}');

        if (!mounted) return;

        // 친구의 생년월일과 성별 확인
        if (friendUserData['birth_date'] == null ||
            friendUserData['gender'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('친구의 사주 정보가 없습니다. 친구가 먼저 사주 분석을 완료해야 합니다.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final friendBirthDateStr = friendUserData['birth_date'] as String;
        final friendBirthParts = friendBirthDateStr.split('-');
        if (friendBirthParts.length != 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('친구의 생년월일 정보가 올바르지 않습니다.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final friendGender = friendUserData['gender'] as int;

        // 자신의 사주 분석 실행 (백엔드에 저장하기 위해)
        final myRequest = SajuBirthTraitsRequest(
          year: _birthDate!.year,
          month: _birthDate!.month,
          day: _birthDate!.day,
          gender: _gender,
        );
        await sajuController.analyzeTraits(myRequest);

        // 궁합 계산
        final compatibilityRequest = SajuBirthCompatibilityRequest(
          person1: SajuBirthInfo(
            year: _birthDate!.year,
            month: _birthDate!.month,
            day: _birthDate!.day,
          ),
          person2: SajuBirthInfo(
            year: int.parse(friendBirthParts[0]),
            month: int.parse(friendBirthParts[1]),
            day: int.parse(friendBirthParts[2]),
          ),
          gender1: _gender,
          gender2: friendGender,
          person1Name: auth.user?.name,
          person2Name: widget.friendData!.name,
        );

        final compatibilityResult =
            await sajuController.calculateCompatibility(compatibilityRequest);

        // 데이터베이스 저장이 완료될 때까지 대기
        await Future.delayed(const Duration(milliseconds: 1000));
        await auth.refreshUser();

        if (!mounted) return;

        // 궁합 결과 페이지로 이동
        context.go('/saju/compatibility', extra: {
          'friend': widget.friendData,
          'result': compatibilityResult,
          'person1Name': auth.user?.name ?? '나',
          'person2Name': widget.friendData!.name,
        });
      } else {
        // 일반 사주 분석
        final request = SajuBirthTraitsRequest(
          year: _birthDate!.year,
          month: _birthDate!.month,
          day: _birthDate!.day,
          gender: _gender,
        );

        final result = await sajuController.analyzeTraits(request);

        // 유명인 궁합 페이지에서 사용할 수 있도록 마지막 사주 분석 결과를 저장
        if (userId > 0) {
          final prefs = await SharedPreferences.getInstance();
          // 사주 팔자만 저장 (gan/ji 맵)
          final sajuMap = result.saju;
          await prefs.setString(
            'last_saju_analysis_$userId',
            jsonEncode(sajuMap),
          );
        }

        if (!mounted) return;

        // 사용자 정보 구성
        final userInfo = <String, String>{
          'name': auth.user?.name ?? '사용자',
          'birthDate':
              '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
          'gender': _gender == 1 ? '남성' : '여성',
          'userId': userId.toString(),
        };

        // 데이터베이스 저장이 완료될 때까지 충분히 대기
        await Future.delayed(const Duration(milliseconds: 1000));

        // 사용자 정보 새로고침 (character_type 업데이트 반영)
        await auth.refreshUser();

        // 분석 결과를 바로 표시하기 위해 extra로 전달
        if (!mounted) return;
        context.go('/my-saju', extra: {
          'result': result,
          'userInfo': userInfo,
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '생년월일을 선택하세요';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildIntroCard(),
                const SizedBox(height: 24),
                _buildForm(),
                const Spacer(),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        Text(
          widget.friendData != null ? '궁합 보기 💕' : '사주 입력 🔮',
          style: const TextStyle(
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        widget.friendData != null
            ? '${widget.friendData!.name}님과의 궁합을 확인해보세요.\n자신의 생년월일만 입력하면 됩니다.'
            : '정확한 생년월일과 성별을 입력하면\n나의 오행과 성격, 사주 분석을 볼 수 있어요.',
        style:
            const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '생년월일',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickBirthDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(_birthDate),
                  style: TextStyle(
                    color: _birthDate == null ? Colors.white54 : Colors.white,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.amber, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '성별',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _genderButton(
                label: '남성',
                isSelected: _gender == 1,
                onTap: () {
                  setState(() {
                    _gender = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _genderButton(
                label: '여성',
                isSelected: _gender == 0,
                onTap: () {
                  setState(() {
                    _gender = 0;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _genderButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFACC15)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFACC15)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0F172A) : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFFFACC15),
          foregroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                widget.friendData != null ? '궁합 분석하기' : '사주 분석하기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
