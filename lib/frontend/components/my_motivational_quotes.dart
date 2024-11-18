import 'package:flutter/material.dart';

class MyMotivationalQuotes extends StatelessWidget {
  // set quote
  final String quote;

  const MyMotivationalQuotes({required this.quote, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      quote,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 20.0,
        fontFamily: 'Inter', // Set the font to Inter
        fontWeight: FontWeight.w300, // Set the font weight to 300 (thin)
      ),
    );
  }
}
