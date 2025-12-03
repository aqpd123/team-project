import 'comment_model.dart';

enum BoardCategory { anonymous, ohang }

class CommunityPost {
  CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.boardType,
    this.createdAt,
    this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.authorName,
  });

  final int id;
  final String title;
  final String content;
  final int authorId;
  final String? boardType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final String? authorName;

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['post_id'] as int? ?? 0,
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      authorId: json['author_id'] as int? ?? 0,
      boardType: (json['board_type'] as String?)?.trim(),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      authorName: json['author_name'] as String?,
    );
  }
  
  CommunityPost copyWith({
    int? id,
    String? title,
    String? content,
    int? authorId,
    String? boardType,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    String? authorName,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      boardType: boardType ?? this.boardType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      authorName: authorName ?? this.authorName,
    );
  }

  String get _normalizedBoardType => (boardType ?? '').trim().toLowerCase();

  BoardCategory get category =>
      _ohangKeys.contains(_normalizedBoardType) ? BoardCategory.ohang : BoardCategory.anonymous;

  String get ohangKey =>
      _ohangKeys.contains(_normalizedBoardType) ? _normalizedBoardType : '';

  String get authorLabel {
    // 오행 게시판인 경우 닉네임 표시, 익명 게시판인 경우 익명 표시
    if (category == BoardCategory.ohang && authorName != null && authorName!.isNotEmpty) {
      return authorName!;
    }
    return '익명';
  }

  String get dateLabel {
    final base = updatedAt ?? createdAt;
    if (base == null) return '';
    final month = base.month.toString().padLeft(2, '0');
    final day = base.day.toString().padLeft(2, '0');
    final hour = base.hour.toString().padLeft(2, '0');
    final minute = base.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}

const Set<String> _ohangKeys = {'fire', 'water', 'wood', 'metal', 'earth'};

class CommunityPostDetail {
  CommunityPostDetail({
    required this.post,
    required this.comments,
  });

  final CommunityPost post;
  final List<CommentModel> comments;
}

