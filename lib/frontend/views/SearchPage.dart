import 'dart:async';
import 'package:eureka_final_version/frontend/api/search/search_engine_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/constants/utils.dart';
import 'package:eureka_final_version/frontend/models/constant/profile_preview.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/PublicProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchPage extends StatefulWidget {
  final EurekaUser userData;
  final SearchEngineHelper searchHelper = SearchEngineHelper();
  final UserHelper userHelper = UserHelper();

  SearchPage({required this.userData, Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Search types
  final List<String> _searchTypes = ['All', 'Genies', 'Profiles'];
  String _selectedSearchType = 'All';

  // Genie categories (only show when Genies is selected)
  final List<String> _genieCategories = [
    'All',
    'Productivity',
    'Finance',
    'Health',
    'Education',
    'Entertainment'
  ];
  String _selectedGenieCategory = 'All';

  // Search results
  final List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';

  // Debounce variables for search
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Search logic performed here
  Future<void> _performSearch(String query) async {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Add a slight delay to reduce unnecessary API calls
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      // Skip search if query is too short
      if (query.length < 2) {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _isSearching = true;
        _errorMessage = '';
      });

      try {
        debugPrint('Searching for: $query');
        debugPrint('Type: $_selectedSearchType');
        debugPrint('Category: $_selectedGenieCategory');
        final response = await widget.searchHelper
            .search(query, _selectedSearchType, _selectedGenieCategory);

        // Get the statusCode from response
        final statusCode = response['statusCode'];

        debugPrint('status code: $statusCode');

        if (statusCode == 200) {
          // Parse the response body
          final responseBody = response['data'];

          debugPrint('response body: $responseBody');

          // Clear previous results
          _searchResults.clear();

          if (responseBody.containsKey('genies')) {
            final List<dynamic> geniesData = responseBody['genies'];

            // Directly process each genie object
            for (var genie in geniesData) {
              _searchResults.add(GenieResult(
                title: genie['title'] ?? 'Unnamed Genie',
                id: genie['id'],
                description: genie['description'] ?? 'No description',
                category: genie['category'] ?? 'Uncategorized',
                iconData: _getCategoryIcon(genie['category'] ?? 'All'),
              ));
            }
          }

          if (responseBody.containsKey('profiles')) {
            final List<dynamic> profilesData = responseBody['profiles'];

            for (var profile in profilesData) {
              if (profile['nameSurname'] != widget.userData.nameSurname) {
                _searchResults.add(EurekaUserPublic(
                  nameSurname: profile['nameSurname'],
                  uid: profile['uid'],
                  profession: profile['profession'],
                  profileImage:
                      profile['profileImage'] ?? placeholderProfilePicture,
                ));
              }
            }
          }

          setState(() {
            _isSearching = false;
          });
        } else {
          setState(() {
            _isSearching = false;
            _errorMessage =
                'Failed to load search results. Status code: ${response['statusCode']}';
            _searchResults.clear();
          });
        }
      } catch (e) {
        // Handle network or parsing errors
        setState(() {
          _isSearching = false;
          _errorMessage = 'An error occurred: ${e.toString()}';
          _searchResults.clear();
        });
      }
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Productivity':
        return CupertinoIcons.bolt;
      case 'Finance':
        return CupertinoIcons.money_dollar;
      case 'Health':
        return CupertinoIcons.heart;
      case 'Education':
        return CupertinoIcons.book;
      case 'Entertainment':
        return CupertinoIcons.game_controller;
      default:
        return CupertinoIcons.circle_grid_3x3;
    }
  }

  // Modify the build method to show error message if exists
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchHeader(),
            _buildSearchTypeSelector(),
            if (_selectedSearchType == 'Genies') _buildCategorySelector(),

            // Show error message if exists
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                      color: Colors.red.shade300, fontFamily: 'Roboto'),
                ),
              ),

            // Search Results
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Back Button and Search Text in the same row
          Row(
            children: [
              // Back Button
              IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(
                  width: 8), // Space between back button and "Search" text

              // 'Search' Text
              const Text(
                'Explore',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Material(
            color: Colors.transparent,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Colors.white, fontFamily: 'Roboto'),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade900,
                hintText: 'Search genies or profiles...',
                hintStyle: TextStyle(
                    color: Colors.grey.shade600, fontFamily: 'Roboto'),
                prefixIcon:
                    Icon(CupertinoIcons.search, color: Colors.grey.shade600),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(CupertinoIcons.clear_thick_circled,
                            color: Colors.grey.shade600),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.length > 2) {
                  _performSearch(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _searchTypes.map((type) {
          bool isSelected = _selectedSearchType == type;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(type,
                  style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontFamily: 'Roboto')),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSearchType = type;
                  _searchResults.clear();
                  if (_selectedSearchType != 'Genies') {
                    _selectedGenieCategory = 'All';
                  }
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                });
              },
              selectedColor: Colors.white,
              backgroundColor: Colors.grey.shade900,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _genieCategories.map((category) {
          bool isSelected = _selectedGenieCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category,
                  style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontFamily: 'Roboto')),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedGenieCategory = category;
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                });
              },
              selectedColor: Colors.white,
              backgroundColor: Colors.grey.shade900,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.search,
                size: 100,
                color: Colors.grey.shade800,
              ),
              const SizedBox(height: 16),
              Text(
                'Start searching for genies or profiles',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.nosign,
                size: 100,
                color: Colors.grey.shade800,
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];

          if (result is GenieResult) {
            return GestureDetector(
              onTap: () {
                // Naviga alla nuova pagina per "GenieResult"
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => GenieOpenPage(
                //         result: result), // Crea la pagina di dettaglio
                //   ),
                // );
              },
              child: Card(
                color: cardColor,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    child: Icon(result.iconData, color: Colors.white),
                  ),
                  title: Text(
                    result.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  subtitle: Text(
                    result.description,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontFamily: 'Roboto'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.bookmark),
                    color: Colors.white,
                    onPressed: () async {
                      // Add genie logic - potentially make an API call to add the genie
                      await _addGenie(result);
                    },
                  ),
                ),
              ).animate().fadeIn().slideX(begin: 0.1),
            );
          } else if (result is EurekaUserPublic) {
            return GestureDetector(
              onTap: () {
                // Naviga alla nuova pagina per "EurekaPublic"
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PublicProfilePage(
                      userData: result,
                    ),
                  ),
                );
              },
              child: Card(
                color: cardColor,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(result.profileImage),
                  ),
                  title: Text(
                    result.nameSurname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  subtitle: Text(
                    result.profession,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  trailing: StatefulBuilder(
                    builder: (context, setState) {
                      bool isRequestSent = false;

                      return FutureBuilder<bool>(
                        future: widget.userHelper.isAlreadyFriend(result.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Icon(Icons.error);
                          } else {
                            bool isAlreadyFriends = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isAlreadyFriends || isRequestSent
                                    ? CupertinoIcons.check_mark_circled_solid
                                    : CupertinoIcons.person_add,
                              ),
                              color: Colors.white,
                              onPressed: isAlreadyFriends || isRequestSent
                                  ? null
                                  : () async {
                                      final response = await widget.userHelper
                                          .sendFriendRequest(result.uid);
                                      if (response) {
                                        setState(() {
                                          isRequestSent = true;
                                        });
                                        showSuccessOverlay(
                                            context, result.nameSurname);
                                      }
                                    },
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ).animate().fadeIn().slideX(begin: 0.1),
            );
          }

          return Container();
        },
      ),
    );
  }

  void showSuccessOverlay(BuildContext context, String nameSurname) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Dark semi-transparent background
          Positioned.fill(
            child: ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
          ),
          // Centered overlay
          Positioned.fill(
            child: Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.8, end: 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: scale,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C), // Deep charcoal
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                                color: const Color(
                                    0xFF4A4A4A), // Slightly lighter border
                                width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 25,
                                spreadRadius: 2,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 28.0,
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  'You are now following $nameSurname!',
                                  style: const TextStyle(
                                    color: Colors.white70, // Soft white
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );

    // Insert the overlay
    overlay.insert(overlayEntry);

    // Remove the overlay after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> _addGenie(GenieResult genie) async {}
}
