import 'package:flutter/material.dart';
import 'shipper_game.dart';

class HudOverlay extends StatelessWidget {
  final ShipperGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button and menu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                  Container(),
                ],
              ),
            ),

            // Game content area
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
