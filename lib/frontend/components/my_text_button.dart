import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  final String text;
  final FontWeight? weight;
  final double? size;
  final Function()? onPressed;
  final Color? textColor;
  final bool isBold;

  const MyTextButton(
      {required this.text,
      required this.onPressed,
      this.isBold = false,
      this.textColor,
      this.weight,
      this.size,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontFamily: 'Inter',
            fontWeight: isBold ? FontWeight.bold : (weight ?? FontWeight.w300),
            fontSize: size,
          )),
    );
  }
}
