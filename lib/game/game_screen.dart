import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'shipper_game.dart';
import 'hud_overlay.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: ShipperGame(),
      overlayBuilderMap: {
        ShipperGame.hudOverlayKey: (context, game) =>
            HudOverlay(game: game as ShipperGame),
      },
    );
  }
}