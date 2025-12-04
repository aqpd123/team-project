import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart' show AuthScope;
import '../../controllers/saju_controller.dart';
import '../../models/friend_models.dart';
import '../../models/saju_models.dart';
import '../../services/api_client.dart';

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
  const SajuCompatibilityPage({
    super.key,
    this.onBack,
    this.friendData,
    this.initialResult,
    this.person1Name,
    this.person2Name,
  });

  final VoidCallback? onBack;
  final FriendData? friendData;
  final SajuCompatibilityResult? initialResult;
  final String? person1Name;
  final String? person2Name;

  @override
  State<SajuCompatibilityPage> createState() => _SajuCompatibilityPageState();
}

class _SajuCompatibilityPageState extends State<SajuCompatibilityPage> {
  late TextEditingController _nameCtrl1;
  late TextEditingController _nameCtrl2;
  final _nameFocusNode1 = FocusNode();
  final _nameFocusNode2 = FocusNode();
  final _personCardKey1 = GlobalKey();
  final _personCardKey2 = GlobalKey();
  final _scrollController = ScrollController();
  DateTime? _birthDate1;
  DateTime? _birthDate2;
  String? _gender1;
  String? _gender2;
  bool _showResult = false;
  bool _initialized = false;
  bool _isSubmitting = false;
  bool _loadingFriendData = false;
  SajuCompatibilityResult? _result;
  final ApiClient _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _nameCtrl1 = TextEditingController();
    _nameCtrl2 = TextEditingController();
    
    // 입력 필드 포커스 변경 시 스크롤
    _nameFocusNode1.addListener(() => _onNameFocusChanged(1));
    _nameFocusNode2.addListener(() => _onNameFocusChanged(2));

