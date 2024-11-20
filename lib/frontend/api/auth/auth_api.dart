import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:eureka_final_version/frontend/models/login_response.dart';
import 'package:eureka_final_version/frontend/models/logout_response.dart';
import 'package:eureka_final_version/frontend/models/signup_response.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// // const urlSpring = 'http://localhost:8080/api/auth';
// const urlSpring = 'http://192.168.1.235:8080/api/auth';
// // const middleware = 'http://localhost:8070';
// const middleware = 'http://192.168.1.235:8070';

class AuthHelper {
  static final String urlSpring = dotenv.env['SPRING_API_URL'] ?? '';
  static final String middleware = dotenv.env['MIDDLEWARE_API_URL'] ?? '';
  // Check if the token is valid
  Future<bool> checkToken(String token) async {
    try {
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
      debugPrint('Error checking token: $e');
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
    // const url = 'http://localhost:8070/signup';
    final url = '$middleware/signup';

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
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(signupData),
      );

      if (response.statusCode == 200) {
        // Parse the response body to extract the uid
        final Map<String, dynamic> responseMap = json.decode(response.body);
        final EurekaUser newUserEureka = EurekaUser.fromMap(responseMap);

        debugPrint(newUserEureka.toString());

        // Return success response with the new user
        return SignUpResponse(success: true, user: newUserEureka);
      } else {
        debugPrint('Error signup: ${response.statusCode} - ${response.body}');
        return SignUpResponse(success: false);
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return SignUpResponse(success: false);
    }
  }

  Future<LoginResponse> userLogin(String emailControllerText,
      String passwordControllerText, bool errorMessage) async {
    // const url = 'http://localhost:8070/login';

    final url = '$middleware/login';

    // 192.168.1.235

    final Map<String, String> signupData = {
      'email': emailControllerText,
      'password': passwordControllerText,
    };

    try {
      // Call the backend
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(signupData),
      );

      if (response.statusCode == 200) {
        debugPrint('Login done!');

        // Parse the response body and create a local EurekaUser instance

        final Map<String, dynamic> userDataResponse =
            json.decode(response.body);
        final EurekaUser userData =
            EurekaUser.fromMap(userDataResponse['user']);
        final String token = userDataResponse['token'];

        // Receiving from the backend

        debugPrint('Token: $token');

        // Put token in the secure storage
        const storage = FlutterSecureStorage();
        await storage.write(key: 'auth_token', value: token);

        errorMessage = false;

        return LoginResponse(success: true, user: userData);
      } else {
        errorMessage = true;

        debugPrint('Error Login: ${response.statusCode}');
        return LoginResponse(success: false);
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return LoginResponse(success: false);
    }
  }

  Future<LogoutResponse> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$middleware/signout'), // Replace with your actual logout service URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      final Map<String, dynamic> checkResponse = json.decode(response.body);
      final int statusCode = checkResponse['statusCode'];
      if (statusCode == 200) {
        // If logout is successful, clear local resources

        return LogoutResponse(success: true);
      } else {
        debugPrint('Failed to log out: ${response.body}');
        return LogoutResponse(success: false);
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      return LogoutResponse(success: false);
    }
  }
}
