import 'dart:convert';
import 'package:eureka_final_version/frontend/api/URLs/urls.dart';
import 'package:eureka_final_version/frontend/models/constant/comment.dart';
import 'package:eureka_final_version/frontend/models/constant/reply.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CommentService {
  static final String commentURL = UrlManager.getCommentURL();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<List<CommentEureka>> getGenieComments(String genieId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      final response = await http
          .get(Uri.parse('$commentURL/get-comments/genie/$genieId'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> commentsJson = data['comments'];
        final List<CommentEureka> comments =
            commentsJson.map((json) => CommentEureka.fromJson(json)).toList();
        for (var comment in comments) {
          comment.replies = await getCommentReplies(genieId, comment.id);
        }

        return comments;
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Failed to load comments');
    }
  }

  Future<CommentEureka> createComment(String genieId, String content) async {
    try {
      debugPrint('genieId from comment creation: $genieId');
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse('$commentURL/create-comments/genie/$genieId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(content),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create comment: ${response.statusCode}');
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      debugPrint('Response data from creation service: $responseData');

      final Map<String, dynamic> commentData = responseData['comment'];

      if (commentData['content'] is Map) {
        commentData['content'] = commentData['content']['content'];
      }

      debugPrint('Comment data: $commentData');

      return CommentEureka.fromJson(commentData);
    } catch (e) {
      debugPrint('Error creating comment: $e');
      throw Exception('Failed to create comment: $e');
    }
  }

  Future<ReplyComment> createReply(
      String commentId, String content, String replyingTo) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      final response = await http.post(
        Uri.parse('$commentURL/create-reply/comment/$commentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(content),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to create reply: ${response.statusCode}');
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      final Map<String, dynamic> replyData = responseData['reply'];

      if (replyData['content'] is Map) {
        replyData['content'] = replyData['content']['content'];
      }
      return ReplyComment.fromJson(replyData);
    } catch (e) {
      throw Exception('Failed to create reply: $e');
    }
  }

  Future<List<ReplyComment>> getCommentReplies(
      String genieId, String commentId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$commentURL/comments/$commentId/replies?genieId=$genieId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic> repliesJson = data['replies'] ?? [];

        debugPrint('Replies data: $repliesJson');

        return repliesJson.map((json) => ReplyComment.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load replies: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching replies: $e');
      return [];
    }
  }

  Future<void> deleteComment(String commentId, String genieId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.delete(
        Uri.parse('$commentURL/delete-comments/$commentId/genie/$genieId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }

      return;
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}
