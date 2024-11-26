import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/personal_card.dart';
import 'package:eureka_final_version/frontend/components/tab_bar_profile.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/models/genie.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:eureka_final_version/frontend/views/edit_profile_page.dart';
import 'package:eureka_final_version/frontend/views/setting_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eureka_final_version/frontend/components/my_navigation_bar.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
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
  final _secureStorage = const FlutterSecureStorage();

  late bool isProfileNull;
  late bool isBannerNull;

  late EurekaUser _currentUserData;
  String? profileImageUrl;
  String? bannerImageUrl;
  int _selectedTabIndex = 0;
  late Future<List<Map<String, dynamic>>> geniesFuture;

  @override
  void initState() {
    super.initState();
    _currentUserData = widget.userData;
    profileImageUrl = null;
    bannerImageUrl = null;
    isBannerNull = true;
    isProfileNull = true;
    geniesFuture = _fetchGenies();
    _loadImages(); // Load images on init
  }

  Future<void> _loadImages() async {
    profileImageUrl = await userHelper.getProfileImage();
    bannerImageUrl = await userHelper.getBannerImage();
    if (profileImageUrl != null) {
      isProfileNull = false;
    }
    if (bannerImageUrl != null) {
      isBannerNull = false;
    }

    setState(() {}); // Refresh UI with loaded images
  }

  // Refresh images manually when clicking the profile
  Future<void> refreshImages() async {
    await _loadImages();
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
    if (token == null || !(await authHelper.checkToken(token))) {
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildFollow(),
              _buildProfileInfo(),
              MyTabBarProfile(
                tabs: const ['💡 Genies', '🗓️ Calendar', '⭐️ References'],
                selectedIndex: _selectedTabIndex,
                onTabSelected: _onTabSelected,
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
                    return const Center(child: Text('No genies found.'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final genie = Genie.fromMap(snapshot.data![index]);
                        return GenieCard(
                            genie: genie,
                            user: _currentUserData,
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
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          onTap(index);
        },
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
                    : const AssetImage('assets/images/techPlaceholder.jpg')
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
                        : const AssetImage(
                                'assets/images/profile_picture_placeholder.jpg')
                            as ImageProvider,
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
            _buildStatColumn(
                'Followers', _formatNumber(_currentUserData.followersCount)),
            _buildStatColumn(
                'Following', _formatNumber(_currentUserData.followingCount)),
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
}
