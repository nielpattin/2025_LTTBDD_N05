import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
import '../models/plantmon.dart';
import '../models/care_resources.dart';
import '../services/care_service.dart';
import '../providers/rewards_state.dart';
import '../widgets/notification_bar.dart' as notification;

class PlantViewScreen extends StatelessWidget {
  final int slotIndex;

  const PlantViewScreen({super.key, required this.slotIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2a2a2a), height: 1),
        ),
      ),
      body: Container(
        color: const Color(0xFF0a0a0a),
        child: Consumer<PlayerProfile>(
          builder: (context, profile, _) {
            final plantmon = profile.getPlantmon(slotIndex);

            if (plantmon == null) {
              return const Center(
                child: Text(
                  'Plantmon not found',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // TOP SECTION: Plantmon + Stats
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: _buildPlantmonCard(plantmon)),
                      const SizedBox(width: 12),
                      Expanded(flex: 3, child: _buildStatsCard(plantmon)),
                    ],
                  ),
                ),
                // MIDDLE SECTION: Care (single column)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _buildCareCard(plantmon),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlantmonCard(Plantmon plantmon) {
    final expProgress = plantmon.exp / plantmon.expToNextLevel;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // EXP Label
          Text(
            'EXP: ${plantmon.exp}/${plantmon.expToNextLevel}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // EXP Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: expProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFF2a2a2a),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF66BB6A),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            height: 60,
            child: _buildPlantmonImageSmall(plantmon),
          ),
          const SizedBox(height: 8),
          Text(
            plantmon.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Plantmon plantmon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Level, Attack
          Row(
            children: [
              Expanded(
                child: _buildCompactStatTile(
                  'Level',
                  '${plantmon.level}',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildCompactStatTile(
                  'Attack',
                  '${plantmon.attack}',
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Row 2: Defense
          Row(
            children: [
              Expanded(
                child: _buildCompactStatTile(
                  'Defense',
                  '${plantmon.defense}',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Row 3: HP (full width)
          Row(
            children: [
              Expanded(
                child: _buildCompactStatTile(
                  'HP',
                  '${plantmon.hp}',
                  Colors.pink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareCard(Plantmon plantmon) {
    return Consumer<PlayerProfile>(
      builder: (context, profile, _) {
        final resources = profile.careResources;
        final waterExp = CareService.getWaterExpReward(plantmon);
        final fertExp = CareService.getFertilizerExpReward(plantmon);
        final canWater = resources.canUseWater();
        final canFert = resources.canUseFertilizer();
        final waterRegen = resources.getWaterRegenTimeRemaining();
        final fertRegen = resources.getFertilizerRegenTimeRemaining();

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e1e),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Care Actions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.water_drop,
                          color: Color(0xFF42A5F5),
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${resources.waterCharges}/5',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (waterRegen != null && resources.waterCharges < 5)
                          Text(
                            CareResources.formatDuration(waterRegen),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                          )
                        else
                          const SizedBox(height: 15),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canWater
                                ? () async {
                                    await _handleWaterAction(context, plantmon);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canWater
                                  ? const Color(0xFF42A5F5)
                                  : const Color(0xFF2a2a2a),
                              disabledBackgroundColor: const Color(0xFF2a2a2a),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Water',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '+$waterExp EXP',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_florist,
                          color: Color(0xFF66BB6A),
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${resources.fertilizerCharges}/5',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (fertRegen != null &&
                            resources.fertilizerCharges < 5)
                          Text(
                            CareResources.formatDuration(fertRegen),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                          )
                        else
                          const SizedBox(height: 15),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canFert
                                ? () async {
                                    await _handleFertilizerAction(
                                      context,
                                      plantmon,
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canFert
                                  ? const Color(0xFF66BB6A)
                                  : const Color(0xFF2a2a2a),
                              disabledBackgroundColor: const Color(0xFF2a2a2a),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Fertilizer',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '+$fertExp EXP',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleWaterAction(
    BuildContext context,
    Plantmon plantmon,
  ) async {
    final profile = context.read<PlayerProfile>();
    final rewards = context.read<RewardsState>();

    final updatedPlantmon = await CareService.performWater(profile, plantmon);

    if (CareService.shouldDropRareItem(updatedPlantmon)) {
      await rewards.addRareItemDrop();
      if (context.mounted) {
        notification.NotificationBar.success(
          context,
          '\ud83c\udf81 Rare item dropped during care!',
          duration: const Duration(seconds: 3),
        );
      }
    }

    await profile.updateCareStreak();

    if (updatedPlantmon.level > plantmon.level) {
      if (context.mounted) {
        _showLevelUpDialog(context, updatedPlantmon);
      }
    }

    await profile.updatePlantmonInSlot(slotIndex, updatedPlantmon);

    if (context.mounted) {
      notification.NotificationBar.success(
        context,
        '\ud83d\udca7 Watered! ${plantmon.name} gained +10 EXP',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _handleFertilizerAction(
    BuildContext context,
    Plantmon plantmon,
  ) async {
    final profile = context.read<PlayerProfile>();
    final rewards = context.read<RewardsState>();

    final updatedPlantmon = await CareService.performFertilize(
      profile,
      plantmon,
    );

    if (CareService.shouldDropRareItem(updatedPlantmon)) {
      await rewards.addRareItemDrop();
      if (context.mounted) {
        notification.NotificationBar.success(
          context,
          '\ud83c\udf81 Rare item dropped during care!',
          duration: const Duration(seconds: 3),
        );
      }
    }

    await profile.updateCareStreak();

    if (updatedPlantmon.level > plantmon.level) {
      if (context.mounted) {
        _showLevelUpDialog(context, updatedPlantmon);
      }
    }

    await profile.updatePlantmonInSlot(slotIndex, updatedPlantmon);

    if (context.mounted) {
      notification.NotificationBar.success(
        context,
        '\ud83c\udf31 Fertilized! ${plantmon.name} gained +10 EXP',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showLevelUpDialog(BuildContext context, Plantmon plantmon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('Level Up!', style: TextStyle(color: Colors.white)),
        content: Text(
          '${plantmon.name} reached level ${plantmon.level}!\n\nStats increased!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF66BB6A))),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantmonImageSmall(Plantmon plantmon) {
    final typeCapitalized = plantmon.type.replaceFirst(
      plantmon.type[0],
      plantmon.type[0].toUpperCase(),
    );
    final spritePath = 'assets/images/plants/$typeCapitalized.png';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        spritePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text('🌿', style: TextStyle(fontSize: 32)),
          );
        },
      ),
    );
  }
}
