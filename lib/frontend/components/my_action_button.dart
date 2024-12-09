import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Future<bool>? isActive;
  final Future<bool>? isBookmark;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive,
    this.isBookmark,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _currentState = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    widget.isActive?.then((value) => setState(() => _currentState = value));
    widget.isBookmark?.then((value) => setState(() => _isBookmarked = value));
  }

  @override
  Widget build(BuildContext context) {
    // Check if it's a comment or share icon
    bool isStaticIcon = widget.icon == CupertinoIcons.chat_bubble ||
        widget.icon == CupertinoIcons.share;

    IconData currentIcon = widget.icon;
    if (!isStaticIcon) {
      if (widget.icon == CupertinoIcons.heart) {
        currentIcon =
            _currentState ? CupertinoIcons.heart_fill : CupertinoIcons.heart;
      } else if (widget.icon == CupertinoIcons.bookmark) {
        currentIcon = _currentState
            ? CupertinoIcons.bookmark_fill
            : CupertinoIcons.bookmark;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isStaticIcon) {
            setState(() => _currentState = !_currentState);
          }
          widget.onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(
            currentIcon,
            color: isStaticIcon
                ? Colors.white
                : (_currentState
                    ? (_isBookmarked ? Colors.yellow : Colors.red)
                    : Colors.white),
            size: 24,
          ),
        ),
      ),
    );
  }
}
