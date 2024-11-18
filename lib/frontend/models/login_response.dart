import 'package:eureka_final_version/frontend/models/user.dart';

class LoginResponse {
  final bool success;
  final EurekaUser? user;

  LoginResponse({required this.success, this.user});
}
