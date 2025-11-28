import 'package:flutter/material.dart';

import '../../shared/widgets/blur_card.dart';
import '../../shared/widgets/mystic_background.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key, this.onBack});

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
                    '서비스 약관 📋',
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
                child: _section(
                  title: '이용약관',
                  icon: Icons.description_outlined,
                  color: const Color(0xFFFACC15),
                  children: const [
                    _Paragraph(
                      heading: '제1조 (목적)',
                      body:
                          '본 약관은 사주보기 서비스 이용과 관련하여 회사와 이용자 간의 권리와 의무를 규정합니다.',
                    ),
                    _Paragraph(
                      heading: '제2조 (정의)',
                      body:
                          '서비스는 사주 분석 기능을 의미하며, 이용자는 회원 및 비회원을 모두 포함합니다.',
                    ),
                    _Paragraph(
                      heading: '제3조 (서비스 제공)',
                      body:
                          '회사는 개인 사주 분석, 사주 궁합, 유명인 궁합, 커뮤니티 게시판 서비스를 제공합니다.',
                    ),
                    _Paragraph(
                      heading: '제4조 (이용자의 의무)',
                      body:
                          '정확한 정보를 입력하고 타인의 권리를 침해하지 않으며 서비스 운영을 방해하지 않아야 합니다.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BlurCard(
                child: _section(
                  title: '개인정보처리방침',
                  icon: Icons.privacy_tip_outlined,
                  color: const Color(0xFF34D399),
                  children: const [
                    _Paragraph(
                      heading: '1. 수집 및 이용 목적',
                      body:
                          '회원가입, 사주 분석 제공, 서비스 개선 및 맞춤형 서비스 제공을 위해 정보를 수집합니다.',
                    ),
                    _Paragraph(
                      heading: '2. 수집 항목',
                      body:
                          '필수: 이메일, 닉네임, 생년월일, 출생시간 / 선택: 성별, 프로필 사진',
                    ),
                    _Paragraph(
                      heading: '3. 보유 기간',
                      body: '회원 탈퇴 시까지 보관하며, 법령이 요구할 경우 해당 기간 보유합니다.',
                    ),
                    _Paragraph(
                      heading: '4. 제3자 제공',
                      body: '이용자 동의 없이 개인정보를 제3자에게 제공하지 않습니다.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BlurCard(
                child: _section(
                  title: '문의 사항',
                  icon: Icons.support_agent,
                  color: const Color(0xFF60A5FA),
                  children: const [
                    _Paragraph(
                      heading: '이메일',
                      body: 'support@sajuapp.com',
                    ),
                    _Paragraph(
                      heading: '운영시간',
                      body: '평일 09:00 - 18:00',
                    ),
                  ],
                ),
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
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Color color,
    required List<_Paragraph> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

