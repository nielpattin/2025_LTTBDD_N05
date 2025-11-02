import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class ShipperGame extends FlameGame {
  static const String hudOverlayKey = 'hudOverlay';

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  @override
  Future<void> onLoad() async {
    // Show HUD overlay when game loads
    overlays.add(hudOverlayKey);
  }
}
