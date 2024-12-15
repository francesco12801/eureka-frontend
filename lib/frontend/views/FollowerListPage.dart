// import 'package:eureka_final_version/frontend/models/profile_preview.dart';
import 'package:eureka_final_version/frontend/models/constant/profile_preview.dart';
import 'package:eureka_final_version/frontend/views/PublicProfile.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';

class FollowersPage extends StatefulWidget {
  final String userId;
  final bool isFollowers;
  final String currentUserId; // Aggiungi questo parametro

  const FollowersPage({
    super.key,
    required this.userId,
    required this.isFollowers,
    required this.currentUserId, // Aggiungi questo parametro
  });

  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  final UserHelper _userHelper = UserHelper();
  List<EurekaUserPublic> _followList = [];
  bool _isLoading = true;
  String _pageTitle = '';

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.isFollowers ? 'Followers' : 'Following';
    _fetchFollowData();
  }

  Future<void> _fetchFollowData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<dynamic> followData = widget.isFollowers
          ? await _userHelper.getFollowers(widget.userId)
          : await _userHelper.getFollowing(widget.userId);

      debugPrint('Follow data wooooow: $followData');

      // Converti i dati e ordina la lista
      List<EurekaUserPublic> sortedList =
          followData.map((data) => EurekaUserPublic.fromMap(data)).toList();

      // Ordina la lista mettendo il profilo corrente per primo
      sortedList.sort((a, b) {
        if (a.uid == widget.currentUserId) return -1;
        if (b.uid == widget.currentUserId) return 1;
        return a.nameSurname.compareTo(b.nameSurname);
      });

      setState(() {
        _followList = sortedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading $_pageTitle: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          _pageTitle,
          style: const TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: white,
              ),
            )
          : _buildFollowList(),
    );
  }

  Widget _buildFollowList() {
    if (_followList.isEmpty) {
      return Center(
        child: Text(
          'No $_pageTitle yet',
          style: const TextStyle(
            color: white,
            fontSize: 18,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _followList.length,
      separatorBuilder: (context, index) => const Divider(
        color: greyIOS,
        height: 1,
        thickness: 0.5,
      ),
      itemBuilder: (context, index) {
        final user = _followList[index];
        return _buildFollowListItem(user);
      },
    );
  }

  Widget _buildFollowListItem(EurekaUserPublic user) {
    final bool isCurrentUser = user.uid == widget.currentUserId;

    return ListTile(
      onTap: isCurrentUser
          ? null // Disabilita il tap per il profilo corrente
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PublicProfilePage(userData: user),
                ),
              );
            },
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: greyIOS.withOpacity(0.2),
        backgroundImage:
            CachedNetworkImageProvider(user.profileImage) as ImageProvider,
      ),
      title: Text(
        user.nameSurname + (isCurrentUser ? ' (You)' : ''),
        style: TextStyle(
          color: white,
          fontSize: 16,
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        user.profession,
        style: const TextStyle(
          color: greyIOS,
          fontSize: 14,
        ),
      ),
      trailing: isCurrentUser
          ? null // Nessun pulsante per il profilo corrente
          : ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PublicProfilePage(userData: user),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('View Profile'),
            ),
    );
  }
}
