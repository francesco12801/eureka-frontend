import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:flutter/material.dart';

class MyTabBarProfile extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const MyTabBarProfile({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Adjust the horizontal padding as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: selectedIndex == index ? white : greyIOS,
                  ),
                ),
                Container(
                  height: selectedIndex == index ? 2 : 0.5,
                  width: 120,
                  color: selectedIndex == index ? white : greyIOS,
                  margin: const EdgeInsets.only(top: 8),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
