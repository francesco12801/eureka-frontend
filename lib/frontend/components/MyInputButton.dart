import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyInputButton extends StatefulWidget {
  final String placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final FocusNode? focusNode;
  final bool errorMessage;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const MyInputButton({
    required this.controller,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.focusNode,
    this.errorMessage = false,
    this.onSubmitted,
    super.key,
  });

  @override
  _MyInputButtonState createState() => _MyInputButtonState();
}

class _MyInputButtonState extends State<MyInputButton> {
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();

    // Update state when focus changes
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: widget.controller,
      focusNode: _focusNode,
      placeholder: widget.placeholder,
      placeholderStyle: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(isFocused ? 0.7 : 0.5),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.obscureText ? 1 : null, // Single line for obscured text
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: BoxDecoration(
        color: isFocused
            ? Colors.transparent
            : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
        border: Border.all(
          color: widget.errorMessage
              ? Colors.red
              : (isFocused ? Colors.white : Colors.white.withOpacity(0.9)),
          width: isFocused ? 0.9 : 0.5,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(12.0),
    );
  }
}
