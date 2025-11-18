import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/battle_party.dart';
import '../models/plantmon.dart';
import '../game/player_profile.dart';
import '../game/battle_state.dart';
import '../config/game_balance.dart';
import 'battle_screen.dart';

class BattlePreparationScreen extends StatefulWidget {
  final int floor;
  final bool isPracticeMode;

  const BattlePreparationScreen({
    super.key,
    required this.floor,
    this.isPracticeMode = false,
  });

  @override
  State<BattlePreparationScreen> createState() =>
      _BattlePreparationScreenState();
}

class _BattlePreparationScreenState extends State<BattlePreparationScreen> {
  final List<int> _selectedSlotIndices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Floor ${widget.floor}'),
        backgroundColor: const Color(0xFF1a1a1a),
      ),
      backgroundColor: const Color(0xFF0a0a0a),
      body: Consumer<PlayerProfile>(
        builder: (context, profile, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildEnemyPreview(),
                    const SizedBox(height: 12),
                    _buildRewardPreview(),
                    const SizedBox(height: 16),
                    _buildPartySelection(profile),
                  ],
                ),
              ),
              _buildStartButton(profile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnemyPreview() {
    final (enemyCount, minLevel, maxLevel) = GameBalance.getFloorInfoForFloor(
      widget.floor,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enemy Info',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$enemyCount ${enemyCount == 1 ? 'Enemy' : 'Enemies'} • Lv $minLevel-$maxLevel',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPreview() {
    if (widget.isPracticeMode) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1e1e1e),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.history, color: Colors.orange, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice Mode',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'No rewards will be earned',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final int starsEarned = GameBalance.getStarRewardForFloor(widget.floor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rewards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text(
                '$starsEarned Stars',
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartySelection(PlayerProfile profile) {
    final plantedSlots = <int>[];
    for (int i = 0; i < profile.slots.length; i++) {
      if (profile.getPlantmon(i) != null) {
        plantedSlots.add(i);
      }
    }

    final maxPartySize = GameBalance.getMaxPartySizeForFloor(widget.floor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Party (1-$maxPartySize)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...plantedSlots.map((slotIndex) {
          final plantmon = profile.getPlantmon(slotIndex)!;

          final isSelected = _selectedSlotIndices.contains(slotIndex);
          return _buildPlantmonCard(plantmon, slotIndex, isSelected);
        }),
      ],
    );
  }

  Widget _buildPlantmonCard(Plantmon plantmon, int slotIndex, bool isSelected) {
    final maxPartySize = GameBalance.getMaxPartySizeForFloor(widget.floor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: isSelected
              ? const BorderSide(color: Color(0xFF66BB6A), width: 3)
              : BorderSide.none,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedSlotIndices.remove(slotIndex);
            } else {
              if (_selectedSlotIndices.length < maxPartySize) {
                _selectedSlotIndices.add(slotIndex);
              }
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildPlantmonImage(plantmon),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantmon.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lv ${plantmon.level} • HP: ${plantmon.hp}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatBadge('ATK: ${plantmon.attack}'),
                        const SizedBox(width: 6),
                        _buildStatBadge('DEF: ${plantmon.defense}'),
                        const SizedBox(width: 6),
                        _buildStatBadge('SPD: ${plantmon.speed}'),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF66BB6A),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white54, fontSize: 12),
    );
  }

  Widget _buildStartButton(PlayerProfile profile) {
    final canStart = _selectedSlotIndices.isNotEmpty;
    final maxPartySize = GameBalance.getMaxPartySizeForFloor(widget.floor);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        border: Border(top: BorderSide(color: Color(0xFF2a2a2a), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: canStart ? () => _startBattle(profile) : null,

            style: ElevatedButton.styleFrom(
              backgroundColor: canStart
                  ? const Color(0xFF66BB6A)
                  : const Color(0xFF2a2a2a),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              canStart
                  ? 'Start Battle (${_selectedSlotIndices.length}/$maxPartySize)'
                  : 'Select at least 1 Plantmon',
              style: TextStyle(
                color: canStart ? Colors.white : Colors.white38,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startBattle(PlayerProfile profile) {
    final party = BattleParty(
      plantmonSlotIndices: List.from(_selectedSlotIndices),
    );

    final battleState = BattleState();
    final plantmons = _selectedSlotIndices
        .map((i) => profile.getPlantmon(i)!)
        .toList();

    battleState.startBattleForTower(plantmons, widget.floor);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BattleState>.value(
          value: battleState,
          child: BattleScreen(
            slotIndex: _selectedSlotIndices.first,
            party: party,
            floor: widget.floor,
            isPracticeMode: widget.isPracticeMode,
          ),
        ),
      ),
    );
  }

  Widget _buildPlantmonImage(Plantmon plantmon) {
    final typeCapitalized = plantmon.type.replaceFirst(
      plantmon.type[0],
      plantmon.type[0].toUpperCase(),
    );
    final spritePath = 'assets/images/plants/$typeCapitalized.png';

    return Image.asset(spritePath, fit: BoxFit.contain);
  }
}
