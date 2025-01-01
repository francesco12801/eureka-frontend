import 'dart:ui';
import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/collaborate/collaborate_manager.dart';
import 'package:eureka_final_version/frontend/api/meeting/meeting_manager.dart';
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
  final MeetingManager meetingManager = MeetingManager();
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
                  notification.type == 'COLLAB_DECLINED' ||
                  notification.type == 'MEETING_REQUEST')
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
    if (notification.type == 'MEETING_REQUEST') {
      final bool isOwner = notification.fromUserId == widget.userData.uid;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.purple.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
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
                          ? Border.all(color: Colors.purple.shade400, width: 2)
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
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar,
                                    color: Colors.purple,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Meeting',
                                    style: TextStyle(
                                      color: Colors.purple,
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
            if (isOwner) // Solo il proprietario può modificare o eliminare
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          foregroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Qui la logica per modificare il meeting
                          _showScheduleCallDialog(context, notification);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.pencil),
                            SizedBox(width: 8),
                            Text('Modify'),
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
                        onPressed: () => _deleteNotification(notification),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.trash),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
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
                  onPressed: () =>
                      _showScheduleCallDialog(context, notification),
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

  void _showScheduleCallDialog(
      BuildContext context, NotificationEureka notificationData) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.2),
                          Colors.blueAccent.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      CupertinoIcons.video_camera_solid,
                      color: Color(0xFF8B5CF6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Schedule Video Call',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.xmark, size: 20),
                      color: Colors.white.withOpacity(0.8),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Title Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none,
                    hintText: 'Call Title',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.textformat,
                      color: Colors.white.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Date & Time Row
              Row(
                children: [
                  // Date Picker
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.blue,
                                surface: Color(0xFF1A1A1A),
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: const Color(0xFF1A1A1A),
                            ),
                            child: child!,
                          ),
                        );
                        if (date != null) {
                          selectedDate = date;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.calendar,
                              color: Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time Picker
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFF8B5CF6),
                                surface: Color(0xFF1A1A1A),
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: const Color(0xFF1A1A1A),
                            ),
                            child: child!,
                          ),
                        );
                        if (time != null) {
                          selectedTime = time;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              color: Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedTime.format(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Notes Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: descriptionController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none,
                    hintText: 'Additional Notes',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Schedule Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await _markAsRead(notificationData);
                      // Mostra loading spinner
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Stack(
                            children: [
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/eureka_loader.gif',
                                        width: 60,
                                        height: 60,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Get ready for an amazing collaboration!',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      // Validazione input
                      if (titleController.text.isEmpty) {
                        throw Exception('Il titolo è obbligatorio');
                      }

                      String formattedDay =
                          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                      String formattedTime =
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";

                      // Debug logs
                      debugPrint(
                          '------------- DEBUG MEETING CREATION -------------');
                      debugPrint('GuestId: ${notificationData.fromUserId}');
                      debugPrint('Infos: ${descriptionController.text}');
                      debugPrint('Time: $formattedTime');
                      debugPrint('Day: $formattedDay');
                      debugPrint('Title: ${titleController.text}');
                      debugPrint(
                          'Collaborators: [${notificationData.fromUserId}, ${widget.userData.uid}]');
                      debugPrint('GenieId: ${notificationData.genieID}');
                      debugPrint(
                          '-----------------------------------------------');

                      // Usa l'istanza invece del metodo statico
                      final result = await MeetingManager.createMeeting(
                          notificationData.fromUserId,
                          descriptionController.text,
                          formattedTime,
                          formattedDay,
                          titleController.text,
                          [notificationData.fromUserId, widget.userData.uid],
                          notificationData.genieID!,
                          notificationData.collaborationId!);

                      debugPrint('Meeting creation result: $result');

                      setState(() {
                        notifications
                            .removeWhere((n) => n.id == notificationData.id);
                        _filterNotifications(_selectedTabIndex);
                      });

                      // Chiudi loading spinner e dialog
                      Navigator.of(context).pop(); // chiude loading
                      Navigator.of(context).pop(); // chiude dialog

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF1A1A1A),
                                    const Color(0xFF1A1A1A).withOpacity(0.95),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icona animata di successo
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.celebration,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Titolo
                                  const Text(
                                    'Meeting Scheduled! 🎉',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),

                                  // Messaggio motivazionale
                                  Text(
                                    'Get ready for an amazing collaboration! Your meeting is all set for ${selectedTime.format(context)} on ${selectedDate.day}/${selectedDate.month}.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),

                                  Text(
                                    'Pro tip: Take a moment to prepare your ideas and make the most of this opportunity! 💡',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),

                                  // Pulsante di chiusura
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.green,
                                          Colors.greenAccent
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: const Text(
                                        "I'm Ready!",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } catch (e, stackTrace) {
                      debugPrint('------------- ERROR DETAILS -------------');
                      debugPrint('Error: $e');
                      debugPrint('StackTrace: $stackTrace');
                      debugPrint('----------------------------------------');

                      // Chiudi loading spinner se aperto
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Errore durante la creazione del meeting: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.video_camera_solid,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Schedule Call',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
