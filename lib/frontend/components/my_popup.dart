import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModernAlert {
  static OverlayEntry? _currentOverlay;
  static bool _isVisible = false;

  static void show({
    required String message,
    required bool isSuccess,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Se c'è già un alert visibile, rimuovilo
    if (_isVisible) {
      hide();
    }

    _isVisible = true;

    // Crea l'overlay entry
    _currentOverlay = OverlayEntry(
      builder: (BuildContext context) => SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isSuccess ? Colors.green : Colors.red)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSuccess
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.xmark_circle_fill,
                          color: isSuccess ? Colors.green : Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    try {
      // Inserisci l'overlay
      final overlay =
          Overlay.of(NavigationService.navigatorKey.currentContext!);
      overlay.insert(_currentOverlay!);

      // Rimuovi automaticamente dopo la durata specificata
      Future.delayed(duration, () {
        hide();
      });
    } catch (e) {
      debugPrint('Error showing ModernAlert: $e');
    }
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _isVisible = false;
  }
}

// Navigation service to store global navigator key
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
