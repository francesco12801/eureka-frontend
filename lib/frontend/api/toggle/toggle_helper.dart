import 'dart:convert';

import 'package:eureka_final_version/frontend/models/constant/genie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ToggleHelper {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static final String toggleAPI = dotenv.env['TOGGLE_API_URL'] ?? '';

  Future<bool> isLiked(Genie genieData) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      final response = await http.get(
        Uri.parse('$toggleAPI/like-check?genieId=${genieData.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        final bool isLiked = responseBody['like'] as bool;
        if (isLiked) {
          return true;
        }
        return false;
      } else {
        throw Exception(
            'Failed to check if Genie is liked: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error checking if Genie is liked: $e");
      return false;
    }
  }

  Future<bool> isSaved(Genie genieData) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$toggleAPI/save-check?genieId=${genieData.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        final bool isSaved = responseBody['saved'] as bool;
        if (isSaved) {
          return true;
        }
        return false;
      } else {
        throw Exception(
            'Failed to check if Genie is saved: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error checking if Genie is saved: $e");
      return false;
    }
  }

  // method to toggle like and dislike

  Future<bool> toogleSave(String genieId, String control) async {
    final token = await _secureStorage.read(key: 'auth_token');
    try {
      final response = await http.post(
        Uri.parse('$toggleAPI/bookmark'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'genieId': genieId,
          'control': control,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to bookmark Genie: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error toggling save: $e");
      return false;
    }
  }

  Future<bool> toogleLike(String genieId, String control) async {
    final token = await _secureStorage.read(key: 'auth_token');
    debugPrint("geniedId: $genieId, control: $control");
    try {
      final response = await http.post(
        Uri.parse('$toggleAPI/like'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'genieId': genieId,
          'control': control,
        }),
      );
      debugPrint("Response: ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to like Genie: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error toggling like: $e");
      return false;
    }
  }
}
