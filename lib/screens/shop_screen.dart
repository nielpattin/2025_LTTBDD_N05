import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
import '../game/garden_state.dart';
import '../data/shop_data.dart';
import '../data/plants_data.dart';
import '../data/ball_tiers.dart';
import '../models/plantmon.dart';
import '../models/shop_item.dart';
import '../models/seed.dart';
import '../widgets/notification_bar.dart' as notification;

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerProfile, GardenState>(
      builder: (context, profile, gardenState, _) {
        final List<Widget> items = [];

        for (final item in shopInventory) {
          items.add(_buildShopItemCard(context, item));
        }

        return Container(
          color: const Color(0xFF0a0a0a),
          child: ListView(padding: const EdgeInsets.all(16), children: items),
        );
      },
    );
  }

  Widget _buildShopItemCard(BuildContext context, item) {
    return Consumer<PlayerProfile>(
      builder: (context, profile, _) {
        final starCost = item.starCost ?? 0;
        final canAffordStars = profile.canAffordStars(starCost);
        final isUnlocked = profile.towerFloor >= (item.unlockFloor ?? 1);
        final canPurchase = canAffordStars && isUnlocked;

        Color getTierColor() {
          switch (item.tier) {
            case BallTier.common:
              return const Color(0xFF66BB6A);
            case BallTier.rare:
              return const Color(0xFF42A5F5);
            case BallTier.legendary:
              return const Color(0xFFAB47BC);
            default:
              return const Color(0xFF66BB6A);
          }
        }

        String getBallImagePath() {
          switch (item.tier) {
            case BallTier.common:
              return 'assets/images/shop/Ball_1.png';
            case BallTier.rare:
              return 'assets/images/shop/Ball_2.png';
            case BallTier.legendary:
              return 'assets/images/shop/Ball_3.png';
            default:
              return 'assets/images/shop/Ball_1.png';
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: const Color(0xFF1e1e1e),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: getTierColor().withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: getTierColor().withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Image.asset(
                            getBallImagePath(),
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.circle,
                                color: getTierColor(),
                                size: 32,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: getTierColor(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!isUnlocked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Unlock at Floor ${item.unlockFloor}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canPurchase
                            ? () => _handlePurchase(context, item)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canPurchase
                              ? getTierColor()
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              canAffordStars
                                  ? 'BUY $starCost STARS'
                                  : 'NEED $starCost STARS',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePurchase(BuildContext context, item) {
    final profile = context.read<PlayerProfile>();
    final gardenState = context.read<GardenState>();

    final starCost = item.starCost ?? 0;

    if (!profile.canAffordStars(starCost)) {
      notification.NotificationBar.error(
        context,
        'Not enough stars! Need $starCost stars',
      );
      return;
    }

    final isUnlocked = profile.towerFloor >= (item.unlockFloor ?? 1);
    if (!isUnlocked) {
      notification.NotificationBar.error(
        context,
        'Reach Floor ${item.unlockFloor} to unlock!',
      );
      return;
    }

    if (!gardenState.hasEmptySlot()) {
      notification.NotificationBar.error(
        context,
        'No slots! Level up for more space',
      );
      return;
    }

    _showSeedBallPicker(context, item);
  }

  void _showSeedBallPicker(BuildContext context, ShopItem item) {
    final plantmons = _generateSeedBallByTier(item.tier!);

    String getBallImageForTier(BallTier tier) {
      switch (tier) {
        case BallTier.common:
          return 'assets/images/shop/Ball_1.png';
        case BallTier.rare:
          return 'assets/images/shop/Ball_2.png';
        case BallTier.legendary:
          return 'assets/images/shop/Ball_3.png';
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e1e1e),
          title: Text(
            'Choose 1 of 3 Plantmon',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _getTierColorByTier(item.tier!),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(plantmons.length, (index) {
                    final plantmon = plantmons[index];
                    final ballImage = getBallImageForTier(item.tier!);

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _handleBallSelected(context, plantmon, item);
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                          border: Border.all(
                            color: _getTierColorByTier(item.tier!),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            ballImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.circle,
                                color: _getTierColorByTier(item.tier!),
                                size: 50,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Plantmon> _generateSeedBallByTier(BallTier tier) {
    final pool = List<String>.from(getPlantmonPoolByTier(tier));
    pool.shuffle();
    final selectedNames = pool.take(3).toList();

    Rarity rarity;
    switch (tier) {
      case BallTier.common:
        rarity = Rarity.common;
        break;
      case BallTier.rare:
        rarity = Rarity.uncommon;
        break;
      case BallTier.legendary:
        rarity = Rarity.rare;
        break;
    }

    return selectedNames.map((name) {
      final spritePath = 'assets/images/plants/$name.png';
      return generateRandomPlantmon(
        sprite: spritePath,
        rarity: rarity,
        level: 1,
      );
    }).toList();
  }

  Color _getTierColorByTier(BallTier tier) {
    switch (tier) {
      case BallTier.common:
        return const Color(0xFF66BB6A);
      case BallTier.rare:
        return const Color(0xFF42A5F5);
      case BallTier.legendary:
        return const Color(0xFFAB47BC);
    }
  }

  Future<void> _handleBallSelected(
    BuildContext context,
    Plantmon plantmon,
    ShopItem item,
  ) async {
    final starCost = item.starCost ?? 0;

    final profile = context.read<PlayerProfile>();

    try {
      await profile.spendStars(starCost);

      if (!context.mounted) return;

      _showPlantmonDetail(context, plantmon);

      if (!context.mounted) return;

      _selectPlantmon(context, plantmon);

      if (context.mounted) {
        notification.NotificationBar.success(
          context,
          '${plantmon.name} added to Garden!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        notification.NotificationBar.error(context, 'Purchase error: $e');
      }
    }
  }

  void _showPlantmonDetail(BuildContext context, Plantmon plantmon) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (detailContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1e1e1e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Plantmon Name
                  Text(
                    plantmon.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Plantmon Image (Zoomed)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF66BB6A),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF2a2a2a),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildPlantmonImage(plantmon),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Base Stats
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a2a),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Base Stats',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow('HP', plantmon.hp, 100),
                        _buildStatRow('ATK', plantmon.attack, 150),
                        _buildStatRow('DEF', plantmon.defense, 150),
                        _buildStatRow('SPD', plantmon.speed, 150),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OK Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(detailContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, int value, int maxValue) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: const Color(0xFF3a3a3a),
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 0.7
                      ? const Color(0xFF66BB6A)
                      : percentage > 0.4
                      ? Colors.yellow
                      : Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text('$value', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantmonImage(Plantmon plantmon) {
    final typeCapitalized = plantmon.type.replaceFirst(
      plantmon.type[0],
      plantmon.type[0].toUpperCase(),
    );
    final spritePath = 'assets/images/plants/$typeCapitalized.png';

    return Image.asset(
      spritePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_not_supported,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                plantmon.type,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectPlantmon(BuildContext context, Plantmon plantmon) async {
    final gardenState = context.read<GardenState>();
    final emptySlots = gardenState.getEmptySlots();

    if (emptySlots.isEmpty) {
      if (context.mounted) {
        notification.NotificationBar.error(
          context,
          'No slots! Level up or buy slot expansion',
        );
      }
      return;
    }

    try {
      await gardenState.plantInSlot(emptySlots.first.index, plantmon);

      if (!context.mounted) {
        return;
      }

      final profile = context.read<PlayerProfile>();
      await profile.updatePlantmonCount(gardenState.getTotalPlantmons());
    } catch (e) {
      if (context.mounted) {
        notification.NotificationBar.error(context, 'Purchase error: $e');
      }
    }
  }
}
