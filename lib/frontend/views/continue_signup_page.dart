import 'dart:math';
import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/components/my_elevated_button.dart';
import 'package:eureka_final_version/frontend/components/my_input_button.dart';
import 'package:eureka_final_version/frontend/components/my_motivational_quotes.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/constants/interest.dart';
import 'package:eureka_final_version/frontend/views/transition_before_landing.dart';
import 'package:flutter/material.dart';

class ContinueSignUp extends StatefulWidget {
  final Map<String, String> userData;

  ContinueSignUp({super.key, required this.userData});

  @override
  _ContinueSignUpState createState() => _ContinueSignUpState();
}

class _ContinueSignUpState extends State<ContinueSignUp> {
  // Auth helper
  final authHelper = AuthHelper();

  // Interests
  List<String> selectedInterests = [];
  Map<String, Color> interestColors = {};
  late final List<List<String>> interests;
  late final List<Color> colors;

  // Controllers
  final TextEditingController professionController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();

  // Focus nodes
  final FocusNode professionFocusNode = FocusNode();
  final FocusNode universityFocusNode = FocusNode();
  final FocusNode purposeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    interests = interest;
    colors = color;
  }

  Function()? goBack(BuildContext context) {
    Navigator.of(context).pop();
    return null;
  }

  Function()? goNext(BuildContext context) {
    final BuildContext currentContext = context;

    authHelper
        .userSignUp(
            widget.userData['nameSurname']!,
            widget.userData['email']!,
            widget.userData['password']!,
            widget.userData['phoneNumber']!,
            widget.userData['address']!,
            universityController.text,
            widget.userData['nationality']!,
            purposeController.text,
            professionController.text,
            selectedInterests)
        .then((signUpResponse) {
      if (signUpResponse.success && currentContext.mounted) {
        // Navigate to the next page, passing the user data
        print(signUpResponse.user);
        Navigator.push(
          currentContext,
          MaterialPageRoute(
            builder: (context) => TransitionBeforeLanding(
              userData: signUpResponse.user!, // Pass the user data
            ),
          ),
        );
      } else if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Signup failed, please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }).catchError((error) {
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Error occurred: ${error.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return null;
  }

  Color getRandomColor() {
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    professionController.dispose();
    universityController.dispose();
    purposeController.dispose();
    professionFocusNode.dispose();
    universityFocusNode.dispose();
    purposeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside the text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 27.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image.asset(
                            "assets/images/logo-nobackground.png",
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(height: 20.0),
                          const MyMotivationalQuotes(
                            quote:
                                "Tell us something about your ambitions. How big would you dream?",
                          ),
                          const SizedBox(height: 20.0),
                          MyInputButton(
                            controller: professionController,
                            placeholder: "What's your profession?",
                            focusNode: professionFocusNode, // Added focus node
                          ),
                          const SizedBox(height: 20.0),
                          MyInputButton(
                            controller: universityController,
                            placeholder: "What's your university?",
                            focusNode: universityFocusNode, // Added focus node
                          ),
                          const SizedBox(height: 20.0),
                          MyInputButton(
                            controller: purposeController,
                            placeholder: "What's your purpose on Eureka?",
                            focusNode: purposeFocusNode, // Added focus node
                          ),
                          const SizedBox(height: 20.0),
                          const MyMotivationalQuotes(
                            quote: "Show us your interests!",
                          ),
                          const SizedBox(height: 20.0),

                          // Horizontal scrolling rows
                          Column(
                            children:
                                List.generate(interests.length, (rowIndex) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: SizedBox(
                                  height: 35,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: interests[rowIndex].length,
                                    itemBuilder: (context, index) {
                                      String interest =
                                          interests[rowIndex][index];

                                      bool isSelected =
                                          selectedInterests.contains(interest);

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (!isSelected) {
                                              selectedInterests.add(interest);
                                              interestColors[interest] =
                                                  getRandomColor();
                                            } else {
                                              selectedInterests
                                                  .remove(interest);
                                              interestColors.remove(interest);
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 6.0),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color: interestColors[interest] ??
                                                Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            interest,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 40.0),

                          const Spacer(),
                          Row(
                            children: <Widget>[
                              MyElevatedButton(
                                text: 'Back',
                                isBack: true,
                                onPressed: () {
                                  goBack(context);
                                },
                              ),
                              const Spacer(),
                              MyElevatedButton(
                                text: 'Eureka!',
                                isBold: true,
                                onPressed: () {
                                  goNext(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
