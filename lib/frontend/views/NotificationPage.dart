import 'dart:ui';
import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/collaborate/collaborate_manager.dart';
import 'package:eureka_final_version/frontend/api/navigation_helper.dart';
import 'package:eureka_final_version/frontend/api/notification/notify_manager.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/NotificationGroup.dart';
import 'package:eureka_final_version/frontend/components/MyNavigationBar.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/components/MyTabBar.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/models/constant/notification.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/LoginPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:loading_indicator/loading_indicator.dart';

class NotificationPage extends StatefulWidget {
  final EurekaUser userData;
  final NotifyManager notificationHelper = NotifyManager();
  final UserHelper userHelper = UserHelper();
  NotificationPage({super.key, required this.userData});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final AuthHelper authHelper = AuthHelper();
  final _secureStorage = const FlutterSecureStorage();
  int _selectedTabIndex = 0;
  bool isLoading = true;
  List<NotificationEureka> notifications = [];
  List<NotificationEureka> filteredNotifications = [];
  final Map<String, List<NotificationEureka>> _groupedNotifications = {};
  final CollaborateService collaborateService = CollaborateService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _groupNotifications() {
    _groupedNotifications.clear();
    final now = DateTime.now();

    for (var notification in filteredNotifications) {
      final date = DateTime.fromMillisecondsSinceEpoch(notification.createdAt);
      final difference = now.difference(date);

      String group;
      if (difference.inDays == 0) {
        group = 'Today';
      } else if (difference.inDays == 1) {
        group = 'Yesterday';
      } else if (difference.inDays <= 7) {
        group = 'This Week';
      } else {
        group = 'Earlier';
      }

      if (!_groupedNotifications.containsKey(group)) {
        _groupedNotifications[group] = [];
      }
      _groupedNotifications[group]!.add(notification);
    }
  }

