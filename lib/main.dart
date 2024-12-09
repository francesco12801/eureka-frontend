import 'package:eureka_final_version/firebase_options.dart';
import 'package:eureka_final_version/frontend/components/GeniePublicFullView.dart';
import 'package:eureka_final_version/frontend/models/constant/genie.dart';
import 'package:eureka_final_version/frontend/models/constant/profile_preview.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/AcceptTerms.dart';
import 'package:eureka_final_version/frontend/views/EditProfile.dart';
import 'package:eureka_final_version/frontend/views/EurekaPage.dart';
import 'package:eureka_final_version/frontend/views/FollowerListPage.dart';
import 'package:eureka_final_version/frontend/views/NetworkPage.dart';
import 'package:eureka_final_version/frontend/views/NotificationPage.dart';
import 'package:eureka_final_version/frontend/views/ProfilePage.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/views/ContinueSignUp.dart';
import 'package:eureka_final_version/frontend/views/HomePage.dart';
import 'package:eureka_final_version/frontend/views/LoginPage.dart';
import 'package:eureka_final_version/frontend/views/PreviewLoading.dart';
import 'package:eureka_final_version/frontend/views/PublicProfile.dart';
import 'package:eureka_final_version/frontend/views/SignupPage.dart';
import 'package:eureka_final_version/frontend/views/TransitionBeforeLanding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    await dotenv.load(fileName: ".env");
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Error loading init resources: $e");
  }
  runApp(const EurekaApp());
}

class EurekaApp extends StatelessWidget {
  const EurekaApp({super.key});

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
        },
        publicProfileRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUserPublic;
          return PublicProfilePage(userData: userData);
        },
        followerListRoute: (context) {
          final userData =
              ModalRoute.of(context)!.settings.arguments as EurekaUser;
          final isFollowers =
              ModalRoute.of(context)!.settings.arguments as bool;
          final currentUserId =
              ModalRoute.of(context)!.settings.arguments as String;
          return FollowersPage(
              userId: userData.uid,
              isFollowers: isFollowers,
              currentUserId: currentUserId);
        },
      },
    );
  }
}
