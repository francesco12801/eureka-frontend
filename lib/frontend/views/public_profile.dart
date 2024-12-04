import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/components/personal_card.dart';
import 'package:eureka_final_version/frontend/components/tab_bar_profile.dart';
import 'package:eureka_final_version/frontend/constants/utils.dart';
import 'package:eureka_final_version/frontend/models/genie.dart';
import 'package:eureka_final_version/frontend/models/profile_preview.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
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
      // TODO: Implement friend request sending logic
      // This might involve calling a method from userHelper or a dedicated friend service
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );

      // Update the state to reflect that a request has been sent
      setState(() {
        _canAddFriend = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send friend request: $e')),
      );
    }
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
                        child: Text(
                          'No Genies Yet 😢',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                          textAlign: TextAlign.center,
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
                        return GenieCard(
                          genie: genie,
                          user: _currentUserData!,
                          genieHelper: genieHelper,
                        );
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
        ],
      ),
    );
  }

  Widget _buildFollow() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Followers',
                      _formatNumber(_currentUserData!.followersCount)),
                  if (_canAddFriend)
                    IconButton(
                      icon: const Icon(Icons.person_add, color: white),
                      onPressed: _sendFriendRequest,
                    ),
                  _buildStatColumn('Following',
                      _formatNumber(_currentUserData!.followingCount)),
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
