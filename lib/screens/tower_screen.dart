import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
import '../config/game_balance.dart';
import 'battle_preparation_screen.dart';

enum FloorStatus { cleared, current, locked }

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

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProfile>(
      builder: (BuildContext context, PlayerProfile profile, _) {
        final bool hasPlantmons = profile.getTotalPlantmons() > 0;
        final int currentFloor = profile.currentTowerFloor;

        if (!hasPlantmons) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.store, size: 80, color: Colors.white38),
                  SizedBox(height: 24),
                  Text(
                    'Chưa có Plantmon nào!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Đến cửa hàng và thu thập Plantmon để bắt đầu chinh phục Tower!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: <Widget>[
            Container(
              color: const Color(0xFF0a0a0a),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: currentFloor + 5,
                itemBuilder: (BuildContext context, int index) {
                  final int floor = index + 1;
                  final FloorStatus status = _getFloorStatus(
                    floor,
                    currentFloor,
                  );
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

  void _scrollToCurrentFloor(int currentFloor) {
    final double itemHeight = 140.0;
    final int targetIndex = currentFloor - 1;
    final double targetOffset = targetIndex * itemHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  FloorStatus _getFloorStatus(int floor, int currentFloor) {
    if (floor < currentFloor) {
      return FloorStatus.cleared;
    }
    if (floor == currentFloor) {
      return FloorStatus.current;
    }
    return FloorStatus.locked;
  }

  Widget _buildFloorCard(
    BuildContext context,
    int floor,
    FloorStatus status,
    PlayerProfile profile,
  ) {
    final bool isAccessible =
        status == FloorStatus.current || status == FloorStatus.cleared;
    final int enemyCount = floor <= GameBalance.singleEnemyMaxFloor ? 1 : 2;
    final int starsEarned = GameBalance.getStarRewardForFloor(floor);

    Color? leftAccentColor;
    String statusText;
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
      child: GestureDetector(
        onTap: isAccessible ? () => _startFloor(context, floor) : null,
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
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '$floor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: <Widget>[
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusTextColor,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  '$enemyCount ${enemyCount == 1 ? 'Enemy' : 'Enemies'}',
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
                  if (isAccessible) ...<Widget>[
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFF2a2a2a), height: 1),
                    const SizedBox(height: 12),
                    if (status == FloorStatus.cleared)
                      const Row(
                        children: <Widget>[
                          Icon(Icons.history, color: Colors.orange, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Practice Mode - No rewards',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: <Widget>[
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '$starsEarned stars',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  void _startFloor(BuildContext context, int floor) {
    PlayerProfile profile = context.read<PlayerProfile>();
    bool isPracticeMode = floor < profile.currentTowerFloor;

    Navigator.push(
      context,
      MaterialPageRoute<BattlePreparationScreen>(
        builder: (_) => BattlePreparationScreen(
          floor: floor,
          isPracticeMode: isPracticeMode,
        ),
      ),
    );
  }
}
