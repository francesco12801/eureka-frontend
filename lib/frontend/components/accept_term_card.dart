import 'dart:ui';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/components/my_elevated_button.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/models/constant/genie.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AcceptTermsCard extends StatefulWidget {
  final EurekaUser userData;
  final Genie genieData;
  const AcceptTermsCard(
      {super.key, required this.userData, required this.genieData});

  @override
  State<AcceptTermsCard> createState() => _AcceptTermsCardState();
}

class _AcceptTermsCardState extends State<AcceptTermsCard> {
  // Genie Manager
  final genieHelper = GenieHelper();
  late Genie _localGenieData;

  // Manager for the state of the checkboxes
  bool _isTermsAccepted = false;
  bool _isPrivacyAccepted = false;
  bool _isNewsletterSubscribed = false;

  // Loading state
  bool _isLoading = false; // Add this variable

  @override
  void initState() {
    super.initState();
    // Initialize the local genieData copy with the initial data
    _localGenieData = widget.genieData;
  }

  // Genie Creation with loading indicator
  Future<void> _genieCreation() async {
    setState(() {
      _isLoading = true; // Set loading to true when the backend call starts
    });

    try {
      final genieResponse = await genieHelper.createGenie(_localGenieData);
      if (genieResponse.success == true) {
        Navigator.pushNamed(
          context,
          homePageRoute,
          arguments: widget.userData,
        );
        setState(() {
          _localGenieData = genieResponse.genie!;
        });
      } else {
        // Handle error if genie creation fails
        _showErrorDialog();
      }
    } catch (error) {
      // Handle any error that occurs during the backend call
      _showErrorDialog();
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false when the call is done
      });
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while creating the genie.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.back, color: white),
              SizedBox(width: 8),
              Text(
                'Back',
                style: TextStyle(
                  color: white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.topRight,
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Image.asset(
                "assets/images/verified.png",
                width: 200,
                height: 200,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox 1: Example of Terms and Conditions
          Row(
            children: [
              Checkbox(
                checkColor: black, // Color for the check mark
                activeColor:
                    _isTermsAccepted ? greenIOS : red, // Change when checked
                value: _isTermsAccepted,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isTermsAccepted = newValue ?? false;
                  });
                },
              ),
              const Text(
                'I accept the Terms and Conditions',
                style: normalWriteWhite,
              )
            ],
          ),

          // Checkbox 2: Example of Privacy Policy
          Row(
            children: [
              Checkbox(
                checkColor: black, // Color for the check mark
                activeColor:
                    _isPrivacyAccepted ? greenIOS : red, // Change when checked
                value: _isPrivacyAccepted,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isPrivacyAccepted = newValue ?? false;
                  });
                },
              ),
              const Text('I accept the Privacy Policy', style: normalWriteWhite)
            ],
          ),

          // Checkbox 3: Example of Newsletter Subscription
          Row(
            children: [
              Checkbox(
                checkColor: black,
                activeColor: _isNewsletterSubscribed ? greenIOS : red,
                value: _isNewsletterSubscribed,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isNewsletterSubscribed = newValue ?? false;
                  });
                },
              ),
              const Text('I subscribe to the Newsletter',
                  style: normalWriteWhite)
            ],
          ),
          const SizedBox(height: 30),

          // Conditionally display either the button or the loading indicator
          Center(
            child: _isLoading
                ? CircularProgressIndicator() // Show loading indicator when loading
                : MyElevatedButton(
                    text: "Eureka!",
                    isBold: true,
                    isBack: true,
                    onPressed: () {
                      _handleButtonPress(context);
                    },
                  ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _handleButtonPress(BuildContext context) {
    if (_isTermsAccepted && _isPrivacyAccepted && _isNewsletterSubscribed) {
      // All conditions met, proceed with the home page loading version
      _genieCreation();
    } else {
      // Show a pop-up if terms or conditions are not accepted

      showDialog(
        context: context,
        barrierDismissible:
            true, // Allows closing the dialog by tapping outside
        builder: (BuildContext context) {
          return Stack(
            children: [
              // Frosted Glass Effect
              BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
                child: Container(
                  color: Colors.black.withOpacity(
                      0.3), // Darkened background with transparency
                ),
              ),
              Center(
                child: AlertDialog(
                  backgroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  title: const Center(
                    child: Text(
                      "Action Required",
                      style: TextStyle(fontFamily: 'Roboto'),
                    ),
                  ),
                  content: const Text(
                    "Please accept all terms and conditions before proceeding.",
                    style: TextStyle(fontFamily: 'Roboto'),
                  ),
                  actions: <Widget>[
                    Center(
                      child: MyElevatedButton(
                        isBold: true,
                        text: "OK",
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
