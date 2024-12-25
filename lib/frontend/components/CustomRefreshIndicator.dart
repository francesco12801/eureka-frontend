import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const CustomRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isRefreshing = false;
  static const _maxDragOffset = 100.0;
  late AnimationController _arrowController;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await widget.onRefresh();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _handleRefresh,
          color: Colors.transparent,
          backgroundColor: Colors.transparent,
          strokeWidth: 0,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (!_isRefreshing &&
                  notification is ScrollUpdateNotification &&
                  notification.metrics.axis == Axis.vertical) {
                setState(() {
                  if (notification.metrics.extentBefore == 0) {
                    _dragOffset = notification.metrics.pixels
                        .abs()
                        .clamp(0.0, _maxDragOffset);
                    if (_dragOffset >= 0) {
                      _arrowController.value = _dragOffset / _maxDragOffset;
                    }
                  } else {
                    _dragOffset = 0;
                  }
                });
              } else if (notification is ScrollEndNotification &&
                  !_isRefreshing) {
                setState(() => _dragOffset = 0);
              }
              return false;
            },
            child: widget.child,
          ),
        ),
        if (_dragOffset > 0 && !_isRefreshing)
          Positioned(
            top: _dragOffset / 3,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: (_dragOffset / _maxDragOffset).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: (_dragOffset / _maxDragOffset) * 3.14,
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
