class ReplyComment {
  final String id;
  final String genieId;
  final String content;
  final String likes;
  final String? replyingTo;
  final int createdAt;
  final String? updatedAt;
  final String authorName;
  final String authorId;
  final String profileImageAuthor;
  final String authorProfession;

  ReplyComment({
    required this.id,
    required this.genieId,
    required this.likes,
    required this.content,
    this.replyingTo,
    required this.createdAt,
    required this.authorId,
    this.updatedAt,
    required this.authorName,
    required this.profileImageAuthor,
    required this.authorProfession,
  });

  factory ReplyComment.fromJson(Map<String, dynamic> json) {
    return ReplyComment(
      id: json['id']?.toString() ?? '',
      genieId: json['genieId']?.toString() ?? '',
      likes: json['likes']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      replyingTo: json['replyingTo']?.toString(),
      createdAt: json['createdAt'] is int ? json['createdAt'] : 0,
      updatedAt: json['updatedAt']?.toString(),
      authorName: json['authorName']?.toString() ?? '',
      profileImageAuthor: json['profileImageAuthor']?.toString() ?? '',
      authorProfession: json['authorProfession']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'genieId': genieId,
      'likes': likes,
      'content': content,
      'replyingTo': replyingTo,
      'createdAt': createdAt,
      'authorId': authorId,
      'updatedAt': updatedAt,
      'authorName': authorName,
      'profileImage': profileImageAuthor,
      'authorProfession': authorProfession,
    };
  }

  @override
  String toString() {
    return 'ReplyComment{id: $id, content: $content, replyingTo: $replyingTo, createdAt: $createdAt, updatedAt: $updatedAt, genieId: $genieId}';
  }
}
