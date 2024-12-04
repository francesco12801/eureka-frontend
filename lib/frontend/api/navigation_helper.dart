import 'package:flutter/material.dart';

class NavigationHelper {
  // Navigate without coming back
  static void navigateToPage(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (Route<dynamic> route) => false,
    );
  }
}
