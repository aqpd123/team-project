import 'package:flutter/material.dart';

import '../../controllers/community_controller.dart';
import '../../services/api_client.dart';
import '../../shared/widgets/mystic_background.dart';

class WritePostPage extends StatefulWidget {
  const WritePostPage({
    super.key,
    this.onBack,
    this.postId,
    this.initialTitle,
    this.initialContent,
    this.initialBoardType,
  });

  final VoidCallback? onBack;
  final int? postId; // 수정 모드일 때 게시글 ID
  final String? initialTitle;
  final String? initialContent;
  final String? initialBoardType;

  @override
  State<WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  String _category = 'anonymous';
  String _ohangCategory = '';
  bool _submitting = false;
  bool _isEditMode = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // 빈 값으로 초기화
    _titleCtrl = TextEditingController();
    _contentCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // didChangeDependencies에서 초기값 설정
    if (!_initialized) {
      _isEditMode = widget.postId != null;

      // 초기값 설정
      if (widget.initialTitle != null && widget.initialTitle!.isNotEmpty) {
        _titleCtrl.text = widget.initialTitle!;
      }
      if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
        _contentCtrl.text = widget.initialContent!;
      }

      // 수정 모드일 때 board_type에 따라 카테고리 설정
      if (_isEditMode && widget.initialBoardType != null) {
        final boardType = widget.initialBoardType!.toLowerCase();
        if (['fire', 'water', 'wood', 'metal', 'earth'].contains(boardType)) {
          _category = 'ohang';
          _ohangCategory = boardType;
        } else {
          _category = 'anonymous';
        }
      }

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == 'ohang' && _ohangCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오행 카테고리를 선택해주세요.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final community = CommunityScope.of(context);
    // 오행 게시판일 때는 _ohangCategory를 사용, 익명 게시판일 때는 null
    final boardType = _category == 'ohang' && _ohangCategory.isNotEmpty
        ? _ohangCategory
        : null;
    try {
      if (_isEditMode && widget.postId != null) {
        // 수정 모드
        await community.updatePost(
          postId: widget.postId!,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 성공적으로 수정되었습니다!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        // 작성 모드
        await community.createPost(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          boardType: boardType,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 성공적으로 업로드되었습니다!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
      widget.onBack?.call();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _backButton(),
                        GestureDetector(
                          onTap: _submitting ? null : _handleSubmit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '완료',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _isEditMode ? '글 수정 ✏️' : '글쓰기 ✍️',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 수정 모드일 때는 카테고리 선택 비활성화
                if (!_isEditMode) ...[
                  _categorySelector(),
                  if (_category == 'ohang') ...[
                    const SizedBox(height: 16),
                    _ohangSelector(),
                  ],
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),
                _textField(
                  label: '제목',
                  hint: '제목을 입력하세요...',
                  maxLength: 60,
                  controller: _titleCtrl,
                ),
                const SizedBox(height: 12),
                _textField(
                  label: '내용',
                  hint: '내용을 입력하세요...',
                  maxLines: 12,
                  controller: _contentCtrl,
                ),
                const SizedBox(height: 12),
                _tips(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _categorySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
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
    Widget buildChip(
        String label, String value, List<Color> colors, IconData icon) {
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
            buildChip(
                '화',
                'fire',
                [const Color(0xFFF87171), const Color(0xFFF97316)],
                Icons.local_fire_department_outlined),
            const SizedBox(width: 8),
            buildChip(
                '수',
                'water',
                [const Color(0xFF38BDF8), const Color(0xFF22D3EE)],
                Icons.water_drop_outlined),
            const SizedBox(width: 8),
            buildChip(
                '목',
                'wood',
                [const Color(0xFF34D399), const Color(0xFF10B981)],
                Icons.eco_outlined),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            buildChip(
                '금',
                'metal',
                [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
                Icons.hexagon_outlined),
            const SizedBox(width: 8),
            buildChip(
                '토',
                'earth',
                [const Color(0xFFD97706), const Color(0xFFB45309)],
                Icons.landscape_outlined),
          ],
        ),
      ],
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return '$label 을(를) 입력해주세요';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
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
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _tips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }
}
