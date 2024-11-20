import 'dart:async';
import 'dart:convert';
import 'package:eureka_final_version/frontend/models/genie_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:eureka_final_version/frontend/models/genie.dart';

class GenieHelper {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static final String genieAPI = dotenv.env['GENIE_API_AUTH'] ?? '';

  Future<GenieResponse> createGenie(Genie genieData) async {
    final url = '$genieAPI/create';

    final token = await _secureStorage.read(key: 'auth_token');
    try {
      // Convert the Genie object to JSON
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(genieData.toMap()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final geniedData = responseData['genies'];

        debugPrint('My genie data: ${geniedData['id']}');
        debugPrint(
            'Genie created successfully! ID: ${responseData['genieID']}');
        genieData = genieData.copyWith(id: responseData['genieID']);
        return GenieResponse(success: true, genie: genieData);
      } else {
        throw Exception('Failed to create Genie: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error creating Genie: $error');
      return GenieResponse(success: false);
    }
  }

  String formatDate(String dateString) {
    try {
      // Parse the dateString to an integer (timestamp in milliseconds)
      final int timestamp = int.parse(dateString);

      // Convert timestamp to DateTime
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // Get the current time
      final DateTime now = DateTime.now();

      // Calculate the difference
      final Duration difference = now.difference(date);

      // If the difference is more than 24 hours, return days
      if (difference.inHours >= 24) {
        final int daysDifference = difference.inDays; // Days difference
        return '$daysDifference ${daysDifference == 1 ? "day" : "days"} ago';
      } else {
        // Otherwise, return hours
        final int hoursDifference = difference.inHours;
        return '$hoursDifference ${hoursDifference == 1 ? "hour" : "hours"} ago';
      }
    } catch (e) {
      // Handle parsing errors or invalid dateString
      return 'Invalid date';
    }
  }

  Future<List<Map<String, dynamic>>> getUserGenies() async {
    try {
      // Invia una richiesta GET al server con il token nell'header di autorizzazione
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$genieAPI/get-from-user'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // Analizza il corpo della risposta
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // Verifica se la chiave GENIE_COLLECTION esiste
        if (responseBody.containsKey("genies")) {
          final List<dynamic> genies = responseBody["genies"];
          // Restituisci i dati come lista di mappe
          return genies.cast<Map<String, dynamic>>();
        } else {
          throw Exception("Formato della risposta non valido");
        }
      } else if (response.statusCode == 401) {
        throw Exception("Token non valido");
      } else {
        throw Exception("Errore server: ${response.statusCode}");
      }
    } catch (e) {
      print("Errore durante il recupero dei genies: $e");
      return []; // Restituisci una lista vuota in caso di errore
    }
  }
}
