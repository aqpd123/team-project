import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../services/api_client.dart';

/// React `pages/account-settings/page.tsx`를 Flutter로 변환한 페이지.
/// 계정 정보 관리, 비밀번호 변경, 로그아웃, 회원탈퇴 기능을 제공합니다.
class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({
    super.key,
    this.onBack,
    this.onSave,
    this.onLogout,
    this.onDeleteAccount,
  });

  final VoidCallback? onBack;
  final Future<void> Function(AccountSettingsData data)? onSave;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class AccountSettingsData {
  AccountSettingsData({
    required this.nickname,
    required this.email,
    this.newPassword,
  });

  final String nickname;
  final String email;
  final String? newPassword;
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _emailCtrl;
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _showPasswordChangeForm = false;
  bool _isCurrentPasswordVerified = false;
  bool _showDeleteModal = false;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // 빈 값으로 초기화
    _nicknameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // didChangeDependencies에서 사용자 정보 로드
    if (!_initialized) {
      final auth = AuthScope.of(context);
      if (auth.user != null) {
        _nicknameCtrl.text = auth.user!.name;
        _emailCtrl.text = auth.user!.email;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCurrentPasswordVerification() async {
    if (_currentPasswordCtrl.text.trim().isEmpty) {
      _showSnackBar('현재 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = AuthScope.of(context);
      if (auth.user == null) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('로그인이 필요합니다.');
        return;
      }

      // 로그인 API를 사용하여 현재 비밀번호 확인
      // 토큰 없이 호출하기 위해 새로운 ApiClient 인스턴스 사용
      final verifyApi = ApiClient();
      await verifyApi.post(
        '/auth/login',
        data: {
          'email': auth.user!.email,
          'password': _currentPasswordCtrl.text,
        },
      );

      setState(() {
        _isCurrentPasswordVerified = true;
        _isLoading = false;
      });
      _showSnackBar('현재 비밀번호가 확인되었습니다. 새 비밀번호를 설정해주세요.');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('현재 비밀번호가 일치하지 않습니다.');
      setState(() {
        _currentPasswordCtrl.clear();
      });
    }
  }

  Future<void> _handlePasswordChange() async {
    if (!_isCurrentPasswordVerified) {
      _showSnackBar('먼저 현재 비밀번호를 확인해주세요.');
      return;
    }

    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      _showSnackBar('새 비밀번호가 일치하지 않습니다.');
      return;
    }
    if (_newPasswordCtrl.text.length < 6) {
      _showSnackBar('비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    final auth = AuthScope.of(context);
    if (auth.user == null) {
      _showSnackBar('로그인이 필요합니다.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ApiClient();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        api.updateToken(token);
      }

      // 비밀번호 변경 API 호출
      await api.patch(
        '/users/${auth.user!.id}',
        data: {
          'current_password': _currentPasswordCtrl.text,
          'new_password': _newPasswordCtrl.text,
        },
      );

      if (!mounted) return;
      _showSnackBar('비밀번호가 변경되었습니다.');
      setState(() {
        _currentPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();
        _isCurrentPasswordVerified = false;
        _showPasswordChangeForm = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnackBar('비밀번호 변경 실패: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('비밀번호 변경 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleNicknameChange() async {
    if (_nicknameCtrl.text.trim().length < 2) {
      _showSnackBar('닉네임은 2자 이상이어야 합니다.');
      return;
    }

    final auth = AuthScope.of(context);
    if (auth.user == null) {
      _showSnackBar('로그인이 필요합니다.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ApiClient();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        api.updateToken(token);
      }

      // 닉네임 변경 API 호출
      await api.patch(
        '/users/${auth.user!.id}',
        data: {
          'username': _nicknameCtrl.text.trim(),
        },
      );

      // 사용자 정보 새로고침
      await auth.refreshUser();

      if (!mounted) return;
      _showSnackBar('닉네임이 변경되었습니다.');
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnackBar('닉네임 변경 실패: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('닉네임 변경 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetPasswordChange() {
    setState(() {
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
      _isCurrentPasswordVerified = false;
      _showPasswordChangeForm = false;
    });
  }

  void _handleLogout() {
    widget.onLogout?.call();
    if (context.mounted) {
      context.go('/login');
    }
  }

  void _handleDeleteAccount() {
    widget.onDeleteAccount?.call();
    if (context.mounted) {
      context.go('/login');
    }
    _showSnackBar('회원탈퇴가 완료되었습니다.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
      ],
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x660F172A),
              Color(0x4D1E1B4B),
              Color(0x662E1065),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _circleButton(
              icon: Icons.arrow_back,
              onTap: widget.onBack ?? () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                '계정 설정',
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
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '계정 정보를 관리하고 보안을 설정해보세요',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기본 정보',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildNicknameField(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이메일',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            _emailCtrl.text,
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNicknameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '닉네임',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nicknameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '닉네임을 입력하세요',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFFACC15)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleNicknameChange,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFACC15),
                foregroundColor: const Color(0xFF0F172A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0F172A),
                      ),
                    )
                  : const Text(
                      '변경',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordChangeSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '비밀번호 변경',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (!_showPasswordChangeForm)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showPasswordChangeForm = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACC15),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '비밀번호 변경하기',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            _buildPasswordChangeForm(),
        ],
      ),
    );
  }

  Widget _buildPasswordChangeForm() {
    if (!_isCurrentPasswordVerified) {
      return Column(
        children: [
          _buildTextField(
            controller: _currentPasswordCtrl,
            label: '현재 비밀번호',
            hint: '현재 비밀번호를 입력하세요',
            obscure: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetPasswordChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _handleCurrentPasswordVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFACC15),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0F172A),
                          ),
                        )
                      : const Text(
                          '확인',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                '현재 비밀번호가 확인되었습니다',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _newPasswordCtrl,
          label: '새 비밀번호',
          hint: '새 비밀번호를 입력하세요 (6자 이상)',
          obscure: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordCtrl,
          label: '새 비밀번호 확인',
          hint: '새 비밀번호를 다시 입력하세요',
          obscure: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _resetPasswordChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('취소'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePasswordChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACC15),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0F172A),
                        ),
                      )
                    : const Text(
                        '비밀번호 변경',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFFACC15)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountManagementSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '계정 관리',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildLogoutButton(),
          const SizedBox(height: 12),
          _buildDeleteAccountButton(),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '계정에서 로그아웃합니다',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.logout, color: Colors.blue, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDeleteModal = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '회원탈퇴',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '계정을 영구적으로 삭제합니다',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.delete_outline, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildOverlay(),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildPasswordChangeSection(),
                    const SizedBox(height: 24),
                    _buildAccountManagementSection(),
                  ],
                ),
              ),
            ),
          ),
          if (_showDeleteModal) _buildDeleteModal(),
        ],
      ),
    );
  }

  Widget _buildDeleteModal() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                '회원탈퇴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '정말로 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showDeleteModal = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showDeleteModal = false;
                        });
                        _handleDeleteAccount();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        '탈퇴하기',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
