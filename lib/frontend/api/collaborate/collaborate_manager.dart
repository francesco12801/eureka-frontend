import 'dart:convert';

import 'package:eureka_final_version/frontend/api/URLs/urls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

class CollaborateService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String routeCollab = UrlManager.getCollabURL();

  Future<void> sendCollab(String receiverId, String genieId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      debugPrint('"Receiver, genie: $receiverId, $genieId');
      final Map<String, dynamic> collaborationData = {
        'receiverId': receiverId,
        'genieId': genieId
      };

      final response = await http.post(
        Uri.parse('$routeCollab/sendCollabRequest'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(collaborationData),
      );
      if (response.statusCode == 200) {
        debugPrint('Collab created');
      } else {
        debugPrint('Error creating collab');
      }
    } catch (e) {
      debugPrint("Error creating collab: $e");
    }
  }

  Future<void> acceptCollab(String collaborationId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      debugPrint('Collab id: $collaborationId');
      final Map<String, String> requestBody = {
        'collaborationId': collaborationId
      };
      final response = await http.post(
        Uri.parse('$routeCollab/accept'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        debugPrint("my response: ${response.body}");
        debugPrint('Collab accepted');
      } else {
        debugPrint('Error accepting collab');
      }
    } catch (e) {
      debugPrint("Error accepting collab: $e");
    }
  }

  Future<void> declineCollab(String collaborationId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      debugPrint('Collab id: $collaborationId');
      final Map<String, String> requestBody = {
        'collaborationId': collaborationId
      };
      final response = await http.post(
        Uri.parse('$routeCollab/decline'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        debugPrint('Collab declined');
      } else {
        debugPrint('Error declining collab');
      }
    } catch (e) {
      debugPrint("Error declining collab: $e");
    }
  }

  Future<bool> checkExistingCollab(
      String senderId, String receiverId, String genieId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        debugPrint('No token found');
        return false;
      }

      final response = await http.post(
        Uri.parse('$routeCollab/checkExistingCollab'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'genieId': genieId
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint("Collab check: ${data['check']}");
        return data['check'] == "true";
      } else {
        debugPrint('Error checking collab: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint("Error checking collab: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getCollaborationClusterizedByGenie() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$routeCollab/user-collaborations'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('Collab clusterized by genie: $data');
        return data;
      } else {
        debugPrint(
            'Error getting collab clusterized by genie: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint("Error getting collab clusterized by genie: $e");
      return {};
    }
  }
}
