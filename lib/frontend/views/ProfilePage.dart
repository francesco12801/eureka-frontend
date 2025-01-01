import 'dart:ui';

import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/references/reference_manager.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/MyAnimatedTabBar.dart';
import 'package:eureka_final_version/frontend/components/MyCalendar.dart';
import 'package:eureka_final_version/frontend/components/GenieCard.dart';
import 'package:eureka_final_version/frontend/components/ReferencesView.dart';
import 'package:eureka_final_version/frontend/components/tab_bar_profile.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/constants/utils.dart';
import 'package:eureka_final_version/frontend/models/constant/genie.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/EditProfile.dart';
import 'package:eureka_final_version/frontend/views/SettingPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eureka_final_version/frontend/components/MyNavigationBar.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  final EurekaUser userData;
  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GenieHelper genieHelper = GenieHelper();
  final AuthHelper authHelper = AuthHelper();
  final UserHelper userHelper = UserHelper();
  final ReferenceHelper referenceHelper = ReferenceHelper();
  final _secureStorage = const FlutterSecureStorage();

  late bool isProfileNull;
  late bool isBannerNull;

  bool isLoading = false;

  late EurekaUser _currentUserData;
  String? profileImageUrl;
  String? bannerImageUrl;
  int _selectedTabIndex = 0;
  late Future<List<Map<String, dynamic>>> geniesFuture;

  int followersFuture = 0;
  int followingFuture = 0;

  @override
  void initState() {
    super.initState();
    _currentUserData = widget.userData;
    profileImageUrl = null;
    bannerImageUrl = null;
    isBannerNull = true;
    isProfileNull = true;
    geniesFuture = _fetchGenies();
    _loadFollowCount();
    _loadImages(); // Load images on init
  }

  Future<void> _loadFollowCount() async {
    followersFuture = await userHelper.getFollowerCount();
    followingFuture = await userHelper.getFollowingCount();
    setState(() {
      followersFuture = followersFuture;
      followingFuture = followingFuture;
    });
  }

  Future<void> _loadImages() async {
    setState(() => isLoading = true);
    profileImageUrl = await userHelper.getProfileImage();
    bannerImageUrl = await userHelper.getBannerImage();
    if (profileImageUrl != null) {
      isProfileNull = false;
    }
    if (bannerImageUrl != null) {
      isBannerNull = false;
    }

    await Future.delayed(const Duration(milliseconds: 2300));

    setState(() => isLoading = false);
  }

  Future<List<Map<String, dynamic>>> _fetchGenies() async {
    return genieHelper.getUserGenies();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void onTap(int index) async {
    String? token = await _secureStorage.read(key: 'auth_token');
    if (token == null || !(await authHelper.checkToken())) {
      Navigator.pushNamed(context, loginRoute);
      return;
    }
    switch (index) {
      case 0:
        Navigator.pushNamed(context, homePageRoute,
            arguments: _currentUserData);
        break;
      case 1:
        Navigator.pushNamed(context, notificationPageRoute,
            arguments: _currentUserData);
        break;
      case 2:
        Navigator.pushNamed(context, eurekaRoute, arguments: _currentUserData);
        break;
      case 3:
        Navigator.pushNamed(context, networkRoute, arguments: _currentUserData);
        break;
      case 4:
        Navigator.pushNamed(context, profileRoute, arguments: _currentUserData);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadImages();
            await _loadFollowCount();
            setState(() {
              geniesFuture = _fetchGenies();
            });
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildFollow(),
                    _buildProfileInfo(),
                    MyTabBarProfile(
                      tabs: const [
                        '💡 Genies',
                        '🗓️ Calendar',
                        '⭐️ References'
                      ],
                      selectedIndex: _selectedTabIndex,
                      onTabSelected: _onTabSelected,
                    ),
                    const SizedBox(height: 15),
                    AnimatedTabContent(
                      selectedIndex: _selectedTabIndex,
                      children: [
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: geniesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                  final genie =
                                      Genie.fromMap(snapshot.data![index]);
                                  return GenieCard(
                                    genie: genie,
                                    user: _currentUserData,
                                    genieHelper: genieHelper,
                                  );
                                },
                              );
                            }
                          },
                        ),
                        // const ModernCalendarView(),
                        ReferencesView(
                          referencesFuture: referenceHelper.getUserReferences(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isLoading)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/eureka_loader.gif',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 4,
        onTap: onTap,
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
            right: 10,
            child: GestureDetector(
              onTap: () async {
                final updatedUser = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SettingPage(userData: _currentUserData),
                    ));
                if (updatedUser != null)
                  setState(() => _currentUserData = updatedUser);
              },
              child: const Icon(CupertinoIcons.settings, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
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
          Positioned(
            bottom: 20,
            right: MediaQuery.of(context).size.width / 2 - 55,
            child: GestureDetector(
              onTap: () async {
                final updatedUser = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfile(userData: _currentUserData),
                    ));
                if (updatedUser != null)
                  setState(() => _currentUserData = updatedUser);
              },
              child: const Icon(CupertinoIcons.pencil_outline,
                  color: Colors.white, size: 30),
            ),
          ),
        ],
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
            _buildStatColumn('Followers', _formatNumber(followersFuture)),
            _buildStatColumn('Following', _formatNumber(followingFuture)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: white,
                fontFamily: 'Roboto')),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 16, color: greyIOS, fontFamily: 'Roboto')),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000)
      return '${(number / 1000000).toStringAsFixed(1)} mln';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)} k';
    return number.toString();
  }

  Widget _buildProfileInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          children: [
            Text(
              _currentUserData.nameSurname,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: white,
                  fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 5),
            Text(
              _currentUserData.profession,
              style: const TextStyle(
                  fontSize: 14, color: greyIOS, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 10),
            Text(
              _currentUserData.description ?? 'Add Description',
              style: const TextStyle(
                  fontSize: 16, color: white, fontFamily: 'Roboto'),
            ),
          ],
        ),
      ),
    );
  }
}
