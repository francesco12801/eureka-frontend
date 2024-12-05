import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:eureka_final_version/frontend/views/HomePage.dart';
import 'package:flutter/material.dart';

class TransitionBeforeLanding extends StatefulWidget {
  final EurekaUser userData;
  const TransitionBeforeLanding({super.key, required this.userData});

  @override
  _TransitionBeforeLandingState createState() =>
      _TransitionBeforeLandingState();
}

class _TransitionBeforeLandingState extends State<TransitionBeforeLanding> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return HomePage(
              userData: widget.userData,
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/images/logo-nobackground.png",
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16.0),
              const Text(
                "\"Here's to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently. They're not fond of rules. And they have no respect for the status quo. You can quote them, disagree with them, glorify or vilify them. About the only thing you can't do is ignore them. Because they change things. They push the human race forward. And while some may see them as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do.\"",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20.0,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 15.0),
              const Text(
                "―  Steve Jobs ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20.0,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
