import 'package:flutter/material.dart';

import '../../shared/widgets/mystic_background.dart';

class WritePostPage extends StatefulWidget {
  const WritePostPage({
    super.key,
    this.onBack,
    this.onSubmit,
  });

  final VoidCallback? onBack;
  final Future<void> Function(WritePostPayload payload)? onSubmit;

  @override
  State<WritePostPage> createState() => _WritePostPageState();
}

class WritePostPayload {
  WritePostPayload({
    required this.title,
    required this.content,
    required this.category,
    required this.ohangCategory,
  });

  final String title;
  final String content;
  final String category; // anonymous or ohang
  final String ohangCategory; // fire/water/...
}

class _WritePostPageState extends State<WritePostPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  String _category = 'anonymous';
  String _ohangCategory = '';
  bool _submitting = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == 'ohang' && _ohangCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오행 카테고리를 선택해주세요.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final payload = WritePostPayload(
      title: _title,
      content: _content,
      category: _category,
      ohangCategory: _ohangCategory,
    );
    if (widget.onSubmit != null) {
      await widget.onSubmit!(payload);
    } else {
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
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
                    '글쓰기 ✍️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: _submitting ? null : _handleSubmit,
                    child: _submitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('완료'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _categorySelector(),
              if (_category == 'ohang') ...[
                const SizedBox(height: 16),
                _ohangSelector(),
              ],
              const SizedBox(height: 16),
              _textField(
                label: '제목',
                hint: '제목을 입력하세요...',
                maxLength: 60,
                value: _title,
                onChanged: (v) => setState(() => _title = v),
              ),
              const SizedBox(height: 12),
              _textField(
                label: '내용',
                hint: '내용을 입력하세요...',
                maxLines: 12,
                value: _content,
                onChanged: (v) => setState(() => _content = v),
              ),
              const SizedBox(height: 12),
              _tips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categorySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _categoryButton('익명 게시판', 'anonymous'),
          _categoryButton('오행 게시판', 'ohang'),
        ],
      ),
    );
  }

  Widget _categoryButton(String label, String value) {
    final selected = _category == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _category = value;
          if (value == 'anonymous') _ohangCategory = '';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFACC15) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ohangSelector() {
    Widget buildChip(String label, String value, List<Color> colors, IconData icon) {
      final selected = _ohangCategory == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _ohangCategory = value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오행 카테고리를 선택하세요',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            buildChip('화', 'fire', [const Color(0xFFF87171), const Color(0xFFF97316)],
                Icons.local_fire_department_outlined),
            const SizedBox(width: 8),
            buildChip('수', 'water', [const Color(0xFF38BDF8), const Color(0xFF22D3EE)],
                Icons.water_drop_outlined),
            const SizedBox(width: 8),
            buildChip('목', 'wood', [const Color(0xFF34D399), const Color(0xFF10B981)],
                Icons.eco_outlined),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            buildChip('금', 'metal', [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
                Icons.hexagon_outlined),
            const SizedBox(width: 8),
            buildChip('토', 'earth', [const Color(0xFFD97706), const Color(0xFFB45309)],
                Icons.landscape_outlined),
          ],
        ),
      ],
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
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

  Widget _tips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE).withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '작성 팁',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• 상대를 배려하는 표현을 사용해 주세요\n'
            '• 개인정보는 공유하지 마세요\n'
            '• 사주와 관련된 경험을 나누어보세요',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
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

