import 'package:flutter/material.dart';

class NotificationBar {
  /// Show a notification bar that slides down from top and auto-dismisses with slide-up animation
  ///
  /// [context] - The build context
  /// [message] - The message to display
  /// [icon] - Optional icon widget
  /// [backgroundColor] - Background color of the notification (defaults to blue)
  /// [duration] - How long to show before auto-dismissing (defaults to 5 seconds)
  /// [textColor] - Color of the message text (defaults to white)
  static void show(
    BuildContext context,
    String message, {
    Widget? icon,
    Color backgroundColor = const Color(0xFF2196F3),
    Duration duration = const Duration(seconds: 3),
    Color textColor = Colors.white,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    bool isVisible = true;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: isVisible ? -100.0 : -150.0,
              end: isVisible ? 0.0 : -150.0,
            ),
            duration: const Duration(milliseconds: 400),
            curve: isVisible ? Curves.easeOutCubic : Curves.easeInCubic,
            builder: (context, offset, child) {
              return Transform.translate(
                offset: Offset(0, offset),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                if (!isVisible) return;
                isVisible = false;
                overlayEntry.markNeedsBuild();

                // Give animation time to complete before removing
                Future.delayed(const Duration(milliseconds: 400), () {
                  try {
                    overlayEntry.remove();
                  } catch (_) {
                    // Already removed, ignore
                  }
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        SizedBox(width: 24, height: 24, child: icon),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '✕',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (!isVisible) return;
      isVisible = false;

      // Trigger slide-up animation
      overlayEntry.markNeedsBuild();

      // Give animation time to complete before removing
      Future.delayed(const Duration(milliseconds: 400), () {
        try {
          overlayEntry.remove();
        } catch (_) {
          // Already removed, ignore
        }
      });
    });
  }

  /// Show a success notification (green background, auto-dismiss 5s)
  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
      backgroundColor: Colors.green,
      duration: duration ?? const Duration(seconds: 3),
      textColor: Colors.white,
    );
  }

  /// Show an error notification (red background, auto-dismiss 5s)
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      icon: const Icon(Icons.error, color: Colors.white, size: 20),
      backgroundColor: Colors.red,
      duration: duration,
      textColor: Colors.white,
    );
  }

  /// Show a warning notification (orange background, auto-dismiss 5s)
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      icon: const Icon(Icons.warning, color: Colors.white, size: 20),
      backgroundColor: Colors.orange,
      duration: duration,
      textColor: Colors.white,
    );
  }

  /// Show an info notification (blue background, auto-dismiss 5s)
  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      icon: const Icon(Icons.info, color: Colors.white, size: 20),
      backgroundColor: const Color(0xFF2196F3),
      duration: duration,
      textColor: Colors.white,
    );
  }
}
