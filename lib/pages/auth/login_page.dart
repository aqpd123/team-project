import 'dart:ui';

import 'package:flutter/material.dart';

/// React `pages/login/page.tsx`를 Flutter로 재구현한 화면.
/// 인증 로직은 외부에서 콜백으로 주입받고, UI/상태만 관리한다.
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onBack,
    this.onLogin,
    this.onRegister,
    this.onNavigateAfterSuccess,
    this.onKakaoLogin,
    this.initialModeIsLogin = true,
  });

  final VoidCallback? onBack;
  final Future<bool> Function(String email, String password)? onLogin;
  final Future<bool> Function(String email, String password, String name, String nickname)?
      onRegister;
  final VoidCallback? onNavigateAfterSuccess;
  final Future<void> Function()? onKakaoLogin;
  final bool initialModeIsLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _isLoginMode;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.initialModeIsLogin;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!_isLoginMode && _passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() {
        _isLoading = false;
        _errorMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    try {
      bool success = false;
      if (_isLoginMode) {
        if (widget.onLogin != null) {
          success = await widget.onLogin!(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
        }
      } else {
        if (widget.onRegister != null) {
          success = await widget.onRegister!(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            _nameCtrl.text.trim(),
            _nicknameCtrl.text.trim(),
          );
        }
      }

      if (success) {
        widget.onNavigateAfterSuccess?.call();
      } else {
        setState(() {
          _errorMessage = _isLoginMode ? '로그인에 실패했습니다.' : '회원가입에 실패했습니다.';
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = '오류가 발생했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleKakaoLogin() async {
    if (widget.onKakaoLogin != null) {
      try {
        await widget.onKakaoLogin!();
      } catch (_) {
        setState(() {
          _errorMessage = '카카오 로그인 중 오류가 발생했습니다.';
        });
      }
    } else {
      setState(() {
        _errorMessage = '카카오 로그인 기능은 준비 중입니다.';
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      _nameCtrl.clear();
      _nicknameCtrl.clear();
      _confirmPasswordCtrl.clear();
    });
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildFormCard(),
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
            'https://readdy.ai/api/search-image?query=mystical%20kawaii%20illustration%20style%2C%20traditional%20Korean%20hanok%20temple%20at%20peaceful%20night%20scene%2C%20high%20quality%20detailed%20artwork%2C%20soft%20dreamy%20aesthetic%2C%20ancient%20temple%20with%20warm%20glowing%20paper%20lanterns%2C%20majestic%20bright%20full%20moon%20illuminating%20the%20dark%20blue%20starry%20sky%2C%20countless%20twinkling%20stars%20scattered%20across%20the%20heavens%2C%20serene%20reflecting%20pond%20with%20elegant%20stone%20bridge%2C%20misty%20ethereal%20atmosphere%2C%20soft%20pastel%20night%20colors%20with%20deep%20blues%20and%20purples%2C%20traditional%20Korean%20architecture%20with%20curved%20rooftops%2C%20gentle%20mist%20rising%20from%20the%20water%2C%20enchanted%20fairy%20tale%20ambiance%2C%20nostalgic%20vintage%20feel%2C%20mobile%20wallpaper%20vertical%20composition%2C%20mystical%20lighting%20effects%2C%20peaceful%20zen%20garden%20elements&width=375&height=812&seq=mystical-temple-login&orientation=portrait',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            color: Colors.black.withOpacity(0.2),
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

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: widget.onBack,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _isLoginMode ? '로그인 🌙' : '회원가입 ✨',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 6,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLoginMode ? '별빛 사주의 세계로 들어오세요' : '새로운 여행자가 되어보세요',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFA5F3FC),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _emailCtrl,
            label: '이메일',
            hint: '이메일을 입력하세요',
            keyboardType: TextInputType.emailAddress,
          ),
          if (!_isLoginMode) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameCtrl,
              label: '이름',
              hint: '실명을 입력하세요',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nicknameCtrl,
              label: '닉네임',
              hint: '닉네임을 입력하세요',
            ),
          ],
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordCtrl,
            label: '비밀번호',
            hint: '비밀번호를 입력하세요',
            obscure: true,
          ),
          if (!_isLoginMode) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordCtrl,
              label: '비밀번호 재확인',
              hint: '비밀번호를 다시 입력하세요',
              obscure: true,
            ),
          ],
          const SizedBox(height: 12),
          if (_errorMessage != null) _buildErrorBanner(_errorMessage!),
          const SizedBox(height: 8),
          _buildSubmitButton(),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 12),
          _buildKakaoButton(),
          const SizedBox(height: 16),
          _buildToggleModeButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFFACC15)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFFFACC15),
          foregroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
        ),
        child: Text(
          _isLoading
              ? '처리 중...'
              : _isLoginMode
                  ? '로그인'
                  : '회원가입',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '또는',
            style: TextStyle(color: Colors.white60),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildKakaoButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleKakaoLogin,
        icon: const Icon(Icons.chat_bubble, color: Colors.black),
        label: Text(
          '카카오 계정으로 ${_isLoginMode ? '로그인' : '시작하기'}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          backgroundColor: const Color(0xFFFEE500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
        ),
      ),
    );
  }

  Widget _buildToggleModeButton() {
    return TextButton(
      onPressed: _isLoading ? null : _toggleMode,
      child: Text(
        _isLoginMode ? '계정이 없으신가요? 회원가입' : '이미 계정이 있으신가요? 로그인',
        style: const TextStyle(
          color: Color(0xFFA5F3FC),
        ),
      ),
    );
  }
}

