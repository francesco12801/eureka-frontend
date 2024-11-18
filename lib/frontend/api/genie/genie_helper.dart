import 'dart:async';
import 'dart:convert';
import 'package:eureka_final_version/frontend/models/genie_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:eureka_final_version/frontend/models/genie.dart';

class GenieHelper {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const genieAPI = 'http://localhost:8080/api/genie';

  Future<GenieResponse> createGenie(Genie genieData) async {
    const url = '$genieAPI/create';

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
    DateTime date = DateTime.parse(dateString);

    DateTime now = DateTime.now();

    Duration difference = now.difference(date);

    // Convert the duration to hours
    int hours = difference.inHours;

    // Return the formatted string
    return '${hours.abs()}H';
  }

  // Change this funcion to Spring boot backend

//   Future<List<Map<String, dynamic>>> getUserGenies() async {
//     const url = '$genieAPI/get-from-user';
//     try {
//       // Send the GET request to the backend and attach the token to the header
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       // attach the token to the header
//       final Map<String, dynamic> responseData = jsonDecode(response.body);
//       final geniedData = responseData['genies'];

//       debugPrint('My genie data: $geniedData');

//       // Check if the request was successful
//       if (response.statusCode == 200) {
//         // Parse the response body into a Map
//         final Map<String, dynamic> responseData = jsonDecode(response.body);
//         final geniedData = responseData['genies'];

//         debugPrint('My genie data: $geniedData');

//         // Extract the genies list from the response
//         final List<Map<String, dynamic>> genies =
//             List<Map<String, dynamic>>.from(responseData['genies']);

//         return genies;
//       } else {
//         // If the request failed, throw an exception with the error message
//         throw Exception(
//             'Failed to load genies. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       // If there was an error, print it and rethrow the exception
//       debugPrint('Error fetching genies: $e');
//       throw Exception('Error fetching genies: $e');
//     }
//   }
// }
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
