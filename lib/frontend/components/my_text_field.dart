import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller; // Specify the type for controller
  final String hintText;
  final String fieldName; // New field for the dynamic name
  final bool obscureText;

  const MyTextField({
    required this.controller,
    required this.hintText,
    required this.fieldName, // Add this parameter
    required this.obscureText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align to the start
      children: [
        Text(
          fieldName, // Display the field name
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500, // Adjust weight if needed
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w300, // Set the font weight to 300 (thin)
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300, // Set the font weight to 300 (thin)
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          // Allow multiline input
          minLines: 1, // Minimum number of lines
          maxLines: null, // Allow it to grow indefinitely
          keyboardType:
              TextInputType.multiline, // Set keyboard type for multiline input
          textInputAction: TextInputAction.newline, // Allow new line action
        ),
      ],
    );
  }
}
