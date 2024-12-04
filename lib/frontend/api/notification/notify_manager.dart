import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NotifyManager {
  static final String notifyApi = dotenv.env['NOTIFY_API_URL'] ?? '';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<Map<String, dynamic>> updateFcmToken(String fcmToken) async {
    debugPrint('FCM Token: $fcmToken');
    Map<String, dynamic> response = {};
    try {
      debugPrint('Updating FCM Token');
      final response =
          await http.get(Uri.parse('$notifyApi/updateFcmToken'), headers: {
        'Authorization': 'Bearer $fcmToken',
      });
      if (response.statusCode == 200) {
        return {
          'statusCode': response.statusCode,
          'data': response.body,
        };
      } else {
        return {
          'statusCode': response.statusCode,
          'data': null,
        };
      }
    } catch (e) {
      return response;
    }
  }
}
