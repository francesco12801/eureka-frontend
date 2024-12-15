import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Future<bool>? isSaved;
  final Future<bool>? isLiked;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isSaved,
    this.isLiked,
  });

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _localState = false;

  @override
  void initState() {
    super.initState();
    if (widget.isSaved != null) {
      widget.isSaved!.then((value) {
        if (mounted) {
          setState(() {
            _localState = value;
          });
        }
      });
    }
    if (widget.isLiked != null) {
      widget.isLiked!.then((value) {
        if (mounted) {
          setState(() {
            _localState = value;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.icon == CupertinoIcons.bookmark) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _localState = !_localState;
            });
            widget.onPressed();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Icon(
              _localState
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark,
              color: _localState ? Colors.yellow : Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }

    if (widget.icon == CupertinoIcons.heart) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _localState = !_localState;
            });
            widget.onPressed();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Icon(
              _localState ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: _localState ? Colors.red : Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
