import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedFollowButton extends StatefulWidget {
  final bool isFollowing;
  final VoidCallback onPressed;

  const AnimatedFollowButton({
    Key? key,
    required this.isFollowing,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<AnimatedFollowButton> createState() => _AnimatedFollowButtonState();
}

class _AnimatedFollowButtonState extends State<AnimatedFollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    if (!widget.isFollowing) {
      setState(() {
        _showConfetti = true;
      });
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _showConfetti = false;
          });
        }
      });
    }
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_showConfetti)
          ConfettiEffect(
            onComplete: () {
              setState(() {
                _showConfetti = false;
              });
            },
          ),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onPressed,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.isFollowing
                                ? (_isHovered
                                    ? [
                                        Colors.red.withOpacity(0.3),
                                        Colors.red.withOpacity(0.2),
                                      ]
                                    : [
                                        Colors.green.withOpacity(0.3),
                                        Colors.blue.withOpacity(0.3),
                                      ])
                                : [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.2),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.isFollowing
                                ? (_isHovered
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.3))
                                : Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            if (_isHovered || widget.isFollowing)
                              BoxShadow(
                                color: widget.isFollowing
                                    ? (_isHovered
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.blue.withOpacity(0.2))
                                    : Colors.white.withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return RotationTransition(
                                  turns: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                widget.isFollowing
                                    ? (_isHovered
                                        ? CupertinoIcons.person_badge_minus
                                        : CupertinoIcons.check_mark)
                                    : CupertinoIcons.person_add,
                                color: widget.isFollowing && _isHovered
                                    ? Colors.red
                                    : Colors.white,
                                size: 18,
                                key: ValueKey<bool>(
                                    widget.isFollowing && _isHovered),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.5),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                widget.isFollowing
                                    ? (_isHovered ? 'Unfollow' : 'Following')
                                    : 'Follow',
                                key: ValueKey<String>(
                                  widget.isFollowing
                                      ? (_isHovered ? 'Unfollow' : 'Following')
                                      : 'Follow',
                                ),
                                style: TextStyle(
                                  color: widget.isFollowing && _isHovered
                                      ? Colors.red
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ConfettiEffect extends StatefulWidget {
  final VoidCallback onComplete;

  const ConfettiEffect({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Confetti> confetti = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Create confetti particles
    for (int i = 0; i < 20; i++) {
      confetti.add(Confetti(random));
    }

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: ConfettiPainter(
            _controller.value,
            confetti,
          ),
        );
      },
    );
  }
}

class Confetti {
  late double x;
  late double y;
  late Color color;
  late double size;
  late double speed;
  late double angle;

  Confetti(Random random) {
    x = random.nextDouble() * 200;
    y = random.nextDouble() * 200;
    color = Colors.primaries[random.nextInt(Colors.primaries.length)]
        .withOpacity(0.8);
    size = 3 + random.nextDouble() * 4;
    speed = 1 + random.nextDouble() * 2;
    angle = random.nextDouble() * pi * 2;
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Confetti> confetti;

  ConfettiPainter(this.progress, this.confetti);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in confetti) {
      final paint = Paint()..color = particle.color;
      final position = Offset(
        particle.x + cos(particle.angle) * progress * 100 * particle.speed,
        particle.y +
            sin(particle.angle) * progress * 100 * particle.speed +
            progress * 200 * particle.speed,
      );
      canvas.drawCircle(position, particle.size * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
