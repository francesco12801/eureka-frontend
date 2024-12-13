import 'dart:convert';

import 'package:eureka_final_version/frontend/api/URLs/urls.dart';
import 'package:eureka_final_version/frontend/models/constant/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NotifyManager {
  static final String notificationURL = UrlManager.getNotifyURL();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<Map<String, dynamic>> updateFcmToken(String fcmToken) async {
    debugPrint('FCM Token: $fcmToken');
    Map<String, dynamic> response = {};
    try {
      debugPrint('Updating FCM Token');
      final response = await http
          .get(Uri.parse('$notificationURL/updateFcmToken'), headers: {
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

  Future<List<NotificationEureka>> getUserNotifications(String userId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      debugPrint('Fetching notifications for user $userId');

      final response = await http.get(
        Uri.parse('$notificationURL/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        debugPrint('Notifications: $jsonResponse');
        List<dynamic> notificationsJson = jsonResponse['notifications'];
        debugPrint('Notifications JSON: $notificationsJson');
        return notificationsJson
            .map((json) => NotificationEureka.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<Map<String, dynamic>> markAsRead(
      NotificationEureka notification, String uid) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      debugPrint('Marking notification ${notification.id} as read');

      final response = await http.put(
        Uri.parse('$notificationURL/user/$uid/read/${notification.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

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
      return {
        'statusCode': 500,
        'data': e.toString(),
      };
    }
  }

  Future<bool> markAllAsRead(String userId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      debugPrint('Marking all notifications as read');

      final response = await http.put(
        Uri.parse('$notificationURL/user/$userId//read-all"'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId, String userId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      final response = await http.delete(
        Uri.parse('$notificationURL/user/$userId/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
