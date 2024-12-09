import 'package:eureka_final_version/frontend/models/constant/user.dart';

class SignUpResponse {
  final bool success;
  final EurekaUser? user;

  SignUpResponse({required this.success, this.user});
}
