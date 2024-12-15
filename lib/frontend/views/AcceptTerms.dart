import 'package:eureka_final_version/frontend/components/AcceptTermCard.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/models/constant/genie.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:flutter/material.dart';

class AcceptTermsPage extends StatefulWidget {
  final Genie geniedata;
  final EurekaUser userData;
  const AcceptTermsPage(
      {super.key, required this.geniedata, required this.userData});

  @override
  State<AcceptTermsPage> createState() => _AcceptTermsPageState();
}

class _AcceptTermsPageState extends State<AcceptTermsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        title: Image.asset(
          "assets/images/slogan-nobackground.png",
          width: 200,
          height: 200,
        ),
      ),
      body: ListView(
        children: [
          AcceptTermsCard(
            userData: widget.userData,
            genieData: widget.geniedata,
          ),
        ],
      ),
    );
  }
}
