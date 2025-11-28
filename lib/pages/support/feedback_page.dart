import 'package:flutter/material.dart';

import '../../shared/widgets/mystic_background.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({
    super.key,
    this.onBack,
    this.onSubmit,
  });

  final VoidCallback? onBack;
  final Future<void> Function(FeedbackPayload payload)? onSubmit;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class FeedbackPayload {
  FeedbackPayload({
    required this.type,
    required this.subject,
    required this.message,
    required this.email,
  });

  final String type;
  final String subject;
  final String message;
  final String email;
}

class _FeedbackPageState extends State<FeedbackPage> {
  String _type = '';
  String _subject = '';
  String _message = '';
  String _email = '';
  bool _submitting = false;
  bool _submitted = false;

  final _formKey = GlobalKey<FormState>();

  final _types = const [
    ('bug', '버그 신고', Icons.bug_report_outlined, [Color(0xFFF87171), Color(0xFFE11D48)]),
    ('feature', '기능 제안', Icons.lightbulb_outline, [Color(0xFFFBBF24), Color(0xFFF97316)]),
    ('improve', '개선 사항', Icons.build_outlined, [Color(0xFF38BDF8), Color(0xFF22D3EE)]),
    ('other', '기타 의견', Icons.chat_bubble_outline, [Color(0xFF8B5CF6), Color(0xFFE879F9)]),
  ];

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_type.isEmpty) return;
    setState(() => _submitting = true);

    final payload = FeedbackPayload(
      type: _type,
      subject: _subject,
      message: _message,
      email: _email,
    );

    if (widget.onSubmit != null) {
      await widget.onSubmit!(payload);
    } else {
      await Future<void>.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = true;
    });
  }

  void _reset() {
    setState(() {
      _type = '';
      _subject = '';
      _message = '';
      _email = '';
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        body: MysticBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF34D399), Color(0xFF10B981)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  '피드백이 전송되었어요!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '소중한 의견 감사합니다.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('다른 피드백 보내기'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: MysticBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _backButton(),
                  const Text(
                    '피드백 💌',
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
              const Text(
                '개발자에게 의견을 들려주세요',
                style: TextStyle(color: Color(0xFFA5F3FC)),
              ),
              const SizedBox(height: 20),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildTextField(
                label: '제목',
                hint: '피드백 제목을 입력해주세요',
                value: _subject,
                onChanged: (v) => setState(() => _subject = v),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: '내용',
                hint: '자세한 내용을 입력해주세요',
                value: _message,
                maxLines: 6,
                maxLength: 500,
                onChanged: (v) => setState(() => _message = v),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_message.length}/500',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: '이메일 (선택)',
                hint: '답장을 받고 싶다면 입력하세요',
                value: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final emailRegex = RegExp(r'.+@.+\..+');
                  if (!emailRegex.hasMatch(value)) {
                    return '유효한 이메일을 입력해주세요';
                  }
                  return null;
                },
                onChanged: (v) => setState(() => _email = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    _submitting ? null : () => _handleSubmit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACC15),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '피드백 보내기',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _types.map((type) {
        final selected = _type == type.$1;
        return GestureDetector(
          onTap: () => setState(() => _type = type.$1),
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? const Color(0xFFFACC15) : Colors.white24,
                width: 2,
              ),
              color: selected ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.05),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: type.$4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(type.$3, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  type.$2,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator ??
              (val) {
                if (val == null || val.isEmpty) {
                  return '$label 을(를) 입력해주세요';
                }
                return null;
              },
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFFACC15)),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: widget.onBack,
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
}

