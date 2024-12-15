import 'package:flutter/material.dart';

class AnimatedTabContent extends StatelessWidget {
  final int selectedIndex;
  final List<Widget> children;
  final Duration duration;

  const AnimatedTabContent({
    Key? key,
    required this.selectedIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.05, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(selectedIndex),
        child: children[selectedIndex],
      ),
    );
  }
}
