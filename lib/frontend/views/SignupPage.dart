import 'package:eureka_final_version/frontend/components/my_elevated_button.dart';
import 'package:eureka_final_version/frontend/components/my_input_button.dart';
import 'package:eureka_final_version/frontend/components/my_motivational_quotes.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/views/ContinueSignUp.dart';
import 'package:flutter/material.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // controller
  final controllerNameSurname = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerPhoneNumber = TextEditingController();
  final controllerAddress = TextEditingController();
  final controllerNationality = TextEditingController();

  // focus nodes
  final FocusNode _focusNodeNameSurname = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePhoneNumber = FocusNode();
  final FocusNode _focusNodeAddress = FocusNode();
  final FocusNode _focusNodeNationality = FocusNode();
  bool auth = false;

  // methods
  // Handling authentication

  Map<String, String> getUserData() {
    // Data to be sent to the backend
    final Map<String, String> userData = {
      'nameSurname': controllerNameSurname.text,
      'email': controllerEmail.text,
      'password': controllerPassword.text,
      'phoneNumber': controllerPhoneNumber.text,
      'address': controllerAddress.text,
      'nationality': controllerNationality.text,
    };
    return userData;
  }

  void back() {
    // Handle the back
    Navigator.pop(context);
  }

  Function()? next() {
    final userData = getUserData();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ContinueSignUp(userData: userData)),
    ); // Handle the next

    return null;
  }

  @override
  void dispose() {
    // Avoid memory leaks
    controllerNameSurname.dispose();
    controllerEmail.dispose();
    controllerPassword.dispose();
    controllerPhoneNumber.dispose();
    controllerAddress.dispose();
    controllerNationality.dispose();

    _focusNodeNameSurname.dispose();
    _focusNodeEmail.dispose();
    _focusNodePhoneNumber.dispose();
    _focusNodeAddress.dispose();
    _focusNodeNationality.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
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
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 15.0),
                          const MyMotivationalQuotes(
                              quote: 'Immagination is everything.'),
                          const SizedBox(height: 30.0),
                          MyInputButton(
                              controller: controllerNameSurname,
                              placeholder: 'Name & Surname',
                              focusNode: _focusNodeNameSurname),
                          const SizedBox(height: 20.0),
                          MyInputButton(
                              controller: controllerEmail,
                              placeholder: 'Email',
                              focusNode: _focusNodeEmail),
                          const SizedBox(height: 20.0),
                          PasswordField(
                            controller: controllerPassword,
                            color: Colors.transparent,
                            passwordConstraint: r'[0-9a-zA-Z]{6,}',
                            hintText: 'Password',
                            passwordDecoration: PasswordDecoration(
                              inputStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              inputPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                            ),
                            border: PasswordBorder(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue.shade100,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  width: 0.3,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorMessage:
                                'Must be at least 6 characters long and contain at least one number.',
                          ),
                          const SizedBox(height: 20.0),
                          IntlPhoneField(
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0.7,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0)),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.9),
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0.9,
                                ),
                              ),
                            ),
                            initialCountryCode: 'IT',
                            dropdownTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            disableLengthCheck: true,
                            onChanged: (phone) {
                              controllerPhoneNumber.text = phone.completeNumber;
                            },
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          MyInputButton(
                              controller: controllerAddress,
                              placeholder: "Address",
                              focusNode: _focusNodeAddress),
                          const SizedBox(height: 20.0),
                          MyInputButton(
                              controller: controllerNationality,
                              placeholder: "Nationality",
                              focusNode: _focusNodeNationality),
                          const SizedBox(height: 40.0),
                          Row(
                            children: <Widget>[
                              MyElevatedButton(
                                  text: 'Back', isBack: true, onPressed: back),
                              const Spacer(),
                              MyElevatedButton(
                                  text: 'Next', isBold: true, onPressed: next),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
