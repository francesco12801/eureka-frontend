import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  // Button settings
  final String text;
  final Function()? onPressed;
  final bool isBold;
  final double? textSize;
  final bool isBack;
  final Color? textColor;
  final bool personalColor;

  const MyElevatedButton({
    required this.text,
    required this.onPressed,
    this.personalColor = false,
    this.textColor,
    this.textSize = 0,
    this.isBold = false,
    this.isBack = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isBack
            ? Colors.transparent
            : const Color.fromARGB(255, 247, 247, 247),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(
            color: white,
            width: 2.0,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: personalColor
              ? textColor
              : (isBack ? white : const Color.fromARGB(255, 27, 27, 27)),
          fontFamily: 'Inter',
          fontSize: textSize != 0 ? textSize! : 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w300,
        ),
      ),
    );
  }
}
