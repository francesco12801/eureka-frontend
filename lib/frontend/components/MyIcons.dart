import 'package:flutter/material.dart';

class MyFbIcon extends StatelessWidget {
  final Function()? onPressed;

  const MyFbIcon({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // Use the appropriate icons
      icon: Image.asset('assets/images/facebook.png', height: 50, width: 50),
      onPressed: onPressed, // Handle Facebook sign in
    );
  }
}

class MyAppleIcon extends StatelessWidget {
  final Function()? onPressed;
  const MyAppleIcon({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/apple-logo.png', height: 50, width: 50),
      onPressed: onPressed,
    );
  }
}

class MyInstaIcon extends StatelessWidget {
  final Function()? onPressed;
  const MyInstaIcon({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/instagram.png', height: 50, width: 50),
      onPressed: onPressed,
    );
  }
}

class MyXIcon extends StatelessWidget {
  final Function()? onPressed;
  const MyXIcon({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/twitter.png', height: 50, width: 50),
      onPressed: onPressed,
    );
  }
}

class MyGoogleIcon extends StatelessWidget {
  final Function()? onPressed;

  const MyGoogleIcon({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset('assets/images/google.png', height: 50, width: 50),
      onPressed: onPressed, // Handle Google sign in
    );
  }
}
