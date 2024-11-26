import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/components/my_elevated_button.dart';
import 'package:eureka_final_version/frontend/components/my_motivational_quotes.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingPage extends StatefulWidget {
  final EurekaUser userData;
  const SettingPage({super.key, required this.userData});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isLoggingOut = false;

  // Function to fetch UID from the email
  final authHelper = AuthHelper();

  // Storage

  final _secureStorage = const FlutterSecureStorage();

  Future<void> _clearLocalResources() async {
    setState(() {
      widget.userData.clearUser();
    });
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });
    final token = await _secureStorage.read(key: 'auth_token');
    final response = await authHelper.logout(token!);

    if (response.success) {
      await _clearLocalResources();
      // Navigate to the login page
      Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
    } else {
      setState(() {
        _isLoggingOut = false;
      });
      // Handle error (e.g., show error message to the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const MyMotivationalQuotes(
          quote: "Settings",
        ),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: _isLoggingOut
            ? const CircularProgressIndicator() // Show loading while logging out
            : MyElevatedButton(
                text: "Logout",
                isBack: true,
                onPressed: _handleLogout, // Trigger logout process
              ),
      ),
    );
  }
}
