import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:flutter/material.dart';

class MyTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const MyTabBar(
      {required this.tabs,
      required this.selectedIndex,
      required this.onTabSelected,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: transparent, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List<Widget>.generate(tabs.length, (index) {
          return GestureDetector(
            onTap: () {
              onTabSelected(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selectedIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedIndex == index ? selected : white,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
