import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/celebrity_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_client.dart';
import 'celebrity_page.dart';

/// 유명인 선택 이후 상세 궁합을 보여주는 화면.
class CelebrityResultPage extends StatefulWidget {
  const CelebrityResultPage({
    super.key,
    required this.celebrity,
    this.onBack,
    this.onStartCompatibility,
  });

  final CelebrityData celebrity;
  final VoidCallback? onBack;
  final VoidCallback? onStartCompatibility;

  @override
  State<CelebrityResultPage> createState() => _CelebrityResultPageState();
}

class _CelebrityResultPageState extends State<CelebrityResultPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _compatibilityResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    // initState 완료 후 context를 사용할 수 있도록 postFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCompatibility();
      }
    });
  }

  Future<void> _loadCompatibility() async {
    if (!mounted) return;
    
    try {
      final auth = AuthScope.of(context);
      final celebrityController = CelebrityScope.of(context);
      
      // 사용자 사주 데이터 가져오기 - SharedPreferences에서 마지막 사주 분석 결과 가져오기
      Map<String, String>? userSaju;
      int userGender = 0;
      
      // SharedPreferences에서 마지막 사주 분석 결과 가져오기
      final prefs = await SharedPreferences.getInstance();
      final lastSajuJson = prefs.getString('last_saju_analysis');
      
      if (lastSajuJson != null) {
        try {
          final sajuData = jsonDecode(lastSajuJson) as Map<String, dynamic>;
          userSaju = sajuData.map((key, value) => MapEntry(key, value.toString()));
        } catch (e) {
          // JSON 파싱 실패 시 무시
        }
      }
      
      // AuthUser에서도 시도
      if ((userSaju == null || userSaju.isEmpty) && auth.user?.saju != null) {
        final sajuData = auth.user!.saju!;
        userSaju = sajuData.map((key, value) => MapEntry(key, value.toString()));
      }
      
      // 사용자 사주 데이터가 없으면 에러 표시
      if (userSaju == null || userSaju.isEmpty) {
        if (mounted) {
          setState(() {
            _error = '사주 분석을 먼저 진행해주세요.\n사주 분석 페이지로 이동하시겠습니까?';
            _isLoading = false;
          });
        }
        return;
      }

      final result = await celebrityController.calculateCompatibility(
        int.parse(widget.celebrity.id),
        userSaju,
        userGender,
      );
      if (mounted) {
        setState(() {
          _compatibilityResult = result;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '궁합 계산 중 오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildProfileCard(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildCompatibilityScore(),
                            const SizedBox(height: 16),
                            _buildInsightCard(
                              title: '연애 궁합',
                              emoji: '💕',
                              description:
                                  '${widget.celebrity.name}님과는 서로의 감정을 섬세하게 공감할 수 있어요. 감성적인 면이 잘 맞아 부드러운 관계가 기대됩니다.',
                            ),
                            const SizedBox(height: 12),
                            _buildInsightCard(
                              title: '우정 궁합',
                              emoji: '🤝',
                              description:
                                  '같은 목표를 향해 나아갈 때 협력 관계가 빛을 발합니다. 진솔한 대화를 자주 나누면 서로에게 든든한 친구가 되어줄 수 있어요.',
                            ),
                            const SizedBox(height: 12),
                            _buildInsightCard(
                              title: '사업 궁합',
                              emoji: '💼',
                              description:
                                  '서로 다른 장점을 적절히 분담하면 시너지가 큽니다. ${widget.celebrity.profession} 특유의 창의력이 큰 영감을 줄 수 있어요.',
                            ),
                            const SizedBox(height: 16),
                            _buildAdviceCard(),
                            const SizedBox(height: 24),
                            _buildActionButton(),
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
        _circleButton(icon: Icons.arrow_back, onTap: widget.onBack),
        Expanded(
          child: Center(
            child: const Text(
              '궁합 결과 ⭐',
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

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage(widget.celebrity.imageUrl),
            backgroundColor: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.celebrity.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.celebrity.profession,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.celebrity.birthDate,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              widget.celebrity.element,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityScore() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_error != null) {
      final isSajuRequired = _error!.contains('사주 분석을 먼저 진행해주세요');
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isSajuRequired)
              ElevatedButton(
                onPressed: () {
                  context.go('/saju/input');
                },
                child: const Text('사주 분석하러 가기'),
              )
            else
              ElevatedButton(
                onPressed: _loadCompatibility,
                child: const Text('다시 시도'),
              ),
          ],
        ),
      );
    }

    final scores = _compatibilityResult?['scores'] as Map<String, dynamic>?;
    final finalScore = (scores?['final'] as num?)?.toDouble() ?? 0.0;
    final description = _compatibilityResult?['description'] as String? ?? 
        '${widget.celebrity.name}님과의 궁합이에요!';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF472B6), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                finalScore.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String emoji,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji $title',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, height: 1.6),
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
          colors: [Color(0xFFF472B6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '✨ 더욱 가까워지는 팁',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '공통 관심사를 함께 즐기고 솔직한 대화를 자주 나눠보세요. '
            '자연스럽게 신뢰를 쌓을 수 있어요.',
            style: TextStyle(color: Colors.white, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onStartCompatibility,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2E1065),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          '다른 유명인도 보기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

