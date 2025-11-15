import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/garden_game.dart';
import '../game/player_profile.dart';
import '../models/slot.dart';
import 'plant_view_screen.dart';

class GardenFlameHost extends StatefulWidget {
  const GardenFlameHost({super.key});

  @override
  State<GardenFlameHost> createState() => _GardenFlameHostState();
}

class _GardenFlameHostState extends State<GardenFlameHost> {
  late GardenGame game;

  @override
  void initState() {
    super.initState();
    final profile = context.read<PlayerProfile>();
    _initializeGame(profile.getUnlockedSlots());
  }

  void _initializeGame(List<Slot> slots) {
    game = GardenGame(
      slots: slots,
      onTapSlot: (slotIndex) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlantViewScreen(slotIndex: slotIndex),
          ),
        );
      },
      onTapPlant: (slotIndex) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlantViewScreen(slotIndex: slotIndex),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProfile>(
      builder: (context, profile, _) {
        final currentSlots = profile.getUnlockedSlots();

        game.updateSlots(currentSlots);

        return GameWidget(game: game);
      },
    );
  }

  @override
  void dispose() {
    game.removeFromParent();
    super.dispose();
  }
}
