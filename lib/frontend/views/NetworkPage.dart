import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/collaborate/collaborate_manager.dart';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/navigation_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/CollaborationCluser.dart';
import 'package:eureka_final_version/frontend/components/my_navigation_bar.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/models/constant/collaboration.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NetworkPage extends StatefulWidget {
  final EurekaUser userData;
  const NetworkPage({super.key, required this.userData});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final AuthHelper authHelper = AuthHelper();
  final UserHelper userHelper = UserHelper();
  final GenieHelper _genieService = GenieHelper();
  final CollaborateService collaborateService = CollaborateService();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<CollaborationCluster> collaborationClusters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollaborations();
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

  Widget _buildCollaborationList() {
    return ListView.builder(
      itemCount: collaborationClusters.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final cluster = collaborationClusters[index];
        return _buildCollaborationCluster(cluster);
      },
    );
  }

  Widget _buildCollaborationCluster(CollaborationCluster cluster) {
    debugPrint('Building cluster for genieId: ${cluster.genieId}');
    debugPrint('Collaborations: ${cluster.collaborations}');

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(cluster),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cluster.genieName ?? 'Genie ${cluster.genieId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                      }),
                ],
              ),
            ),
            if (_hasPendingCollaborations(cluster))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_getPendingCount(cluster)} pending',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        children: [
          _buildCollaboratorsList(cluster),
        ],
      ),
    );
  }

  Future<String> _loadGenieOwnerName(String genieId) async {
    try {
      return 'Owner Name';
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

  int _getPendingCount(CollaborationCluster cluster) {
    return cluster.collaborations
        .where((collab) => collab.status == CollaborationStatus.PENDING)
        .length;
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
            leading: CircleAvatar(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.withOpacity(0.2),
              child: const Icon(Icons.error, color: Colors.red),
            ),
            title: const Text(
              'Error loading user data',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final userData = snapshot.data!;

        return ListTile(
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isPending ? Colors.orange : Colors.blue.shade400,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: userData['profileImage'] != null
                  ? NetworkImage(userData['profileImage'])
                  : null,
              backgroundColor: Colors.grey.withOpacity(0.2),
              child: userData['profileImage'] == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            userData['nameSurname'] ?? 'Unknown',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData['profession'] ?? 'No profession',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
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
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 20),
                      ),
                      onPressed: () => _acceptCollaboration(collab),
                      color: Colors.green,
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                      onPressed: () => _declineCollaboration(collab),
                      color: Colors.red,
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mail_outline, size: 20),
                      ),
                      onPressed: () => _sendMessage(collab),
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.videocam_outlined, size: 20),
                      ),
                      onPressed: () => _startVideoCall(collab),
                      color: Colors.blue,
                    ),
                  ],
                ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: primaryColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Collaboration',
                      style: TextStyle(
                        color: white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: filterUnreadIcon,
                      onPressed: () => _loadCollaborations(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCollaborationList(),
            ),
          ],
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

  void _declineCollaboration(Collaboration collab) {}

  void _sendMessage(Collaboration collab) {}

  void _startVideoCall(Collaboration collab) {}
}
