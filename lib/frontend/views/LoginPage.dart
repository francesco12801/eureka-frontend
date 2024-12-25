import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/components/MyElevatedButton.dart';
import 'package:eureka_final_version/frontend/components/MyIcons.dart';
import 'package:eureka_final_version/frontend/components/MyInputButton.dart';
import 'package:eureka_final_version/frontend/components/MyMotivationalQuotes.dart';
import 'package:eureka_final_version/frontend/components/MyPopup.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/components/MyTextButton.dart';
import 'package:eureka_final_version/frontend/views/HomePage.dart';
import 'package:eureka_final_version/frontend/views/SignupPage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Mail or Password Error
  bool errorMessage = false;

  // Auth Helper

  final authHelper = AuthHelper();

  // Focus Nodes
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();

  @override
  void dispose() {
    // Clean up the controllers and focus nodes when the widget is disposed
    emailController.dispose();
    passwordController.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    super.dispose();
  }

  // methods
  void createAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
    );
  }

  Function()? forgotPassword() {
    // Handle forgot password action
    return null;
  }

  Function()? login(BuildContext context) {
    final BuildContext currentContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/eureka_loader.gif',
                  width: 50,
                  height: 50,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logging in...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    authHelper
        .userLogin(emailController.text, passwordController.text, errorMessage)
        .then((LoginResponse) {
      Navigator.pop(currentContext); // Close loader
      if (LoginResponse.success && currentContext.mounted) {
        Navigator.push(
          currentContext,
          MaterialPageRoute(
            builder: (context) => HomePage(userData: LoginResponse.user!),
          ),
        );
      } else if (currentContext.mounted) {
        setState(() => errorMessage = true);
      }
    }).catchError((error) {
      Navigator.pop(currentContext); // Close loader
      if (currentContext.mounted) {
        setState(() => errorMessage = true);
      }
    });
    return null;
  }

  Function()? loginWithFacebook() {
    // Handle Facebook login action
    return null;
  }

  Function()? loginWithInstagram() {
    // Handle Instagram login action
    return null;
  }

  Function()? loginWithTwitter() {
    // Handle Twitter login action
    return null;
  }

  Function()? loginWithGoogle() {
    // Handle Google login action
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/images/logo-nobackground.png",
                          width: 150,
                          height: 150,
                        ),
                        const SizedBox(height: 20.0),
                        const MyMotivationalQuotes(
                            quote:
                                "People don't know what they want until you show it to them."),
                        const SizedBox(height: 35.0),
                        // Email Input Field
                        MyInputButton(
                            controller: emailController,
                            placeholder: 'Email',
                            focusNode: _focusNodeEmail,
                            errorMessage: errorMessage),
                        const SizedBox(height: 20.0),
                        // Password Input Field
                        MyInputButton(
                          controller: passwordController,
                          placeholder: 'Password',
                          focusNode: _focusNodePassword,
                          obscureText: true,
                          errorMessage: errorMessage,
                        ),

                        const SizedBox(height: 10.0),
                        if (errorMessage)
                          const Text(
                            'Email or Password is incorrect',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15.0,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        const SizedBox(height: 30.0),
                        SizedBox(
                          height: 40.0,
                          width: 100.0,
                          child: MyElevatedButton(
                            text: "Login",
                            personalColor: true,
                            textColor: const Color.fromARGB(255, 3, 150, 219),
                            onPressed: () => login(context),
                            textSize: 15,
                            isBold: true,
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        const Row(
                          children: <Widget>[
                            Expanded(child: Divider(color: Colors.white)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 210, 210, 210),
                                  fontFamily: 'Inter', // Set the font to Inter
                                  fontWeight: FontWeight
                                      .w300, // Set the font weight to 300 (thin)
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 40.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            MyFbIcon(onPressed: loginWithFacebook),
                            MyAppleIcon(
                              onPressed: loginWithInstagram,
                            ),
                            MyXIcon(onPressed: loginWithTwitter),
                            MyGoogleIcon(onPressed: loginWithGoogle),
                          ],
                        ),
                        const SizedBox(height: 40.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            MyTextButton(
                                text: 'Create an account',
                                onPressed: createAccount),
                            MyTextButton(
                                text: 'Forgot Password?',
                                onPressed: forgotPassword),
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
    );
  }
}
