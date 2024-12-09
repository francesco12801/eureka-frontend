import 'package:eureka_final_version/frontend/api/notification/firebase_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:eureka_final_version/frontend/models/responses/login_response.dart';
import 'package:eureka_final_version/frontend/models/responses/logout_response.dart';
import 'package:eureka_final_version/frontend/models/responses/signup_response.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';

import 'package:http/http.dart' as http;

class AuthHelper {
  static final String urlSpring = dotenv.env['SPRING_API_AUTH'] ?? '';
  static final String middleware = dotenv.env['MIDDLEWARE_API_URL'] ?? '';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  // Check if the token is valid
  Future<bool> checkToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response =
          await http.get(Uri.parse('$urlSpring/verify-token'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      final Map<String, dynamic> checkResponse = json.decode(response.body);
      final int statusCode = checkResponse['statusCode'];
      if (statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<SignUpResponse> userSignUp(
      String nameSurname,
      String email,
      String password,
      String phoneNumber,
      String address,
      String university,
      String nationality,
      String purpose,
      String profession,
      List<String> interests) async {
    // Data to be sent to the backend without the uid
    final Map<String, dynamic> signupData = {
      'nameSurname': nameSurname,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'nationality': nationality,
      'profession': profession,
      'interests': interests,
      'university': university,
      'purpose': purpose,
    };

    try {
      // Call the backend to sign up the user
      final response = await http.post(
        Uri.parse('$middleware/signup'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(signupData),
      );

      if (response.statusCode == 200) {
        // Parse the response body to extract the uid
        final Map<String, dynamic> responseMap = json.decode(response.body);
        // Get token from the response
        final String token = responseMap['token'];
        // Put token in the secure storage
        const storage = FlutterSecureStorage();
        await storage.write(key: 'auth_token', value: token);

        final EurekaUser newUserEureka = EurekaUser.fromMap(responseMap);

        // Return success response with the new user
        return SignUpResponse(success: true, user: newUserEureka);
      } else {
        return SignUpResponse(success: false);
      }
    } catch (e) {
      return SignUpResponse(success: false);
    }
  }

  Future<LoginResponse> userLogin(String emailControllerText,
      String passwordControllerText, bool errorMessage) async {
    final Map<String, String> signupData = {
      'email': emailControllerText,
      'password': passwordControllerText,
    };

    try {
      // Call the backend
      final response = await http.post(
        Uri.parse('$middleware/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(signupData),
      );

      if (response.statusCode == 200) {
        // Parse the response body and create a local EurekaUser instance

        final Map<String, dynamic> userDataResponse =
            json.decode(response.body);
        final EurekaUser userData =
            EurekaUser.fromMap(userDataResponse['user']);

        // get uid from the response

        final String uid = userData.uid;

        // Initialize the notification manager
        await FirebaseNotificationManager().initNotification(uid);
        final String token = userDataResponse['token'];

        // Put token in the secure storage
        const storage = FlutterSecureStorage();
        await storage.write(key: 'auth_token', value: token);

        errorMessage = false;

        return LoginResponse(success: true, user: userData);
      } else {
        errorMessage = true;

        return LoginResponse(success: false);
      }
    } catch (e) {
      return LoginResponse(success: false);
    }
  }

  Future<LogoutResponse> logout() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('$urlSpring/logout'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        const storage = FlutterSecureStorage();
        await storage.delete(key: 'auth_token');
        return LogoutResponse(success: true);
      } else {
        return LogoutResponse(success: false);
      }
    } catch (e) {
      return LogoutResponse(success: false);
    }
  }
}
