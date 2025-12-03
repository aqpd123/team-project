import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../models/saju_models.dart';
import '../../services/api_client.dart';
import 'components/saju_analysis.dart';

/// 나의 사주 페이지 - 저장된 사주 분석 결과를 표시
class MySajuPage extends StatefulWidget {
  const MySajuPage({
    super.key,
    this.onBack,
    this.onNavigateToSaju,
    this.initialResult,
    this.initialUserInfo,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNavigateToSaju;
  final SajuAnalysisResult? initialResult;
  final Map<String, String>? initialUserInfo;

  @override
  State<MySajuPage> createState() => _MySajuPageState();
}

class _MySajuPageState extends State<MySajuPage> {
  bool _isLoading = true;
  SajuAnalysisResult? _result;
  Map<String, String>? _userInfo;
  String? _error;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    // 초기 결과가 있으면 바로 표시, 없으면 데이터베이스에서 로드
    if (widget.initialResult != null && widget.initialUserInfo != null) {
      _result = widget.initialResult;
      _userInfo = widget.initialUserInfo;
      _isLoading = false;
      _isInitialLoad = false;
    } else {
      _loadMySaju();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 첫 로드가 완료된 후에만 새로고침 (무한 루프 방지)
    if (_isInitialLoad) {
      _isInitialLoad = false;
      return;
    }
    
    // 페이지가 다시 표시될 때만 데이터 새로고침
    if (mounted && !_isLoading) {
      // 약간의 지연을 두어 데이터베이스 저장이 완료된 후 로드
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isLoading) {
          _loadMySaju();
        }
      });
    }
  }

  Future<void> _loadMySaju() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 현재 로그인한 사용자 확인
      final auth = AuthScope.of(context);
      final currentUserId = auth.user?.id ?? 0;
      
      if (currentUserId == 0) {
        setState(() {
          _isLoading = false;
          _error = '로그인이 필요합니다';
        });
        return;
      }

      // 데이터베이스에서 사용자 정보 가져오기
      final api = ApiClient();
      api.updateToken(auth.user != null ? await _getToken() : null);
      
      final userResponse = await api.get('/users/$currentUserId');
      
      // 디버깅: 응답 데이터 확인
      print('🔍 사용자 응답 전체: $userResponse');
      print('🔍 사용자 응답 키 목록: ${userResponse.keys.toList()}');
      
      // 사주 분석 결과 확인
      final sajuAnalysis = userResponse['saju_analysis'] as Map<String, dynamic>?;
      final birthDateRaw = userResponse['birth_date'];
      final birthDate = birthDateRaw?.toString();
      final gender = userResponse['gender'] as int?;
      
      print('🔍 saju_analysis 타입: ${sajuAnalysis.runtimeType}');
      print('🔍 saju_analysis 값: $sajuAnalysis');
      print('🔍 saju_analysis가 null인가: ${sajuAnalysis == null}');
      print('🔍 saju_analysis가 비어있는가: ${sajuAnalysis?.isEmpty ?? true}');
      if (sajuAnalysis != null) {
        print('🔍 saju_analysis 키 목록: ${sajuAnalysis.keys.toList()}');
      }
      print('🔍 birth_date (raw): $birthDateRaw');
      print('🔍 birth_date (string): $birthDate');
      print('🔍 gender: $gender');
      
      if (sajuAnalysis == null || sajuAnalysis.isEmpty) {
        print('⚠️ 사주 분석 결과가 없습니다');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = null; // 빈 상태로 표시
          });
        }
        return;
      }

      // 사주 분석 결과를 SajuAnalysisResult로 변환
      try {
        print('🔍 사주 분석 결과 파싱 시도: $sajuAnalysis');
        final result = SajuAnalysisResult.fromJson(sajuAnalysis);
        print('✅ 사주 분석 결과 파싱 성공');
      
        // 사용자 정보 구성
        final userInfo = <String, String>{
          'name': userResponse['username']?.toString() ?? '사용자',
          'birthDate': birthDate ?? '',
          'gender': gender == 1 ? '남성' : (gender == 0 ? '여성' : ''),
          'userId': currentUserId.toString(),
        };

        if (mounted) {
          setState(() {
            _result = result;
            _userInfo = userInfo;
            _isLoading = false;
          });
        }
      } catch (parseError) {
        print('❌ 사주 분석 결과 파싱 실패: $parseError');
        print('❌ 원본 데이터: $sajuAnalysis');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = '저장된 사주 데이터 형식이 올바르지 않습니다.\n새로 사주 분석을 진행해주세요.';
          });
        }
        return;
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e.statusCode == 404) {
            _error = '저장된 사주가 없습니다.\n사주보기를 통해 나의 운명을 확인해보세요.';
          } else {
            _error = '사주 정보를 불러오는 중 오류가 발생했습니다.\n${e.message}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '저장된 사주가 없습니다.\n사주보기를 통해 나의 운명을 확인해보세요.';
        });
      }
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            Positioned.fill(
              child: SafeArea(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 저장된 사주가 있는 경우 분석 결과 표시
    if (_result != null && _userInfo != null) {
      return SajuAnalysisView(
        summary: SajuSummary(
          name: _userInfo!['name'] ?? '사용자',
          birthDate: _userInfo!['birthDate'] ?? '',
          gender: _userInfo!['gender'] ?? '',
          saju: _result!.saju,
        ),
        result: _result!,
        onBack: widget.onBack ?? () {},
      );
    }

    // 저장된 사주가 없는 경우 빈 상태 표시
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
                    const SizedBox(height: 32),
                    _buildEmptyState(),
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
            color: Colors.black.withValues(alpha: 0.2),
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
          '나의 사주 ⭐',
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

  Widget _buildEmptyState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
            ),
            child: const Icon(
              Icons.star_outline,
              size: 56,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _error ?? '저장된 사주가 없어요',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '사주보기를 통해\n나의 운명을 확인해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onNavigateToSaju,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              backgroundColor: const Color(0xFFFACC15),
              foregroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
            ),
            child: const Text(
              '사주보러 가기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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

