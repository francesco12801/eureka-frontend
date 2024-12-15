import 'dart:ui';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/components/MyElevatedButton.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
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

class _AcceptTermsCardState extends State<AcceptTermsCard>
    with SingleTickerProviderStateMixin {
  // Genie Manager
  final genieHelper = GenieHelper();
  late Genie _localGenieData;

  // Manager for the state of the checkboxes
  bool _isTermsAccepted = false;
  bool _isPrivacyAccepted = false;
  bool _isNewsletterSubscribed = false;

  // Loading state
  bool _isLoading = false; // Add this variable

  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
    _localGenieData = widget.genieData;
  }

  Widget _buildCheckboxItem({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, double animValue, child) {
        // rinominato per evitare conflitti
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value ? greenIOS.withOpacity(0.3) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    checkColor: black,
                    activeColor: value ? greenIOS : red,
                    value: value,
                    onChanged: onChanged,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                title: Text(
                  text,
                  style: const TextStyle(
                    color: white,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 13,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 0.2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context),
                              const SizedBox(height: 10),
                              _buildContent(),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
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
        const SizedBox(height: 24),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + (0.5 * value),
              child: Opacity(
                opacity: value,
                child: Center(
                  child: Image.asset(
                    "assets/images/verified.png",
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCheckboxItem(
            value: _isTermsAccepted,
            onChanged: (value) =>
                setState(() => _isTermsAccepted = value ?? false),
            text: 'I accept the Terms and Conditions',
            index: 0,
          ),
          _buildCheckboxItem(
            value: _isPrivacyAccepted,
            onChanged: (value) =>
                setState(() => _isPrivacyAccepted = value ?? false),
            text: 'I accept the Privacy Policy',
            index: 1,
          ),
          _buildCheckboxItem(
            value: _isNewsletterSubscribed,
            onChanged: (value) =>
                setState(() => _isNewsletterSubscribed = value ?? false),
            text: 'I subscribe to the Newsletter',
            index: 2,
          ),
          const SizedBox(height: 40),
          Center(
            child: _isLoading
                ? TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(greenIOS),
                        ),
                      );
                    },
                  )
                : TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: MyElevatedButton(
                            text: "Eureka!",
                            isBold: true,
                            isBack: true,
                            onPressed: () => _handleButtonPress(context),
                          ),
                        ),
                      );
                    },
                  ),
          ),
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
