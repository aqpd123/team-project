import 'package:flutter/material.dart';

import '../../shared/widgets/blur_card.dart';
import '../../shared/widgets/mystic_background.dart';

class FaqEntry {
  const FaqEntry({required this.question, required this.answer});

  final String question;
  final String answer;
}

class HelpPage extends StatelessWidget {
  const HelpPage({
    super.key,
    this.onBack,
    this.faqEntries = const [],
  });

  final VoidCallback? onBack;
  final List<FaqEntry> faqEntries;

  List<FaqEntry> get _defaultFaqs => const [
        FaqEntry(
          question: '사주보기는 어떻게 이용하나요?',
          answer: '홈 화면에서 사주보기를 누르고 정확한 생년월일을 입력하면 됩니다.',
        ),
        FaqEntry(
          question: '사주궁합은 어디서 확인하나요?',
          answer:
              '사주 메뉴에서 사주궁합보기를 선택해 두 사람의 정보를 입력하면 궁합을 볼 수 있어요.',
        ),
        FaqEntry(
          question: '게시판 사용법이 궁금해요.',
          answer: '게시판에서 글을 작성하고 다른 이용자와 소통할 수 있습니다.',
        ),
        FaqEntry(
          question: '프로필 정보는 어디서 수정하나요?',
          answer: '더보기 > 프로필 설정 메뉴에서 닉네임, 이메일 등을 수정할 수 있습니다.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final entries = faqEntries.isEmpty ? _defaultFaqs : faqEntries;
    return Scaffold(
      body: MysticBackground(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _backButton(),
                const Text(
                  '도움말 ❓',
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
            Expanded(
              child: ListView(
                children: [
                  BlurCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '앱 사용법',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text('• 홈 화면에서 개인 사주를 확인하세요',
                            style: TextStyle(color: Colors.white70)),
                        Text('• 게시판에서 사용자들과 소통하세요',
                            style: TextStyle(color: Colors.white70)),
                        Text('• 더보기에서 각종 설정을 변경할 수 있어요',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlurCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '자주 묻는 질문',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...entries.map(
                          (faq) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q. ${faq.question}',
                                  style: const TextStyle(
                                    color: Color(0xFFFACC15),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'A. ${faq.answer}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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

