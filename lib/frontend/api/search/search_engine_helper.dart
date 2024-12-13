import 'dart:convert';
import 'package:eureka_final_version/frontend/api/URLs/urls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SearchEngineHelper {
  static final String searchURL = UrlManager.getSearchURL();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<Map<String, dynamic>> search(
      String query, String type, String? category) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      debugPrint(encodedQuery);
      final encodedType = Uri.encodeComponent(type);
      debugPrint(encodedType);
      final encodedCategory = Uri.encodeComponent(category!);
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
          Uri.parse(
              '$searchURL/perform?query=$encodedQuery&type=$encodedType&category=$encodedCategory'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          });

      if (response.statusCode == 200) {
        return {
          'statusCode': response.statusCode,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'statusCode': response.statusCode,
          'data': null,
        };
      }
    } catch (e) {
      return {
        'statusCode': 500,
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> getGenieDetails(String genieId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http
          .get(Uri.parse('$searchURL/genie-details/$genieId'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load genie details');
      }
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getProfileDetails(String userId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http
          .get(Uri.parse('$searchURL/genie-details/$userId'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      return {};
    }
  }
}
