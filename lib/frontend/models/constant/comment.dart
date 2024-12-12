import 'package:eureka_final_version/frontend/models/constant/reply.dart';

class CommentEureka {
  final String id;
  final String genieId;
  final String authorId;
  final String authorName;
  final String? authorTitle;
  final String? authorProfession;
  final String content;
  final int createdAt;
  final String? authorProfileImage;
  List<ReplyComment>? replies;

  CommentEureka({
    required this.id,
    required this.genieId,
    required this.authorId,
    required this.authorName,
    this.authorTitle,
    this.authorProfession,
    required this.content,
    required this.createdAt,
    this.authorProfileImage,
  });

  factory CommentEureka.fromJson(Map<String, dynamic> json) {
    return CommentEureka(
      id: json['id'] ?? '',
      genieId: json['genieId'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorTitle: json['authorTitle'],
      authorProfession: json['authorProfession'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'],
      authorProfileImage: json['authorProfileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'genieId': genieId,
      'authorId': authorId,
      'authorName': authorName,
      'authorTitle': authorTitle,
      'authorProfession': authorProfession,
      'content': content,
      'createdAt': createdAt,
      'authorProfileImage': authorProfileImage,
    };
  }
}
