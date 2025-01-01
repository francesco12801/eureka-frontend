import 'dart:convert';
import 'package:eureka_final_version/frontend/api/URLs/urls.dart';
import 'package:eureka_final_version/frontend/models/constant/CalendarEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MeetingManager {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final String _meetingURL = UrlManager.getMeetingURL();

  static Future<List<Meeting>> getMeetings() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse(_meetingURL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> meetingsJson = json.decode(response.body);
        return meetingsJson.map((json) => Meeting.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error getting meetings: $e');
      return [];
    }
  }

  static Future<Meeting> createMeeting(
      String guestId,
      String infos,
      String time,
      String day,
      String title,
      List<String> collaborators,
      String genieId,
      String collaborationId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      debugPrint('Sending request with body: ${json.encode({
            'guestId': guestId,
            'infos': infos,
            'time': time,
            'day': day,
            'title': title,
            'collaborators': collaborators,
            'genieId': genieId
          })}');

      final response = await http.post(
        Uri.parse('$_meetingURL/create-meeting'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'guestId': guestId,
          'infos': infos,
          'time': time,
          'day': day,
          'title': title,
          'collaborators': collaborators,
          'genieId': genieId
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Server response: ${response.body}');
        debugPrint('Status code: ${response.statusCode}');
        throw Exception('Error creating meeting: ${response.body}');
      }

      final responseJson = json.decode(response.body);

      // Verifica che la risposta sia di successo
      if (responseJson['status'] != 'success') {
        throw Exception(
            'Error creating meeting: ${responseJson['message'] ?? 'Unknown error'}');
      }

      // Estrai il meeting dalla risposta
      final meetingJson = responseJson['meeting'];
      if (meetingJson == null) {
        throw Exception('Meeting data is missing from response');
      }

      debugPrint('Meeting JSON: $meetingJson');
      return Meeting.fromJson(meetingJson);
    } catch (e, stackTrace) {
      debugPrint('Error creating meeting: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> updateMeeting(Meeting meeting) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      final response = await http.put(
        Uri.parse('$_meetingURL/edit-meeting'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(meeting.toJson()),
      );

      if (response.statusCode != 200) throw Exception('Error updating meeting');
    } catch (e) {
      debugPrint('Error updating meeting: $e');
    }
  }

  static Future<void> deleteMeeting(Meeting meeting) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.delete(
        Uri.parse('$_meetingURL/delete-meeting'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(meeting.toJson()),
      );
      if (response.statusCode != 200) throw Exception('Error deleting meeting');
    } catch (e) {
      debugPrint('Error deleting meeting: $e');
    }
  }
}
