import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart' show AuthScope;
import '../../controllers/community_controller.dart';
import '../../controllers/friend_controller.dart';
import '../../models/comment_model.dart';
import '../../models/community_post.dart';
import '../../services/api_client.dart';
import '../../shared/widgets/mystic_background.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    super.key,
    required this.postId,
    this.onBack,
  });

  final int postId;
  final VoidCallback? onBack;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  CommunityPostDetail? _detail;
  bool _loading = true;
  bool _postingComment = false;
  bool _liking = false;
  String? _error;
  final _commentCtrl = TextEditingController();
  bool _showAuthorModal = false;
  bool _sendingFriendRequest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final community = CommunityScope.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await community.fetchPostDetail(widget.postId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  

  Future<void> _toggleLike() async {
    if (!AuthScope.of(context).isLoggedIn) return;
    final community = CommunityScope.of(context);
    setState(() {
      _liking = true;
    });
    try {
      final result = await community.toggleLike(widget.postId);
      if (!mounted) return;
      setState(() {
        if (_detail != null) {
          _detail = CommunityPostDetail(
            post: _detail!.post.copyWith(
              likeCount: result['like_count'] as int,
              isLiked: result['is_liked'] as bool,
            ),
            comments: _detail!.comments,
          );
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _liking = false;
        });
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 내용을 입력해 주세요.')),
      );
      return;
    }
    final community = CommunityScope.of(context);
    setState(() {
      _postingComment = true;
    });
    try {
      final comment = await community.addComment(
        postId: widget.postId,
        content: text,
      );
      if (!mounted) return;
      setState(() {
        _detail = _detail == null
            ? null
            : CommunityPostDetail(
                post: CommunityPost(
                  id: _detail!.post.id,
                  title: _detail!.post.title,
                  content: _detail!.post.content,
                  authorId: _detail!.post.authorId,
                  boardType: _detail!.post.boardType,
                  createdAt: _detail!.post.createdAt,
                  updatedAt: _detail!.post.updatedAt,
                  likeCount: _detail!.post.likeCount,
                  commentCount: _detail!.comments.length + 1,
                ),
                comments: [..._detail!.comments, comment],
              );
        _commentCtrl.clear();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _postingComment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthScope.of(context).isLoggedIn;
    return Scaffold(
      body: Stack(
        children: [
          MysticBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? _errorView()
                            : _detail == null
                                ? const Center(
                                    child: Text(
                                      '게시글 정보를 불러오지 못했습니다.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _load,
                                    child: ListView(
                                      padding: const EdgeInsets.all(24),
                                      children: [
                                        _postCard(_detail!.post),
                                        const SizedBox(height: 24),
                                        _commentSection(_detail!.comments),
                                        if (isLoggedIn) ...[
                                          const SizedBox(height: 16),
                                          _commentInput(),
                                        ],
                                      ],
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          ),
          if (_showAuthorModal && _detail != null) _authorModal(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '게시글 상세',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _error!,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _postCard(CommunityPost post) {
    final auth = AuthScope.of(context);
    final isLiked = post.isLiked;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // 오행 게시판에서만 작성자 닉네임 클릭 가능
              post.category == BoardCategory.ohang && post.authorName != null && post.authorName!.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        final currentUserId = auth.user?.id;
                        // 본인 게시글은 모달 표시 안 함
                        if (currentUserId != null && post.authorId != currentUserId) {
                          setState(() => _showAuthorModal = true);
                        }
                      },
                      child: Text(
                        post.authorLabel,
                        style: const TextStyle(
                          color: Color(0xFFA5F3FC),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFA5F3FC),
                        ),
                      ),
                    )
                  : Text(
                      post.authorLabel,
                      style: const TextStyle(color: Color(0xFFA5F3FC)),
                    ),
              const SizedBox(width: 12),
              Text(
                post.dateLabel,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post.content,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: auth.isLoggedIn && !_liking ? _toggleLike : null,
                  child: _liking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.likeCount}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
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
    );
  }

  Widget _commentSection(List<CommentModel> comments) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '댓글 ${comments.length}개',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (comments.isEmpty)
            const Text(
              '첫 댓글을 남겨보세요!',
              style: TextStyle(color: Colors.white54),
            )
          else
            ...comments.map(
              (comment) {
                final auth = AuthScope.of(context);
                final isMyComment = auth.user?.id == comment.authorId;
                final isAuthorComment = comment.authorId == _detail?.post.authorId;
                final isOhangBoard = _detail?.post.category == BoardCategory.ohang;
                
                String authorLabel;
                // 오행 게시판인 경우 닉네임 표시
                if (isOhangBoard && comment.authorName != null && comment.authorName!.isNotEmpty) {
                  authorLabel = comment.authorName!;
                  // 작성자가 자신의 게시글에 댓글을 남긴 경우
                  if (isAuthorComment) {
                    authorLabel = '${comment.authorName!}(글쓴이)';
                  }
                } else {
                  // 익명 게시판인 경우
                  authorLabel = comment.authorLabel;
                  // 작성자가 자신의 게시글에 댓글을 남긴 경우
                  if (isAuthorComment) {
                    authorLabel = '익명(글쓴이)';
                  }
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              authorLabel,
                              style: TextStyle(
                                color: isMyComment ? const Color(0xFF38BDF8) : Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              comment.dateLabel,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          comment.content,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _commentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '댓글 작성',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentCtrl,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '댓글을 입력해 주세요...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(color: Color(0xFFFACC15)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _postingComment ? null : _submitComment,
              icon: _postingComment
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: const Text('등록'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFriendRequest() async {
    if (_detail == null) return;
    setState(() => _sendingFriendRequest = true);
    try {
      final friendController = FriendScope.of(context);
      await friendController.sendFriendRequest(_detail!.post.authorId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_detail!.post.authorName ?? "사용자"}님에게 친구 요청을 보냈습니다.'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      setState(() => _showAuthorModal = false);
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
        setState(() => _sendingFriendRequest = false);
      }
    }
  }

  Widget _authorModal() {
    if (_detail == null) return const SizedBox.shrink();
    final post = _detail!.post;
    final authorName = post.authorName ?? '알 수 없음';
    
    return GestureDetector(
      onTap: () => setState(() => _showAuthorModal = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 모달 내부 클릭 시 닫히지 않도록
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _avatar(authorName),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _verticalModalButton(
                    label: '친구 신청',
                    icon: Icons.person_add_outlined,
                    color: const Color(0xFFFACC15),
                    onTap: _sendingFriendRequest ? null : _sendFriendRequest,
                    isLoading: _sendingFriendRequest,
                  ),
                  const SizedBox(height: 8),
                  _verticalModalButton(
                    label: '쪽지 보내기',
                    icon: Icons.mail_outline,
                    color: const Color(0xFF22D3EE),
                    onTap: () {
                      setState(() => _showAuthorModal = false);
                      context.go(
                        '/send-message',
                        extra: {'name': authorName, 'id': post.authorId},
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _showAuthorModal = false),
                      child: const Text(
                        '닫기',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String name) {
    final text = name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFACC15), Color(0xFF22D3EE)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFACC15).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _verticalModalButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, size: 14),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
