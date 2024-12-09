import 'package:eureka_final_version/frontend/models/constant/notification.dart';
import 'package:flutter/material.dart';

class NotificationGroup extends StatefulWidget {
  final String title;
  final List<NotificationEureka> notifications;
  final Function(NotificationEureka) onTap;
  final Function(NotificationEureka) onLongPress;
  final Widget Function(NotificationEureka) buildNotificationTile;

  const NotificationGroup({
    Key? key,
    required this.title,
    required this.notifications,
    required this.onTap,
    required this.onLongPress,
    required this.buildNotificationTile,
  }) : super(key: key);

  @override
  State<NotificationGroup> createState() => _NotificationGroupState();
}

class _NotificationGroupState extends State<NotificationGroup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = _controller.drive(
      Tween<double>(begin: 0.0, end: 0.5).chain(
        CurveTween(curve: Curves.easeIn),
      ),
    );
    _heightFactor = _controller.drive(
      CurveTween(curve: Curves.easeIn),
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildGroupHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          RotationTransition(
            turns: _iconTurns,
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.notifications.length}',
              style: TextStyle(
                color: Colors.blue.shade400,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _handleTap,
          child: _buildGroupHeader(),
        ),
        AnimatedBuilder(
          animation: _controller.view,
          builder: (BuildContext context, Widget? child) {
            return ClipRect(
              child: Align(
                heightFactor: _heightFactor.value,
                child: child,
              ),
            );
          },
          child: Column(
            children: widget.notifications.map((notification) {
              return GestureDetector(
                onTap: () => widget.onTap(notification),
                onLongPress: () => widget.onLongPress(notification),
                child: widget.buildNotificationTile(notification),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
