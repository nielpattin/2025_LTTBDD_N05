import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    // Unlock slots after first frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final profile = context.read<PlayerProfile>();
      await profile.unlockSlotsForLevel(profile.level);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProfile>(
      builder: (context, profile, _) {
        final nextSlot = profile.getNextLockedSlot();

        return Container(
          color: const Color(0xFF0a0a0a),
          child: ListView(
            padding: const EdgeInsets.all(16),
             children: [
              _buildPlayerCard(profile),
              const SizedBox(height: 16),
                    _buildSlotsCard(
                      profile,
                      nextSlot,
                      context,
                    ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerCard(PlayerProfile profile) {
    return Card(
      elevation: 0,
      color: const Color(0xFF1e1e1e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF2a2a2a),
              child: const Icon(Icons.person, size: 60, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            const Text(
              'Player',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Level ${profile.level}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Experience',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${profile.exp} / ${profile.expToNextLevel}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: profile.expProgress,
                    backgroundColor: const Color(0xFF2a2a2a),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Streak',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStreakColor(profile.careStreak)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStreakColor(profile.careStreak)
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: _getStreakColor(profile.careStreak),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.careStreak}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _getStreakColor(profile.careStreak),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsCard(
     PlayerProfile profile,
     nextSlot,
     BuildContext context,
   ) {
     final unlockedCount = profile.getUnlockedSlots().length;
     final totalPlantmons = profile.getTotalPlantmons();


    return Card(
      elevation: 0,
      color: const Color(0xFF1e1e1e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.grid_view, color: Colors.white54, size: 20),
                SizedBox(width: 8),
                Text(
                  'Garden Slots',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                   'Unlocked',
                   '$unlockedCount / ${profile.maxSlots}',

                  Icons.lock_open,
                ),
                _buildStatItem('Growing', '$totalPlantmons', Icons.eco),
                _buildStatItem(
                  'Empty',
                  '${unlockedCount - totalPlantmons}',
                  Icons.add_circle_outline,
                ),
              ],
            ),
            if (nextSlot != null && !nextSlot.isUnlocked) ...[
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF2a2a2a), height: 1),
              const SizedBox(height: 16),
              const Text(
                'Next Slot',
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),
              const SizedBox(height: 8),
              if (profile.level >= nextSlot.unlockLevel)
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Will unlock automatically on reload!',
                      style: TextStyle(
                        color: Color(0xFF66BB6A),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              else ...[
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white54, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Required: Level ${nextSlot.unlockLevel}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: profile.level / nextSlot.unlockLevel,
                    backgroundColor: const Color(0xFF2a2a2a),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white38),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${nextSlot.unlockLevel - profile.level} more levels',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.white54),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }

  Color _getStreakColor(int streak) {
    if (streak == 0) return Colors.white38;
    if (streak >= 7) return const Color(0xFFFFD700); // Gold for hot streaks
    return const Color(0xFFFF6B35); // Orange for active streaks
  }
}
