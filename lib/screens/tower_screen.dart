import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
import '../game/garden_state.dart';
import '../config/game_balance.dart';
import 'battle_preparation_screen.dart';

class TowerScreen extends StatefulWidget {
  const TowerScreen({super.key});

  @override
  State<TowerScreen> createState() => _TowerScreenState();
}

class _TowerScreenState extends State<TowerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentFloor(int currentFloor) {
    final itemHeight = 140.0;
    final targetIndex = currentFloor - 1;
    final targetOffset = targetIndex * itemHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerProfile, GardenState>(
      builder: (context, profile, gardenState, _) {
        final hasPlantmons = gardenState.getTotalPlantmons() > 0;
        final currentFloor = profile.towerFloor;

        if (!hasPlantmons) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.white38),
                  SizedBox(height: 24),
                  Text(
                    'No Plantmon Yet!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Grow plants in the Garden first',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            Container(
              color: const Color(0xFF0a0a0a),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: currentFloor + 5,
                itemBuilder: (context, index) {
                  final floor = index + 1;
                  final status = _getFloorStatus(floor, currentFloor);
                  return _buildFloorCard(context, floor, status, profile);
                },
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => _scrollToCurrentFloor(currentFloor),
                backgroundColor: const Color(0xFF66BB6A),
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  FloorStatus _getFloorStatus(int floor, int currentFloor) {
    if (floor < currentFloor) return FloorStatus.cleared;
    if (floor == currentFloor) return FloorStatus.current;
    return FloorStatus.locked;
  }

  Widget _buildFloorCard(
    BuildContext context,
    int floor,
    FloorStatus status,
    PlayerProfile profile,
  ) {
    final isAccessible =
        status == FloorStatus.current || status == FloorStatus.cleared;
    final (enemyCount, minLevel, maxLevel) = _getFloorInfo(floor);
    final (expMin, expMax, starsEarned) = _calculateReward(floor);

    Color? leftAccentColor;
    String? statusText;
    Color statusTextColor;
    double opacity = 1.0;

    switch (status) {
      case FloorStatus.cleared:
        leftAccentColor = const Color(0xFF525252);
        statusText = 'Cleared';
        statusTextColor = const Color(0xFF999999);
        break;
      case FloorStatus.current:
        leftAccentColor = const Color(0xFF66BB6A);
        statusText = 'Challenge';
        statusTextColor = const Color(0xFF66BB6A);
        break;
      case FloorStatus.locked:
        statusText = 'Locked';
        statusTextColor = Colors.white38;
        opacity = 0.5;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isAccessible ? () => _startFloor(context, floor) : null,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1e1e1e),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: leftAccentColor != null
                    ? BorderSide(color: leftAccentColor, width: 3)
                    : BorderSide.none,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$floor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '$enemyCount ${enemyCount == 1 ? 'Enemy' : 'Enemies'}',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '•',
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Lv $minLevel-$maxLevel',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isAccessible)
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white24,
                          size: 16,
                        ),
                    ],
                  ),
                  if (isAccessible) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFF2a2a2a), height: 1),
                    const SizedBox(height: 12),
                    if (status == FloorStatus.cleared)
                      const Row(
                        children: [
                          Icon(Icons.history, color: Colors.orange, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Practice Mode - No rewards',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          _buildRewardInfo('$expMin-$expMax EXP'),
                          const SizedBox(width: 16),
                          _buildRewardInfo('⭐ $starsEarned Stars'),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardInfo(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  (int, int, int) _getFloorInfo(int floor) {
    final enemyCount = floor <= GameBalance.singleEnemyMaxFloor ? 1 : 2;
    final minLevel = floor;
    final maxLevel = floor + 2;
    return (enemyCount, minLevel, maxLevel);
  }

  (int, int, int) _calculateReward(int floor) {
    final multiplier = 1 + (floor * 0.15);
    final expMin = (40 * multiplier).round();
    final expMax = (80 * multiplier).round();
    
    int starsEarned;
    if (floor <= 10) {
      starsEarned = 3;
    } else if (floor <= 20) {
      starsEarned = 5;
    } else if (floor <= 50) {
      starsEarned = 10;
    } else if (floor <= 100) {
      starsEarned = 15;
    } else {
      starsEarned = 20;
    }
    
    if (floor % 10 == 0) {
      starsEarned += 5;
    }
    
    return (expMin, expMax, starsEarned);
  }

  void _startFloor(BuildContext context, int floor) {
    final profile = context.read<PlayerProfile>();
    final isPracticeMode = floor < profile.towerFloor;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BattlePreparationScreen(
          floor: floor,
          isPracticeMode: isPracticeMode,
        ),
      ),
    );
  }
}

enum FloorStatus { cleared, current, locked }
