import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eureka_final_version/frontend/api/URLs/urls.dart';
import 'package:eureka_final_version/frontend/models/responses/genie_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:eureka_final_version/frontend/models/constant/genie.dart';

class GenieHelper {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final String genieURL = UrlManager.getGenieURL();

  Future<int> getLikesCount(Genie genieData) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$genieURL/get-likes?genieId=${genieData.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('likes')) {
          return responseBody['likes'];
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error getting likes count: $e");
      return 0;
    }
  }

  Future<int> getSavedCount(Genie genieData) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$genieURL/get-bookmarks?genieId=${genieData.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('bookmarks')) {
          return responseBody['bookmarks'];
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error getting bookmarks count: $e");
      return 0;
    }
  }

  Future<GenieResponse> createGenie(Genie genieData) async {
    final url = '$genieURL/create';
    final token = await _secureStorage.read(key: 'auth_token');

    try {
      // Creazione della richiesta multipart
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Aggiungi i file delle immagini
      for (final imagePath in genieData.images ?? []) {
        final imageFile = http.MultipartFile.fromBytes(
          'images', // Nome del campo
          await File(imagePath).readAsBytes(),
          filename: imagePath.split('/').last,
        );
        request.files.add(imageFile);
      }

      // Aggiungi i file generici
      for (final filePath in genieData.files ?? []) {
        final file = http.MultipartFile.fromBytes(
          'files', // Nome del campo
          await File(filePath).readAsBytes(),
          filename: filePath.split('/').last,
        );
        request.files.add(file);
      }

      // Aggiungi i dati JSON come parte della richiesta
      request.fields['data'] = jsonEncode(genieData.toMap());

      // Esegui la richiesta
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final geniedData = responseData['genies'];

        debugPrint('My genie data: ${geniedData['id']}');
        debugPrint('Genie created successfully! ID: ${geniedData['id']}');
        genieData = genieData.copyWith(id: geniedData['id']);
        return GenieResponse(success: true, genie: genieData);
      } else {
        throw Exception('Failed to create Genie: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error creating Genie: $error');
      return GenieResponse(success: false);
    }
  }

  Future<List<String>> getImageFromGenie(Genie genieData) async {
    debugPrint("Trying to get images"); // Print the genie ID
    debugPrint("Genie ID: ${genieData.id}"); // Print the genie ID
    final List<String> images = [];
    try {
      // call spring endpoint to get an image passing the id of the genie and token
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$genieURL/get-images-from-genie?genieId=${genieData.id}'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey("images")) {
          final List<dynamic> imagesList = responseBody["images"];
          debugPrint("Images: $imagesList");
          for (var image in imagesList) {
            images.add(image);
          }
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
      return images;
    } catch (e) {
      return images;
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
        return '$daysDifference ${daysDifference == 1 ? "day" : "days"}';
      } else {
        // Otherwise, return hours
        final int hoursDifference = difference.inHours;
        return '$hoursDifference ${hoursDifference == 1 ? "h" : "h"}';
      }
    } catch (e) {
      // Handle parsing errors or invalid dateString
      return 'Invalid date';
    }
  }

  Future<bool> deleteGenie(Genie genieData) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse('$genieURL/delete'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $token",
        },
        body: json.encode(genieData.id),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to delete Genie: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error deleting Genie: $e");
      return false;
    }
  }

  Future<List<String>> getFilesFromGenie(Genie genieData) async {
    final List<String> files = [];
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$genieURL/get-files-from-genie?genieId=${genieData.id}'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey("files")) {
          final List<dynamic> filesList = responseBody["files"];
          for (var file in filesList) {
            files.add(file);
          }
          debugPrint("Files: $files");
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
      return files;
    } catch (e) {
      return files;
    }
  }

  Future<List<Map<String, dynamic>>> getUserGenies() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$genieURL/get-from-user'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey("genies")) {
          final List<dynamic> genies = responseBody["genies"];
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
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPublicUserGenies(String uid) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse('$genieURL/get-public-user-genies'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(uid),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey('genies')) {
          final List<dynamic> genies = responseBody['genies'];
          return genies.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting public user genies: $e');
      return [];
    }
  }

  // get genie by id
  Future<Genie> getGenieById(String genieId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      debugPrint('Getting genie details for ID: $genieId');

      final url = '$genieURL/get?genieId=$genieId';
      debugPrint('Calling URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('genies')) {
          final Map<String, dynamic> genieData = responseBody['genies'];
          return Genie.fromJson(genieData);
        } else {
          debugPrint('Response does not contain genie key: $responseBody');
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting genie by id: $e');
      return Genie(
        id: genieId,
        title: 'Untitled Genie',
        nameSurnameCreator: 'Unknown Creator',
        description: 'No description available',
        target: 'No target available',
      );
    }
  }
}
