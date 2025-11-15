import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
import '../models/care_resources.dart';
import 'garden_screen_flame_host.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0f1a0f), Color(0xFF132312)],
            ),
          ),
          child: Consumer<PlayerProfile>(
            builder: (context, profile, child) {
              final slots = profile.slots;

              if (slots.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có slot nào',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return child!;
            },
            child: const GardenFlameHost(key: Key('garden_flame_host')),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: Consumer<PlayerProfile>(
              builder: (context, profile, _) {
                final resources = profile.careResources;
                final waterRegen = resources.getWaterRegenTimeRemaining();
                final fertRegen = resources.getFertilizerRegenTimeRemaining();

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e1e1e).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2a2a2a),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Water resource
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Color(0xFF42A5F5),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${resources.waterCharges}/5',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (waterRegen != null && resources.waterCharges < 5)
                                Text(
                                  CareResources.formatDuration(waterRegen),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Fertilizer resource
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_florist,
                            color: Color(0xFF66BB6A),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${resources.fertilizerCharges}/5',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (fertRegen != null && resources.fertilizerCharges < 5)
                                Text(
                                  CareResources.formatDuration(fertRegen),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
