import 'dart:convert';
import 'package:eureka_final_version/frontend/api/URLs/urls.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseNotificationManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final String userURL = UrlManager.getUserURL();

  Future<void> initNotification(String uid) async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Get FCM token
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      debugPrint("FCM Token: $fcmToken");

      if (fcmToken != null) {
        // Save the token to the backend

        debugPrint("Saving token to the backend");

        final response = await http.post(
          Uri.parse('$userURL/save-token'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"uid": uid, "fcmToken": fcmToken}),
        );

        debugPrint("Response status code: ${response.body}");

        if (response.statusCode == 200) {
          debugPrint("Token saved successfully");
        } else {
          debugPrint("Error saving token");
        }
      }
      // backend call to save the token
    } catch (e) {
      debugPrint("Error getting token: $e");
    }
  }
}
