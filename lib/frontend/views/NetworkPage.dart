import 'dart:ui';
import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/collaborate/collaborate_manager.dart';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/navigation_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/CollaborationCluser.dart';
import 'package:eureka_final_version/frontend/components/CustomRefreshIndicator.dart';
import 'package:eureka_final_version/frontend/components/ShimmerAvatar.dart';
import 'package:eureka_final_version/frontend/components/MyNavigationBar.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/models/constant/collaboration.dart';
import 'package:eureka_final_version/frontend/models/constant/profile_preview.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/LoginPage.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_indicator/loading_indicator.dart';

class NetworkPage extends StatefulWidget {
  final EurekaUser userData;
  const NetworkPage({super.key, required this.userData});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage>
    with TickerProviderStateMixin {
  final AuthHelper authHelper = AuthHelper();
  final UserHelper userHelper = UserHelper();
  final GenieHelper _genieService = GenieHelper();
  final CollaborateService collaborateService = CollaborateService();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<CollaborationCluster> collaborationClusters = [];
  bool isLoading = true;
  late final AnimationController _refreshIconController = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _loadCollaborations();
  }

  @override
  void dispose() {
    _refreshIconController.dispose();
    super.dispose();
  }

  void onTap(int index) async {
    String? token = await _secureStorage.read(key: 'auth_token');

    if (token == null) {
      // Handle token not found
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Token Not Found'),
          content: Text('Token not found. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  loginRoute,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    bool isVerified = await authHelper.checkToken();

    if (isVerified) {
      switch (index) {
        case 0:
          Navigator.pushNamed(
            context,
            homePageRoute,
            arguments: widget.userData,
          );
          break;
        case 1:
          Navigator.pushNamed(
            context,
            notificationPageRoute,
            arguments: widget.userData,
          );
          break;
        case 2:
          Navigator.pushNamed(
            context,
            eurekaRoute,
            arguments: widget.userData,
          );
          break;
        case 3:
          Navigator.pushNamed(
            context,
            networkRoute,
            arguments: widget.userData,
          );
          break;
        case 4:
          Navigator.pushNamed(
            context,
            profileRoute,
            arguments: widget.userData,
          );
          break;
        default:
          Navigator.pushNamed(
            context,
            homePageRoute,
            arguments: widget.userData,
          );
      }
    } else {
      // Handle token verification failure
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Verification Failed'),
          content:
              const Text('Token verification failed. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                NavigationHelper.navigateToPage(context, const LoginPage());
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadCollaborations() async {
    setState(() => isLoading = true);
    try {
      final response =
          await collaborateService.getCollaborationClusterizedByGenie();
      debugPrint('Collaborations: $response');

      final clusters = await _processCollaborations(response);

      setState(() {
        collaborationClusters = clusters;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading collaborations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading collaborations: $e')),
      );
    }
  }

  Future<String> _loadGenieOwnerName(String genieId) async {
    try {
      return widget.userData.nameSurname;
    } catch (e) {
      debugPrint('Error loading genie owner name: $e');
      return 'Unknown Owner';
    }
  }

  Future<List<CollaborationCluster>> _processCollaborations(
      Map<String, dynamic> response) async {
    List<CollaborationCluster> clusters = [];

    if (response['status'] == 'success' && response['collaborations'] is Map) {
      Map<String, dynamic> collaborationsMap = response['collaborations'];

      for (var genieId in collaborationsMap.keys) {
        debugPrint('Processing genieId: $genieId'); // Debug log

        if (collaborationsMap[genieId] is List) {
          List<Collaboration> collaborations = [];

          for (var item in collaborationsMap[genieId]) {
            try {
              if (item is Map<String, dynamic>) {
                if (item['status'] is String) {
                  String statusStr = item['status'];
                  item['status'] = CollaborationStatus.values.firstWhere(
                    (e) => e.toString() == 'CollaborationStatus.$statusStr',
                    orElse: () => CollaborationStatus.PENDING,
                  );
                }
                collaborations.add(Collaboration.fromJson(item));
              }
            } catch (e) {
              debugPrint('Error processing collaboration: $e');
              continue;
            }
          }

          if (collaborations.isNotEmpty) {
            try {
              debugPrint('Fetching genie details for: $genieId');
              final genieDetails = await _genieService.getGenieById(genieId);
              debugPrint('Genie details received: ${genieDetails.title}');

              clusters.add(
                CollaborationCluster(
                  genieId: genieId,
                  collaborations: collaborations,
                  isExpanded: false,
                  genieName: genieDetails.title,
                  genieOwner: genieDetails.nameSurnameCreator,
                ),
              );
            } catch (e) {
              debugPrint('Error loading genie details for $genieId: $e');
              clusters.add(
                CollaborationCluster(
                  genieId: genieId,
                  collaborations: collaborations,
                  isExpanded: false,
                ),
              );
            }
          }
        }
      }
    }

    return clusters;
  }

  Color _getStatusColor(CollaborationCluster cluster) {
    if (_hasPendingCollaborations(cluster)) {
      return Colors.orange;
    }

    bool hasAccepted = cluster.collaborations
        .any((collab) => collab.status == CollaborationStatus.ACCEPTED);

    if (hasAccepted) {
      return Colors.green;
    }

    return Colors.grey;
  }

  bool _hasPendingCollaborations(CollaborationCluster cluster) {
    return cluster.collaborations
        .any((collab) => collab.status == CollaborationStatus.PENDING);
  }

  Future<Map<String, dynamic>> _loadUserData(String userId) async {
    try {
      final futures = await Future.wait([
        userHelper.getPublicProfileImage(userId),
        userHelper.getNameSurname(userId),
        userHelper.getProfession(userId),
      ]);

      return {
        'profileImage': futures[0],
        'nameSurname': futures[1],
        'profession': futures[2],
      };
    } catch (e) {
      debugPrint('Error loading user data: $e');
      throw e;
    }
  }

  String _formatTimestamp(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Collaborations Yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start collaborating with others to see them here',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTile() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.withOpacity(0.2),
        child: const Icon(Icons.error_outline, color: Colors.red),
      ),
      title: const Text(
        'Error loading user data',
        style: TextStyle(color: Colors.red),
      ),
      subtitle: const Text(
        'Please try again later',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildCollaborationList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: collaborationClusters.length,
        itemBuilder: (context, index) {
          final cluster = collaborationClusters[index];
          return _buildCollaborationCluster(cluster);
        },
      ),
    );
  }

  Color getRandomColor() {
    final random = math.Random();
    return Color.fromRGBO(
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
      1.0, // Opacity
    );
  }

  Widget _buildCollaborationCluster(CollaborationCluster cluster) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
      color: const Color(0xFF2A2A2A),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.dark(
            primary: _getStatusColor(cluster),
          ),
        ),
        child: ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cluster.genieName ?? 'Genie ${cluster.genieId}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              FutureBuilder<String>(
                future: _loadGenieOwnerName(cluster.genieId),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Loading...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ],
          ),
          children: [
            _buildCollaboratorsList(cluster),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaboratorsList(CollaborationCluster cluster) {
    final pendingCollaborations = cluster.collaborations
        .where((collab) => collab.status == CollaborationStatus.PENDING)
        .toList();
    final acceptedCollaborations = cluster.collaborations
        .where((collab) => collab.status == CollaborationStatus.ACCEPTED)
        .toList();

    return Column(
      children: [
        if (pendingCollaborations.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Pending Requests',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...pendingCollaborations
              .map((collab) => _buildCollaboratorTile(collab, true)),
        ],
        if (acceptedCollaborations.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Active Collaborators',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...acceptedCollaborations
              .map((collab) => _buildCollaboratorTile(collab, false)),
        ],
      ],
    );
  }

  Widget _buildCollaboratorTile(Collaboration collab, bool isPending) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadUserData(collab.senderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: ShimmerAvatar(),
            title: ShimmerText(),
            subtitle: ShimmerText(),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorTile();
        }

        final userData = snapshot.data!;

        return InkWell(
          onTap: () {
            final userPublic = EurekaUserPublic(
              uid: collab.senderId,
              nameSurname: userData['nameSurname'] ?? '',
              profession: userData['profession'] ?? '',
              profileImage: userData['profileImage'],
            );
            Navigator.pushNamed(
              context,
              publicProfileRoute,
              arguments: userPublic,
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Hero(
              tag: 'avatar_${collab.senderId}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPending ? Colors.orange : Colors.blue.shade400,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: userData['profileImage'] != null
                      ? NetworkImage(userData['profileImage'])
                      : null,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  child: userData['profileImage'] == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
              ),
            ),
            title: Text(
              userData['nameSurname'] ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['profession'] ?? 'No profession',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(collab.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: isPending
                ? _buildPendingActions(collab)
                : _buildAcceptedActions(collab),
          ),
        );
      },
    );
  }

  Widget _buildPendingActions(Collaboration collab) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.check_rounded,
          color: Colors.green,
          onPressed: () => _acceptCollaboration(collab),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.close_rounded,
          color: Colors.red,
          onPressed: () => _declineCollaboration(collab),
        ),
      ],
    );
  }

  Widget _buildAcceptedActions(Collaboration collab) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.mail_outline_rounded,
          color: Colors.blue,
          onPressed: () => _sendMessage(collab),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.videocam_outlined,
          color: Colors.blue,
          onPressed: () => _startVideoCall(collab),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withOpacity(0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: CustomRefreshIndicator(
          onRefresh: () async {
            await _loadCollaborations();
          },
          child: Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverAppBar(
                    floating: true,
                    backgroundColor: primaryColor,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    centerTitle: false,
                    titleSpacing: 25,
                    title: Text(
                      'Collaboration',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isLoading ? 0.0 : 1.0,
                      child: collaborationClusters.isEmpty && !isLoading
                          ? _buildEmptyState()
                          : _buildCollaborationList(),
                    ),
                  ),
                ],
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
        currentIndex: 3,
        onTap: onTap,
      ),
    );
  }

  // Helper methods
  void _acceptCollaboration(Collaboration collab) async {
    try {
      await collaborateService.acceptCollab(collab.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collaboration accepted')),
      );
      _loadCollaborations();
    } catch (e) {
      debugPrint('Error accepting collaboration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error accepting collaboration')),
      );
    }
  }

  void _declineCollaboration(Collaboration collab) async {
    try {
      await collaborateService.declineCollab(collab.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collaboration declined')),
      );
      _loadCollaborations();
    } catch (e) {
      debugPrint('Error declining collaboration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error declining collaboration')),
      );
    }
  }

  void _sendMessage(Collaboration collab) {}

  void _startVideoCall(Collaboration collab) {}
}
