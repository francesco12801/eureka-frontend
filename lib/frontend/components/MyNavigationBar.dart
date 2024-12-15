import 'dart:ui';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';

import 'package:flutter/material.dart';

class MyNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MyNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 300.0, sigmaY: 300.0),
        child: SizedBox(
          height: 111,
          child: BottomNavigationBar(
              backgroundColor: Colors.transparent.withOpacity(0.1),
              selectedItemColor: currentIndex == 2
                  ? const Color.fromARGB(219, 255, 235, 59)
                  : selected,
              unselectedItemColor: iconColor,
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: onTap,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              iconSize: 25,
              selectedLabelStyle: const TextStyle(fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              items: [
                const BottomNavigationBarItem(
                  icon: homeIcon,
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: notificationIcon,
                  label: 'Notifications',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 50,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(205, 255, 242, 0),
                        shape: BoxShape.circle,
                      ),
                      child: lightbulbIcon,
                    ),
                  ),
                  label: 'Idea',
                ),
                const BottomNavigationBarItem(
                  icon: networkIcon,
                  label: 'Network',
                ),
                const BottomNavigationBarItem(
                  icon: profileIcon,
                  label: 'Profile',
                ),
              ]),
        ),
      ),
    );
  }
}
