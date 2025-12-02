import 'package:flutter/material.dart';

import '../../shared/widgets/blur_card.dart';
import '../../shared/widgets/mystic_background.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _backButton(),
                  const Text(
                    '앱 정보 ℹ️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              BlurCard(
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.transparent,
                      child: Text('🌙', style: TextStyle(fontSize: 32)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '신비한 사주',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '전통 사주학을 현대적으로 해석한 앱',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BlurCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _InfoRow(label: '앱 버전', value: '1.0.0'),
                    _InfoRow(label: '빌드 번호', value: '2024.01.15'),
                    _InfoRow(label: '최신 업데이트', value: '2024년 1월 15일'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BlurCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _InfoRow(label: '개발사', value: '신비한 개발팀'),
                    _InfoRow(label: '이메일', value: 'contact@saju.app'),
                    _InfoRow(label: '웹사이트', value: 'www.saju.app'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BlurCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '라이선스',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• 전통 사주학을 기반으로 제작되었습니다.\n'
                      '• 모든 해석은 참고용이며 절대적 진리가 아닙니다.\n'
                      '• 개인정보는 안전하게 보호됩니다.\n'
                      '• 앱 사용 시 이용약관에 동의한 것으로 간주됩니다.',
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '© 2024 신비한 사주. All rights reserved.',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
}

