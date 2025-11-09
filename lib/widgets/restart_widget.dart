import 'package:flutter/material.dart';

/// A widget that allows the entire app to be restarted by rebuilding
/// the widget tree with a new key.
class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  /// Restarts the app by rebuilding the entire widget tree.
  /// This should be called after clearing persistent storage to ensure
  /// all providers are re-initialized with fresh data.
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
