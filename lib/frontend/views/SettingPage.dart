import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/components/MyElevatedButton.dart';
import 'package:eureka_final_version/frontend/components/MyMotivationalQuotes.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:flutter/material.dart';

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

  Future<void> _clearLocalResources() async {
    setState(() {
      widget.userData.clearUser();
    });
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });
    final response = await authHelper.logout();

    if (response.success) {
      await _clearLocalResources();
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
