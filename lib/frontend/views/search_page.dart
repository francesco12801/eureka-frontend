import 'dart:ui';

import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final EurekaUser userData;

  const SearchPage({required this.userData, super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Search',
                style: TextStyle(
                  color: white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildSearchResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Hero(
      tag: 'search_bar',
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14), // Clip for the blur effect
          child: Stack(
            children: [
              // Backdrop filter for frosted glass effect
              BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.2), // Semi-transparent background
                    borderRadius: BorderRadius.circular(14),
                  ),
                  height: 40, // Set a fixed height
                ),
              ),
              // Actual TextField
              Container(
                height: 40, // Ensure this matches the backdrop height
                decoration: BoxDecoration(
                  color: Colors
                      .transparent, // Make it transparent to see the blur effect
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(
                    color:
                        Colors.white, // Change this to your desired text color
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search people or genies',
                    hintStyle: const TextStyle(
                      color: greyIOS,
                      fontFamily: 'Roboto',
                    ),
                    border: InputBorder.none,
                    // Adjust the padding to center the text vertically
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.5,
                        horizontal: 16), // Adjust vertical padding
                    suffixIcon: IconButton(
                      icon: const Icon(
                        CupertinoIcons.search,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        // Perform search
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                'Genie $index',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Description of Genie $index',
                style: const TextStyle(
                  color: greyIOS,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(CupertinoIcons.add),
                onPressed: () {
                  // Add genie to user's genies
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
