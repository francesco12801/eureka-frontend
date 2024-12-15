import 'dart:ui';

import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/GeniePublicCard.dart';
import 'package:eureka_final_version/frontend/components/MyFriendRequestButton.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/components/tab_bar_profile.dart';
import 'package:eureka_final_version/frontend/constants/utils.dart';
import 'package:eureka_final_version/frontend/models/constant/genie.dart';
import 'package:eureka_final_version/frontend/models/constant/profile_preview.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/FollowerListPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PublicProfilePage extends StatefulWidget {
  final EurekaUserPublic userData;
  final UserHelper userHelper = UserHelper();
  PublicProfilePage({super.key, required this.userData});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final GenieHelper genieHelper = GenieHelper();
  final UserHelper userHelper = UserHelper();

  String? _currentUserId;

  EurekaUser? _currentUserData;
  String? profileImageUrl;
  String? bannerImageUrl;
  bool _isLoading = true;
  bool isProfileNull = true;
  bool isBannerNull = true;
  int _selectedTabIndex = 0;
  Future<List<Map<String, dynamic>>>? geniesFuture;
  bool _canAddFriend = false;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _setPublicProfile();
    if (_currentUserData != null) {
      _currentUserId = await userHelper.getCurrentUserId();
      _loadImages();
      geniesFuture = _fetchGenies();
      // Check if the user can be added as a friend
      _canAddFriend = await _checkFriendEligibility();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendFriendRequest() async {
    try {
      if (_canAddFriend) {
        showSuccessOverlay(context, _currentUserData!.nameSurname);
        await widget.userHelper.sendFriendRequest(_currentUserData!.uid);
        setState(() {
          _canAddFriend = false;
        });
      } else {
        showEliminateOverlay(context, _currentUserData!.nameSurname);
        await widget.userHelper.removeFriend(_currentUserData!.uid);
        setState(() {
          _canAddFriend = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update friend status: $e')),
      );
    }
  }

  void showEliminateOverlay(BuildContext context, String nameSurname) {
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
                                color: Color.fromARGB(255, 152, 51, 0),
                                size: 28.0,
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  'You are no longer following $nameSurname.',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 3,
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

  Future<bool> _checkFriendEligibility() async {
    final response =
        await widget.userHelper.isAlreadyFriend(_currentUserData!.uid);
    if (response) {
      return false;
    }
    return true;
  }

  Future<void> _setPublicProfile() async {
    debugPrint("Public profile uid: ${widget.userData.uid}");
    final data = await userHelper.getUserPublicInformation(widget.userData.uid);
    debugPrint("Public profile data in public profile: $data");
    if (data != null) {
      _currentUserData = EurekaUser.fromMap(data);
    } else {
      debugPrint("Nessun dato trovato per l'UID fornito.");
    }
  }

  Future<void> _loadImages() async {
    if (_currentUserData == null) return;
    profileImageUrl =
        await userHelper.getPublicProfileImage(_currentUserData!.uid);

    bannerImageUrl =
        await userHelper.getPublicBannerImage(_currentUserData!.uid);
    isProfileNull = profileImageUrl == null;
    isBannerNull = bannerImageUrl == null;
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _fetchGenies() async {
    if (_currentUserData == null) return [];
    return genieHelper.getPublicUserGenies(_currentUserData!.uid);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentUserData == null) {
      return const Center(
        child: Text("Nessun profilo trovato."),
      );
    }

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildFollow(),
              _buildProfileInfo(),
              MyTabBarProfile(
                tabs: const ['💡 Genies', '🗓️ Calendar', '⭐️ References'],
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) => setState(() {
                  _selectedTabIndex = index;
                }),
              ),
              const SizedBox(height: 15),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: geniesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 50),
                            Text(
                              'No Genies Yet 😢',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Unleash your creativity and create the first Genie! 💡',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final genie = Genie.fromMap(snapshot.data![index]);
                        return GeniePublicCard(
                            genie: genie,
                            user: _currentUserData!,
                            genieHelper: genieHelper);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: isBannerNull == false
                    ? NetworkImage(bannerImageUrl!)
                    : const AssetImage('assets/images/slogan-nobackground.png')
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedFollowButton(
              isFollowing: !_canAddFriend,
              onPressed: _sendFriendRequest,
            ),
          ),
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (!isProfileNull && _canAddFriend) {
                  _showImageOverlay(context, profileImageUrl!);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: greyIOS, width: 1),
                ),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: isProfileNull == false
                          ? NetworkImage(profileImageUrl!)
                          : NetworkImage(placeholderProfilePicture),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageOverlay(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned(
              right: 16,
              top: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: ClipOval(
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollow() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowersPage(
                              currentUserId: _currentUserId!,
                              userId: _currentUserData!.uid,
                              isFollowers: true),
                        ),
                      );
                    },
                    child: _buildStatColumn('Followers',
                        _formatNumber(_currentUserData!.followersCount)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowersPage(
                              currentUserId: _currentUserId!,
                              userId: _currentUserData!.uid,
                              isFollowers: false),
                        ),
                      );
                    },
                    child: _buildStatColumn('Following',
                        _formatNumber(_currentUserData!.followingCount)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          children: [
            Text(
              _currentUserData!.nameSurname,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: white,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _currentUserData!.profession,
              style: const TextStyle(
                fontSize: 14,
                color: greyIOS,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _currentUserData!.description ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: white,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: white,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: greyIOS,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000)
      return '${(number / 1000000).toStringAsFixed(1)} mln';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)} k';
    return number.toString();
  }
}
