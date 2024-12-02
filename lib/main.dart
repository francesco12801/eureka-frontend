import 'package:eureka_final_version/frontend/models/genie.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:eureka_final_version/frontend/views/accept_terms.dart';
import 'package:eureka_final_version/frontend/views/edit_profile_page.dart';
import 'package:eureka_final_version/frontend/views/eureka_page.dart';
import 'package:eureka_final_version/frontend/views/network_page.dart';
import 'package:eureka_final_version/frontend/views/notification.dart';
import 'package:eureka_final_version/frontend/views/profile_page.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/views/continue_signup_page.dart';
import 'package:eureka_final_version/frontend/views/home_page.dart';
import 'package:eureka_final_version/frontend/views/login_page.dart';
import 'package:eureka_final_version/frontend/views/preview_loading.dart';
import 'package:eureka_final_version/frontend/views/signup_page.dart';
import 'package:eureka_final_version/frontend/views/transition_before_landing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LoadingPage(),
      routes: {
        loginRoute: (context) => const LoginPage(),
        homePageRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUser;
          return HomePage(userData: userData);
        },
        notificationPageRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUser;
          return NotificationPage(userData: userData);
        },
        registerRoute: (context) => const SignUp(),
        transitionBeforeLandinRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUser;
          return TransitionBeforeLanding(userData: userData);
        },
        continueSignuRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return ContinueSignUp(userData: userData);
        },
        previewLoadRoute: (context) => const LoadingPage(),
        eurekaRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUser;
          return EurekaPage(userData: userData);
        },
        acceptTermsRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUser;
          final genieData = ModalRoute.of(context)!.settings.arguments as Genie;
          return AcceptTermsPage(geniedata: genieData, userData: userData);
        },
        networkRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUser;
          return NetworkPage(userData: userData);
        },
        profileRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUser;
          return ProfilePage(userData: userData);
        },
        profileEditRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUser;
          return EditProfile(userData: userData);
        }
      },
    );
  }
}