    // 초기 결과가 있으면 바로 결과 화면 표시
    if (widget.initialResult != null) {
      _result = widget.initialResult;
      _nameCtrl1.text = widget.person1Name ?? '나';
      _nameCtrl2.text = widget.person2Name ?? '친구';
      _showResult = true;
    }
  }
  
  void _onNameFocusChanged(int personIndex) {
    final focusNode = personIndex == 1 ? _nameFocusNode1 : _nameFocusNode2;
    final cardKey = personIndex == 1 ? _personCardKey1 : _personCardKey2;
    
    if (focusNode.hasFocus) {
      // 키보드가 올라온 후 스크롤 (게시판 댓글 작성과 동일한 방식)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !focusNode.hasFocus) return;
        
        final context = cardKey.currentContext;
        if (context == null) return;
        
        // 이름 입력 필드가 완전히 보이도록 스크롤
        // 두 번째 사람은 더 위로 스크롤 (이름 UI 앞까지)
        final alignment = personIndex == 2 ? 0.25 : 0.15;
        
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: alignment, // 이름 UI가 화면 상단 15-25% 위치에 오도록
        );
        
        // 키보드 애니메이션이 완료된 후 한 번 더 확인
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted || !focusNode.hasFocus) return;
          
          final context2 = cardKey.currentContext;
          if (context2 == null) return;
          
          Scrollable.ensureVisible(
            context2,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: alignment,
          );
        });
      });
    }
  }

  Future<void> _initializeWithFriendData() async {
    if (_initialized || widget.friendData == null || !mounted) return;
    _initialized = true;

    // 사용자 이름/친구 이름 초기 세팅
    final auth = AuthScope.of(context);
    _nameCtrl1.text = auth.user?.name ?? '나';
    _nameCtrl2.text = widget.friendData!.name;

    // API 클라이언트에 토큰 설정
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _api.updateToken(token);
    }

    // 친구의 사주 데이터 가져오기
    setState(() {
      _loadingFriendData = true;
    });

    try {
      final friendUserData =
          await _api.get('/users/${widget.friendData!.userId}');

      if (!mounted) return;

      // 친구의 생년월일과 성별 정보 가져오기
      DateTime? loadedBirthDate;
      String? loadedGender;

      // 디버깅: 받은 데이터 확인
      print('🔍 친구 데이터 로드: ${friendUserData.keys}');
      print('🔍 birth_date: ${friendUserData['birth_date']}');
      print(
          '🔍 gender: ${friendUserData['gender']} (타입: ${friendUserData['gender']?.runtimeType})');

      if (friendUserData['birth_date'] != null) {
        final birthDateStr = friendUserData['birth_date'] as String;
        final parts = birthDateStr.split('-');
        if (parts.length == 3) {
          loadedBirthDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          print('✅ 생년월일 파싱 성공: $loadedBirthDate');
        }
      }

      if (friendUserData['gender'] != null) {
        final gender = friendUserData['gender'];
        // gender가 int인지 확인
        if (gender is int) {
          loadedGender = gender == 1 ? '남성' : '여성';
          print('✅ 성별 파싱 성공 (int): $gender -> $loadedGender');
        } else if (gender is String) {
          // 문자열로 온 경우도 처리
          loadedGender =
              gender == '1' || gender.toLowerCase() == 'male' ? '남성' : '여성';
          print('✅ 성별 파싱 성공 (String): $gender -> $loadedGender');
        } else {
          print('⚠️ 성별 타입 인식 실패: ${gender.runtimeType}');
        }
      } else {
        print('⚠️ 친구의 성별 정보가 없습니다.');
      }

      // setState 내에서 상태 업데이트
      if (mounted) {
        setState(() {
          if (loadedBirthDate != null) {
            _birthDate2 = loadedBirthDate;
          }
          if (loadedGender != null) {
            _gender2 = loadedGender;
            print('✅ 성별 상태 업데이트: $_gender2');
          }
          _loadingFriendData = false;
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingFriendData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('친구 정보를 불러오는 중 오류가 발생했습니다: ${e.message}'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingFriendData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('친구 정보를 불러오는 중 오류가 발생했습니다.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl1.dispose();
    _nameCtrl2.dispose();
    _nameFocusNode1.dispose();
    _nameFocusNode2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate(int personIndex) async {
    // ��¥ ���� �� Ű���尡 �ٽ� �ö���� �ʵ��� ��Ŀ�� ����
    FocusScope.of(context).unfocus();
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

  Future<void> _handleSubmit() async {
    // 친구 데이터가 있는 경우, 자신의 정보만 확인
    if (widget.friendData != null) {
      if (_nameCtrl1.text.trim().isEmpty ||
          _birthDate1 == null ||
          _gender1 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('자신의 정보를 모두 입력해 주세요.'),
          ),
        );
        return;
      }
      // 친구 정보가 없으면 에러
      if (_birthDate2 == null || _gender2 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('친구 정보를 불러오는 중입니다. 잠시만 기다려주세요.'),
          ),
        );
        return;
      }
    } else {
      // 일반 궁합보기: 두 사람의 정보 모두 확인
      if (_nameCtrl1.text.trim().isEmpty ||
          _nameCtrl2.text.trim().isEmpty ||
          _birthDate1 == null ||
          _birthDate2 == null ||
          _gender1 == null ||
          _gender2 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('두 사람의 정보를 모두 입력해 주세요.'),
          ),
        );
        return;
      }
    }
    final controller = SajuScope.of(context);
    final request = SajuBirthCompatibilityRequest(
      person1: SajuBirthInfo(
        year: _birthDate1!.year,
        month: _birthDate1!.month,
        day: _birthDate1!.day,
      ),
      person2: SajuBirthInfo(
        year: _birthDate2!.year,
        month: _birthDate2!.month,
        day: _birthDate2!.day,
      ),
      // 남성 = 1, 여성 = 0 으로 전송
      gender1: _gender1 == '남성' ? 1 : 0,
      gender2: _gender2 == '남성' ? 1 : 0,
    );
    setState(() {
      _isSubmitting = true;
    });
    try {
      final result = await controller.calculateCompatibility(request);
      if (!mounted) return;
      setState(() {
        _result = result;
        _showResult = true;
      });
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

  void _handleResultBack() {
    setState(() {
      _showResult = false;
      _result = null;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // extra에서 결과를 받은 경우 (사주 입력 페이지에서 온 경우)
    final extra =
        (context as Element).findAncestorStateOfType<NavigatorState>()?.context;
    if (extra != null) {
      final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments is Map) {
        final args = route.settings.arguments as Map;
        if (args['result'] is SajuCompatibilityResult && !_showResult) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _result = args['result'] as SajuCompatibilityResult;
                _nameCtrl1.text = args['person1Name'] as String? ?? '나';
                _nameCtrl2.text = args['person2Name'] as String? ?? '친구';
                _showResult = true;
              });
            }
          });
        }
      }
    }

    // 친구 정보가 전달된 경우 초기화(한 번만 실행)
    if (widget.friendData != null && !_initialized && mounted && !_showResult) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeWithFriendData();
        }
      });
    }

    if (_showResult && _result != null) {
      return CompatibilityResultView(
        person1Name: _nameCtrl1.text.trim(),
        person2Name: _nameCtrl2.text.trim(),
        result: _result!,
        onBack: _handleResultBack,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라와도 배경이 움직이지 않도록
      body: Stack(
        children: [
          _buildBackground(),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
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
                            key: _personCardKey1,
                            title: widget.friendData != null ? '나' : '첫 번째 사람',
                            accentColor: const Color(0xFFF472B6),
                            indexLabel: '1',
                            nameController: _nameCtrl1,
                            nameFocusNode: _nameFocusNode1,
                            birthDate: _birthDate1,
                            onPickDate: () => _pickBirthDate(1),
                            gender: _gender1,
                            onGenderChanged: (value) {
                              setState(() => _gender1 = value);
                            },
                            enabled: true,
                          ),
                          const SizedBox(height: 20),
                          _buildPersonCard(
                            key: _personCardKey2,
                            title: widget.friendData != null
                                ? widget.friendData!.name
                                : '두 번째 사람',
                            accentColor: const Color(0xFF8B5CF6),
                            indexLabel: '2',
                            nameController: _nameCtrl2,
                            nameFocusNode: _nameFocusNode2,
                            birthDate: _birthDate2,
                            onPickDate: () => _pickBirthDate(2),
                            gender: _gender2,
                            onGenderChanged: (value) {
                              setState(() => _gender2 = value);
                            },
                            enabled: widget.friendData == null,
                            isLoading:
                                widget.friendData != null && _loadingFriendData,
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: const Color(0xFFF472B6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 10,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      '궁합 분석하기 시작',
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
            color: Colors.black.withValues(alpha: 0.2),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) {
              // 네트워크 이미지 실패 시에는 에러 위젯을 숨긴다.
              return const SizedBox.shrink();
            },
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
              '사주 궁합 보기 🔮',
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
      child: Text(
        widget.friendData != null
            ? '${widget.friendData!.name}님과의 궁합을 확인해보세요. 자신의 생년월일만 입력하면 됩니다.'
            : '두 분의 생년월일을 입력하시면 연애, 우정, 사업 궁합을 알려드려요',
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildPersonCard({
    Key? key,
    required String title,
    required String indexLabel,
    required Color accentColor,
    required TextEditingController nameController,
    FocusNode? nameFocusNode,
    required DateTime? birthDate,
    required VoidCallback onPickDate,
    required String? gender,
    required ValueChanged<String> onGenderChanged,
    bool enabled = true,
    bool isLoading = false,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
              focusNode: nameFocusNode,
              enabled: enabled,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white54,
              ),
              decoration: _inputDecoration('이름을 입력해주세요'),
            ),
          ),
          const SizedBox(height: 16),
          _buildLabel('생년월일'),
          _buildInputContainer(
            child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '친구 정보를 불러오는 중...',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: enabled ? onPickDate : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          birthDate == null
                              ? '생년월일을 선택하세요'
                              : _formatDate(birthDate),
                          style: TextStyle(
                            color: birthDate == null
                                ? Colors.white54
                                : (enabled ? Colors.white : Colors.white70),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: enabled ? accentColor : Colors.white54,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _buildLabel('성별'),
          Builder(
            builder: (context) {
              // 디버깅: gender 값 확인
              if (widget.friendData != null && indexLabel == '2') {
                print('🔍 _buildPersonCard - 두 번째 사람 gender: $gender');
              }
              return Row(
                children: [
                  Expanded(
                    child: _genderButton(
                      label: '남성',
                      isSelected: gender == '남성',
                      accentColor: accentColor,
                      enabled: enabled,
                      onTap: enabled ? () => onGenderChanged('남성') : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _genderButton(
                      label: '여성',
                      isSelected: gender == '여성',
                      accentColor: accentColor,
                      enabled: enabled,
                      onTap: enabled ? () => onGenderChanged('여성') : null,
                    ),
                  ),
                ],
              );
            },
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

  Widget _genderButton({
    required String label,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    // enabled가 false여도 isSelected가 true이면 선택된 것처럼 표시
    final effectiveSelected = isSelected;
    final effectiveEnabled = enabled;

    return GestureDetector(
      onTap: effectiveEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: effectiveSelected
              ? (effectiveEnabled
                  ? accentColor
                  : accentColor.withValues(alpha: 0.6)) // 비활성화되어도 선택된 색상 표시
              : (effectiveEnabled
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: effectiveSelected
                ? (effectiveEnabled
                    ? accentColor
                    : accentColor.withValues(alpha: 0.6)) // 비활성화되어도 선택된 테두리 표시
                : (effectiveEnabled
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: effectiveEnabled
                  ? Colors.white
                  : (effectiveSelected
                      ? Colors.white
                      : Colors.white54), // 선택된 경우 비활성화되어도 흰색
              fontWeight:
                  effectiveSelected ? FontWeight.bold : FontWeight.normal,
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
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
    required this.result,
    required this.onBack,
  });

  final String person1Name;
  final String person2Name;
  final SajuCompatibilityResult result;
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
                              description: '서로의 장점을 살려 시너지를 낼 수 있는 관계입니다. '
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
        GestureDetector(
          onTap: onBack,
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
    final score = result.finalScore;
    final original = result.original;
    final stress = result.stress;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                '✨',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${score.toStringAsFixed(1)}점',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$name1님과 $name2님의 종합 궁합 지수입니다.',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  label: '기본 점수',
                  value: original.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  label: '스트레스',
                  value: stress.toStringAsFixed(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(
      {required String title, required String description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
            style: const TextStyle(
                color: Colors.white70, fontSize: 14, height: 1.6),
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
