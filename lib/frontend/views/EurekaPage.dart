import 'package:eureka_final_version/frontend/components/GenieCreation.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:flutter/material.dart';

import 'package:eureka_final_version/frontend/components/MyStyle.dart';

class EurekaPage extends StatefulWidget {
  final EurekaUser userData;
  const EurekaPage({super.key, required this.userData});

  @override
  State<EurekaPage> createState() => _EurekaPageState();
}

class _EurekaPageState extends State<EurekaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          "assets/images/slogan-nobackground.png",
          width: 200,
          height: 200,
        ),
      ),
      body: ListView(
        children: [
          PostCardCreation(userData: widget.userData),
        ],
      ),
    );
  }
}
