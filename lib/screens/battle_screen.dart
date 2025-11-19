import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/battle_state.dart';
import '../game/player_profile.dart';
import '../models/plantmon.dart';
import '../models/timeline_entity.dart';
import '../widgets/timeline_bar_widget.dart';
import '../widgets/battle_result_widgets.dart';
import 'package:flame/game.dart';
import '../game/battle_canvas_game.dart';
import '../config/game_balance.dart';

class BattleScreen extends StatefulWidget {
  final List<Plantmon> initialParty;
  final int floor;
  final bool isPracticeMode;

  const BattleScreen({
    super.key,
    required this.initialParty,
    required this.floor,
    this.isPracticeMode = false,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late final BattleCanvasGame _battleCanvasGame;

  @override
  void initState() {
    super.initState();
    final battleState = context.read<BattleState>();
    _battleCanvasGame = BattleCanvasGame(battleState);

    battleState.onNotification = (message, entityId, {required byPlayer}) {
      _battleCanvasGame.showNotification(message, entityId, byPlayer: byPlayer);
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.castle, size: 20),
            const SizedBox(width: 8),
            Text('Floor ${widget.floor}'),
            const SizedBox(width: 12),
            Text(
              '|',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.38)),
            ),
            const SizedBox(width: 12),
            Consumer<BattleState>(
              builder: (context, battleState, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('Turn ${battleState.turnCount}')],
                );
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF0a0a0a),
        child: Consumer<BattleState>(
          builder: (context, battleState, _) {
            if (battleState.isBattleOver) {
              return Stack(
                children: [
                  Column(
                    children: [
                      const TimelineBarWidget(),
                      Expanded(
                        flex: 1,
                        child: GameWidget(game: _battleCanvasGame),
                      ),
                      Expanded(flex: 1, child: _buildBottomPanel(battleState)),
                    ],
                  ),
                  _buildResultModal(context, battleState),
                ],
              );
            }

            return Column(
              children: [
                // Timeline bar at top
                const TimelineBarWidget(),
                // Battle canvas (50% of remaining space)
                Expanded(flex: 1, child: GameWidget(game: _battleCanvasGame)),
                // Status rows + Action buttons (50% of remaining space)
                Expanded(flex: 1, child: _buildBottomPanel(battleState)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<BattleState>(
        builder: (context, battleState, _) {
          final bool isFast = battleState.timeScale > 1.0;
          return FloatingActionButton(
            heroTag: 'battleSpeedFab',
            backgroundColor: isFast
                ? const Color(0xFFD32F2F)
                : Colors.grey.shade800,
            onPressed: () {
              battleState.setTimeScale(isFast ? 1.0 : 3.0);
            },
            child: Text(
              isFast ? '3x' : '1x',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomPanel(BattleState battleState) {
    final playerEntities = battleState.playerEntities;
    final selectedId = battleState.selectedEntityId;
    TimelineEntity? selectedEntity;
    if (selectedId != null) {
      selectedEntity = battleState.timeline.firstWhere(
        (entity) => entity.id == selectedId,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          _buildPlantmonStatusRow(playerEntities, selectedId),
          const SizedBox(height: 12),
          if (battleState.isSelectingTarget)
            _buildTargetInstruction(battleState.pendingActionType)
          else if (selectedEntity != null)
            _buildActionButtons(battleState, selectedEntity)
          else
            _buildWaitingLabel(),
        ],
      ),
    );
  }

  Widget _buildPlantmonStatusRow(
    List<TimelineEntity> playerEntities,
    String? selectedId,
  ) {
    return Row(
      children: playerEntities.map((entity) {
        final isSelected = selectedId == entity.id;
        final isCasting = entity.isCasting;
        final isDefending = entity.isDefending;

        // Border color logic
        final borderColor = isCasting
            ? Colors.red
            : isDefending
            ? Colors.blue
            : isSelected
            ? const Color(0xFF66BB6A)
            : Colors.transparent;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: entity == playerEntities.first ? 0 : 6,
              right: entity == playerEntities.last ? 0 : 6,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1e1e1e),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: (isCasting || isDefending) ? 2 : 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Level
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entity.plantmon.name,
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: entity.isDead ? 0.4 : 1.0,
                          ),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Lv${entity.plantmon.level}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 1),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // HP Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (entity.plantmon.hp / entity.plantmon.maxHp)
                              .clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.red.shade900,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entity.plantmon.hp}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // MP Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (entity.mp / 100).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.blue.shade900,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entity.mp}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(
    BattleState battleState,
    TimelineEntity selectedEntity,
  ) {
    final canUseHeavyAttack =
        selectedEntity.mp >= GameBalance.heavyAttackMpCost;

    Widget buildActionButton({
      required String label,
      required IconData icon,
      required VoidCallback? onPressed,
      Color color = Colors.blue,
      bool enabled = true,
    }) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? color : Colors.grey.shade800,
            disabledBackgroundColor: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: enabled ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: enabled ? Colors.white : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ATTACK Button
        buildActionButton(
          label: 'ATTACK',
          icon: Icons.flash_on,
          onPressed: () => battleState.queueAction(ActionType.attack),
          color: const Color(0xFFD32F2F),
          enabled: true,
        ),
        const SizedBox(height: 10),
        // DEFEND Button
        buildActionButton(
          label: 'DEFEND',
          icon: Icons.shield,
          onPressed: () => battleState.queueAction(ActionType.defend),
          color: const Color(0xFF1976D2),
          enabled: true,
        ),
        const SizedBox(height: 10),
        // HEAVY ATTACK Button
        buildActionButton(
          label: canUseHeavyAttack
              ? 'HEAVY ATTACK'
              : 'HEAVY ATTACK (${GameBalance.heavyAttackMpCost} MP)',
          icon: Icons.auto_awesome,
          onPressed: () => battleState.queueAction(ActionType.heavyAttack),
          color: const Color(0xFF7B1FA2),
          enabled: canUseHeavyAttack,
        ),
      ],
    );
  }

  Widget _buildTargetInstruction(ActionType? pendingAction) {
    final verb = pendingAction == ActionType.heavyAttack
        ? 'HEAVY ATTACK'
        : 'ATTACK';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Tap an enemy sprite to choose a target for your $verb.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWaitingLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Waiting for timeline...',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildResultModal(BuildContext context, BattleState battleState) {
    final result = battleState.getBattleResult();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.7 * value),
          child: Transform.scale(
            scale: value,
            child: Center(child: child),
          ),
        );
      },
      child: result.isVictory
          ? VictoryScreenWidget(
              message: result.message,
              expGained: result.expGained,
              starsEarned: result.starsEarned,
              isPracticeMode: widget.isPracticeMode,
              onContinue: () async =>
                  await _handleBattleEnd(context, battleState, result),
            )
          : DefeatScreenWidget(
              onContinue: () async =>
                  await _handleBattleEnd(context, battleState, result),
            ),
    );
  }

  Future<void> _handleBattleEnd(
    BuildContext context,
    BattleState battleState,
    result,
  ) async {
    final profile = context.read<PlayerProfile>();

    // Only give rewards if NOT practice mode
    if (!widget.isPracticeMode) {
      await profile.addExp(result.expGained);
      await profile.addStars(result.starsEarned);

      if (result.isWin) {
        await profile.incrementTowerFloor();
      }

      // Update all party members with exp
      for (final plantmon in widget.initialParty) {
        final updatedPlayer = plantmon.addExp(result.expGained);
        await profile.updatePlantmon(updatedPlayer);
      }

      await profile.updatePlantmonCount(profile.getTotalPlantmons());
      await profile.unlockSlotsForLevel(profile.level);
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
