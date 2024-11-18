import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UserHelper {
  // URLs for the spring server and node server
  static const String springURL = 'http://localhost:8080/api/user';
  static const String nodeURL = 'https://localhost:8070/login';
  static const String imageEndpoint = 'http://localhost:8080/api/edit-profile';

  // Instance of FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> getProfileImage() async {
    // Make a get request to the spring server to get profile image of the user
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response =
          await http.post(Uri.parse('$springURL/getProfileImage'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      final Map<String, dynamic> imageResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final String? profileImage = imageResponse['profileImage'];
        debugPrint(
            'profile image MANNAGGGGGGAGGAAYHDBHBHUDSAHBDSA: $profileImage');
        return profileImage;
      } else {
        return 'Error fetching profile image';
      }
    } catch (e) {
      return 'Error fetching profile image: $e';
    }
  }

  Future<String?> getBannerImage() async {
    // Make a get request to the spring server to get profile name of the user
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.post(Uri.parse('$springURL/getBannerImage'),
          headers: {'Authorization': 'Bearer $token'});

      final Map<String, dynamic> imageResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final String? bannerImage = imageResponse['bannerImage'];

        debugPrint("printing respone: $bannerImage");
        return bannerImage;
      } else {
        return 'Error fetching banner image';
      }
    } catch (e) {
      return 'Error fetching banner image: $e';
    }
  }

  Future<String> getEmail() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.post(Uri.parse('$springURL/get-email'),
          headers: {'Authorization': 'Bearer $token'});

      final Map<String, dynamic> emailResponse = json.decode(response.body);
      final int statusCode = emailResponse['statusCode'];
      final String email = emailResponse['email'];
      debugPrint('email: $email');
      if (statusCode == 200) {
        return email;
      } else {
        return 'Error fetching email';
      }
    } catch (e) {
      return 'Error fetching email: $e';
    }
  }

  Future<String> getAddress() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.post(Uri.parse('$springURL/get-address'),
          headers: {'Authorization': 'Bearer $token'});

      final Map<String, dynamic> addressResponse = json.decode(response.body);
      final int statusCode = addressResponse['statusCode'];
      final String address = addressResponse['address'];
      debugPrint('address: $address');
      if (statusCode == 200) {
        return address;
      } else {
        return 'Error fetching address';
      }
    } catch (e) {
      return 'Error fetching address: $e';
    }
  }

  // I need some method since the file can be nullable
  // Change profile image

  Future<Map<String, String>> changeProfileImage(XFile? imageProfile) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      debugPrint('Token: $token');
      final request = http.MultipartRequest(
          'POST', Uri.parse('$imageEndpoint/changeProfileImage'));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';
      if (imageProfile != null) {
        final profileImage = await http.MultipartFile.fromPath(
            'profileImage', imageProfile.path);
        request.files.add(profileImage);
      }
      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      final Map<String, dynamic> imageResponse = json.decode(responseBody);

      final String profileImageReturn = imageResponse['profileImage'];

      if (response.statusCode == 200) {
        debugPrint('Profile image changed successfully');
        return {
          'profileImage': profileImageReturn,
        };
      } else {
        debugPrint('Error changing profile image: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('Error changing profile image: $e');
      return {};
    }
  }

  // Change banner image

  Future<Map<String, String>> changeBannerImage(XFile? imageBanner) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      debugPrint('Token: $token');
      final request = http.MultipartRequest(
          'POST', Uri.parse('$imageEndpoint/changeBannerImage'));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });
      debugPrint('Authorization Header: ${request.headers['Authorization']}');

      if (imageBanner != null) {
        final bannerImage =
            await http.MultipartFile.fromPath('bannerImage', imageBanner.path);
        request.files.add(bannerImage);
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> imageResponse = json.decode(responseBody);
      debugPrint('Response Body: $responseBody');

      final String bannerImageReturn = imageResponse['bannerImage'];

      if (response.statusCode == 200) {
        debugPrint('Banner image changed successfully');
        return {
          'bannerImage': bannerImageReturn,
        };
      } else {
        debugPrint('Error changing banner image: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('Error changing banner image: $e');
      return {};
    }
  }

  // Change both profile and banner images

  Future<Map<String, String>> uploadImages(
      XFile? profileImage, XFile? bannerImage) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      // Create a multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('$imageEndpoint/uploadImages'));
      debugPrint('Token: $token');
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add profile image file
      var profileImageRequest =
          await http.MultipartFile.fromPath('profileImage', profileImage!.path);
      request.files.add(profileImageRequest);

      // Add banner image file
      var bannerImageRequest =
          await http.MultipartFile.fromPath('bannerImage', bannerImage!.path);
      request.files.add(bannerImageRequest);

      debugPrint("Okay just before sending the request");

      // Send the request
      var response = await request.send();

      // Convert the streamed response body to a string
      final responseString = await response.stream.bytesToString();

      // Decode the response string into a Map
      final Map<String, dynamic> imageResponse = json.decode(responseString);

      // Access the profileImage and bannerImage URLs
      final String profileImageReturn = imageResponse['profileImage'];
      final String bannerImageReturn = imageResponse['bannerImage'];

      debugPrint("Profile Image URL: $profileImageReturn");
      debugPrint("Banner Image URL: $bannerImageReturn");

      // Check the response status code
      if (response.statusCode == 200) {
        debugPrint('Images uploaded successfully');
        // Return a map containing the URLs
        return {
          'profileImage': profileImageReturn,
          'bannerImage': bannerImageReturn,
        };
      } else {
        debugPrint('Error uploading images: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('Error uploading images: $e');
      return {};
    }
  }
}
