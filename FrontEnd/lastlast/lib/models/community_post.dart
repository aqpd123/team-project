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
    );
  }

  String get _normalizedBoardType => (boardType ?? '').trim().toLowerCase();

  BoardCategory get category =>
      _ohangKeys.contains(_normalizedBoardType) ? BoardCategory.ohang : BoardCategory.anonymous;

  String get ohangKey =>
      _ohangKeys.contains(_normalizedBoardType) ? _normalizedBoardType : '';

  String get authorLabel => '익명 #$authorId';

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


