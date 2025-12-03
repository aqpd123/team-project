class CommentModel {
  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    this.anonymousNumber,
    this.createdAt,
    this.updatedAt,
    this.authorName,
  });

  final int id;
  final int postId;
  final int authorId;
  final String content;
  final int? anonymousNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? authorName;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['comment_id'] as int? ?? 0,
      postId: json['post_id'] as int? ?? 0,
      authorId: json['author_id'] as int? ?? 0,
      content: (json['content'] ?? '') as String,
      anonymousNumber: json['anonymous_number'] as int?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      authorName: json['author_name'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  String get authorLabel {
    if (anonymousNumber != null) {
      return '익명 #$anonymousNumber';
    }
    // anonymous_number가 없는 경우 (기존 데이터 호환성)
    return '익명 #$authorId';
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
}