  void _handleNotificationTap(NotificationEureka notification) async {
    if (!notification.read) {
      await _markAsRead(notification);
    }

    switch (notification.type) {
      case 'FOLLOW':
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const CircularProgressIndicator(),
              ),
            );
          },
        );

        try {
          final userProfile = await widget.userHelper
              .getUserPublicProfile(notification.fromUserId);

          Navigator.pop(context);

          await Navigator.pushNamed(
            context,
            publicProfileRoute,
            arguments: userProfile,
          );

          setState(() {
            _filterNotifications(_selectedTabIndex);
          });
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;

      case 'LIKE':
        break;
      case 'BOOKMARK':
        break;
      case 'COLLAB':
        break;
    }
  }

  Widget _buildGroupedList() {
    _groupNotifications();

    return ListView.builder(
      itemCount: _groupedNotifications.length,
      itemBuilder: (context, index) {
        final groupKey = _groupedNotifications.keys.elementAt(index);
        final notifications = _groupedNotifications[groupKey]!;

        return NotificationGroup(
          title: groupKey,
          notifications: notifications,
          onTap: _handleNotificationTap,
          onLongPress: _showNotificationOptions,
          buildNotificationTile: _buildNotificationTile,
        );
      },
    );
  }

  void _showNotificationOptions(NotificationEureka notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              notification.read
                  ? Icons.mark_email_unread
                  : Icons.mark_email_read,
              color: Colors.white,
            ),
            title: Text(
              notification.read ? 'Mark as unread' : 'Mark as read',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _markAsRead(notification);
            },
          ),
          if (notification.type == 'friend_request')
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.white),
              title: const Text('View Profile',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  profileRoute,
                  arguments: notification.fromUserId,
                );
              },
            ),
          if (notification.type == 'COMMENT_REPLY')
            ListTile(
              leading: const Icon(Icons.comment, color: Colors.white),
              title: const Text('View Comment',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Handle comment reply notification
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteNotification(notification);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedTabIndex == 0
                ? CupertinoIcons.bell_slash
                : _selectedTabIndex == 1
                    ? CupertinoIcons.bell
                    : CupertinoIcons.eye_slash,
            size: 48,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyMessage(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
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
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    try {
      setState(() => isLoading = true);
      notifications = await widget.notificationHelper
          .getUserNotifications(widget.userData.uid);
      _filterNotifications(_selectedTabIndex);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _filterNotifications(int tabIndex) {
    setState(() {
      switch (tabIndex) {
        case 0: // All
          filteredNotifications = List.from(notifications);
          break;
        case 1: // Collab
          filteredNotifications = notifications
              .where((notification) =>
                  notification.type == 'COLLABORATION_REQUEST' ||
                  notification.type == 'COLLAB_ACCEPTED' ||
                  notification.type == 'COLLAB_DECLINED')
              .toList();
          break;
        case 2: // Unread
          filteredNotifications = notifications
              .where((notification) => !notification.read)
              .toList();
          break;
      }
    });
  }

  Future<void> _markAllAsRead() async {
    try {
      await widget.notificationHelper.markAllAsRead(widget.userData.uid);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<bool> _markAsRead(NotificationEureka notification) async {
    if (notification.read) return true;

    setState(() {
      int index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index].read = true;
      }
    });

    try {
      await widget.notificationHelper
          .markAsRead(notification, widget.userData.uid);
      _filterNotifications(_selectedTabIndex);
      return true;
    } catch (e) {
      setState(() {
        int index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index].read = false;
        }
      });
      _filterNotifications(_selectedTabIndex);
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: black.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Delete Notification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'Are you sure you want to delete this notification?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(NotificationEureka notification) {
    if (notification.type == 'COLLABORATION_REQUEST') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Header della notifica
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: !notification.read
                          ? Border.all(color: Colors.blue.shade400, width: 2)
                          : null,
                    ),
                    child: FutureBuilder<String?>(
                      future: widget.userHelper
                          .getPublicProfileImage(notification.fromUserId),
                      builder: (context, snapshot) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundImage: snapshot.hasData
                              ? NetworkImage(snapshot.data!)
                              : null,
                          backgroundColor: Colors.grey.withOpacity(0.5),
                          child: !snapshot.hasData
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.person_2_fill,
                                    color: Colors.blue,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Collaboration',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification.body,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pulsanti di azione
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.2),
                        foregroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _onPressedAccept(notification.collaborationId!);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.check_mark),
                          SizedBox(width: 8),
                          Text('Accept'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.xmark),
                          SizedBox(width: 8),
                          Text('Decline'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.video_camera_solid,
                          color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Schedule Video Call',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Dismissible(
      key: ValueKey(
          '${notification.id}_${notification.read}_${notification.createdAt}'),
      background: Container(
        color: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return true;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _markAsRead(notification);
        } else {
          _deleteNotification(notification);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: !notification.read
                  ? Border.all(color: Colors.blue.shade400, width: 2)
                  : null,
            ),
            child: FutureBuilder<String?>(
              future: widget.userHelper
                  .getPublicProfileImage(notification.fromUserId),
              builder: (context, snapshot) {
                return CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      snapshot.hasData ? NetworkImage(snapshot.data!) : null,
                  backgroundColor: Colors.grey.withOpacity(0.5),
                  child: !snapshot.hasData
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                );
              },
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        notification.read ? FontWeight.normal : FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                notification.body,
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(notification.read ? 0.5 : 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTimestamp(notification.createdAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPressedAccept(String collaborationId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const CircularProgressIndicator(),
            ),
          );
        },
      );

      await collaborateService.acceptCollab(collaborationId);

      Navigator.pop(context);

      setState(() {
        notifications.removeWhere((n) =>
            n.type == 'COLLABORATION_REQUEST' &&
            n.collaborationId == collaborationId);
        _filterNotifications(_selectedTabIndex);
      });

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: black.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Success!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Collaboration accepted successfully',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Rimuovi lo spinner in caso di errore
      Navigator.pop(context);

      // Mostra alert di errore
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: black.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error accepting collaboration: $e',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          );
        },
      );
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
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadNotifications();
          },
          color: Colors.white,
          backgroundColor: const Color(0xFF2A2A2A),
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.checkmark_alt,
                              color: Colors.white),
                          onPressed: () {
                            setState(() {
                              notifications.forEach((n) => n.read = true);
                              _filterNotifications(_selectedTabIndex);
                              _markAllAsRead();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  MyTabBar(
                    tabs: const ['All', 'Collab', 'Unread'],
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: (index) {
                      setState(() => _selectedTabIndex = index);
                      _filterNotifications(index);
                    },
                  ),

                  // Content
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isLoading ? 0.0 : 1.0,
                      child: filteredNotifications.isEmpty
                          ? _buildEmptyState()
                          : _buildGroupedList(),
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
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballSpinFadeLoader,
                          colors: List.generate(
                            8,
                            (index) =>
                                Colors.white.withOpacity(1 - (index * 0.1)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 1,
        onTap: onTap,
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedTabIndex) {
      case 0:
        return 'No notifications yet';
      case 1:
        return 'No collaboration requests';
      case 2:
        return 'No unread notifications';
      default:
        return 'No notifications to show';
    }
  }

  Future<void> _deleteNotification(NotificationEureka notification) async {
    final NotificationEureka deletedNotification = notification;
    final int deletedIndex = notifications.indexOf(notification);

    setState(() {
      notifications.removeWhere((n) => n.id == notification.id);
      _filterNotifications(_selectedTabIndex);
    });

    try {
      await widget.notificationHelper
          .deleteNotification(notification.id, widget.userData.uid);
    } catch (e) {
      setState(() {
        if (deletedIndex >= 0) {
          notifications.insert(deletedIndex, deletedNotification);
          _filterNotifications(_selectedTabIndex);
        }
      });
      debugPrint('Error deleting notification: $e');
    }
  }
}
