import 'dart:convert';
import 'package:eureka_final_version/frontend/models/constant/comment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CommentService {
  final String? commentEndpoint = dotenv.env['COMMENT_API_URL'];
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<List<CommentEureka>> getGenieComments(String genieId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      final response = await http.get(
          Uri.parse('$commentEndpoint/get-comments/genie/$genieId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          });
      if (response.statusCode != 200) {
        throw Exception('Failed to load comments');
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      debugPrint('Response data: $responseData');

      final List<dynamic> commentsJson = responseData['comments'];
      return commentsJson.map((json) => CommentEureka.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load comments');
    }
  }

  Future<CommentEureka> createComment(String genieId, String content) async {
    try {
      debugPrint('genieId from comment creation: $genieId');
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse('$commentEndpoint/create-comments/genie/$genieId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(content),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create comment: ${response.statusCode}');
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      debugPrint('Response data: $responseData');

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
}
