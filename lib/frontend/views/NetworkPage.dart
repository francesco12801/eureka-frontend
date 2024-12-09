import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/navigation_helper.dart';
import 'package:eureka_final_version/frontend/components/my_navigation_bar.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NetworkPage extends StatefulWidget {
  final EurekaUser userData;
  const NetworkPage({super.key, required this.userData});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final AuthHelper authHelper = AuthHelper();
  final _secureStorage = const FlutterSecureStorage();

  void onTap(int index) async {
    String? token = await _secureStorage.read(key: 'auth_token');

    if (token == null) {
      // Handle token not found
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Token Not Found'),
          content: const Text('Token not found. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  loginRoute,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    bool isVerified = await authHelper.checkToken();

    if (isVerified) {
      switch (index) {
        case 0:
          Navigator.pushNamed(
            context,
            homePageRoute,
            arguments: widget.userData,
          );
          break;
        case 1:
          Navigator.pushNamed(
            context,
            notificationPageRoute,
            arguments: widget.userData,
          );
          break;
        case 2:
          Navigator.pushNamed(
            context,
            eurekaRoute,
            arguments: widget.userData,
          );
          break;
        case 3:
          Navigator.pushNamed(
            context,
            networkRoute,
            arguments: widget.userData,
          );
          break;
        case 4:
          Navigator.pushNamed(
            context,
            profileRoute,
            arguments: widget.userData,
          );
          break;
        default:
          Navigator.pushNamed(
            context,
            networkRoute,
            arguments: widget.userData,
          );
      }
    } else {
      // Handle token verification failure
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Verification Failed'),
          content:
              const Text('Token verification failed. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                NavigationHelper.navigateToPage(context, const LoginPage());
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: primaryColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Collaboration',
                      style: TextStyle(
                        color: white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: filterUnreadIcon,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          onTap(index);
        },
      ),
    );
  }
}
