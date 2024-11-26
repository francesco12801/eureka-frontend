import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:eureka_final_version/frontend/models/login_response.dart';
import 'package:eureka_final_version/frontend/models/logout_response.dart';
import 'package:eureka_final_version/frontend/models/signup_response.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:http/http.dart' as http;

class AuthHelper {
  static final String urlSpring = dotenv.env['SPRING_API_AUTH'] ?? '';
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
        // Parse the response body and create a local EurekaUser instance

        final Map<String, dynamic> userDataResponse =
            json.decode(response.body);
        final EurekaUser userData =
            EurekaUser.fromMap(userDataResponse['user']);
        final String token = userDataResponse['token'];

        // Receiving from the backend

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
        return LogoutResponse(success: false);
      }
    } catch (e) {
      return LogoutResponse(success: false);
    }
  }
}
