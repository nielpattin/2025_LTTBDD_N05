import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
import '../game/garden_state.dart';
import '../widgets/notification_bar.dart' as notification;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _tapCount = 0;
  bool _devToolsUnlocked = false;

  void _handleProjectInfoTap() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 3) {
        _devToolsUnlocked = true;
        if (mounted) {
          notification.NotificationBar.success(
            context,
            'Developer Tools Unlocked!',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProjectInfoCard(),
          if (_devToolsUnlocked) ...[
            const SizedBox(height: 16),
            _buildDevToolsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF1e1e1e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _handleProjectInfoTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Project Info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (_tapCount > 0 && !_devToolsUnlocked) ...[
                    const Spacer(),
                    Text(
                      '$_tapCount/3',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.code,
              'Developed by',
              'Trần Thành Long - 23010070',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.apps, 'Project', 'PlantMon Simulator'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.info, 'Version', '1.0.0'),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Care for your Plantmon daily!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white54),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDevToolsCard() {
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
                Icon(Icons.build, color: Colors.white54, size: 20),
                SizedBox(width: 8),
                Text(
                  'Developer Tools',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDevButton(
              icon: Icons.star,
              label: 'Add 100 Stars',
              color: const Color(0xFF9C27B0),
              onPressed: () => _addStars(context),
            ),
            const SizedBox(height: 8),
            _buildDevButton(
              icon: Icons.lock_open,
              label: 'Unlock +1 Slot',
              color: const Color(0xFF66BB6A),
              onPressed: () => _unlockNextSlot(context),
            ),
            const SizedBox(height: 8),
            _buildDevButton(
              icon: Icons.castle,
              label: 'Unlock All Floors',
              color: const Color(0xFF66BB6A),
              onPressed: () => _unlockAllFloors(context),
            ),
            const SizedBox(height: 8),
            _buildDevButton(
              icon: Icons.add,
              label: '+1 Care Streak',
              color: const Color(0xFF29B6F6),
              onPressed: () => _incrementCareStreak(context),
            ),
            const SizedBox(height: 8),
            _buildDevButton(
              icon: Icons.restore,
              label: 'Reset Care Streak',
              color: Colors.orange,
              onPressed: () => _resetCareStreak(context),
            ),
            const SizedBox(height: 8),
            _buildDevButton(
              icon: Icons.arrow_upward,
              label: 'Level Up Player',
              color: const Color(0xFF66BB6A),
              onPressed: () => _levelUpPlayer(context),
            ),
            const SizedBox(height: 8),
            _buildDevButton(
              icon: Icons.emoji_events,
              label: 'Complete All Achievements',
              color: const Color(0xFF66BB6A),
              onPressed: () => _completeAllAchievements(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addStars(BuildContext context) async {
    if (!mounted) return;

    try {
      final profile = context.read<PlayerProfile>();
      await profile.addStars(100);
      if (!mounted) return;

      notification.NotificationBar.success(context, 'Added 100 stars!');
    } catch (e) {
      if (!mounted) return;
      notification.NotificationBar.error(context, 'Error: $e');
    }
  }

  Future<void> _unlockNextSlot(BuildContext context) async {
    if (!mounted) return;

    try {
      final gardenState = context.read<GardenState>();
      final nextSlot = gardenState.getNextLockedSlot();

      if (nextSlot == null) {
        if (!mounted) return;
        notification.NotificationBar.info(
          context,
          'All slots already unlocked!',
        );
        return;
      }

      await gardenState.unlockSlotWithCoins(nextSlot.index);
      if (!mounted) return;

      notification.NotificationBar.success(
        context,
        'Unlocked slot ${nextSlot.index + 1}!',
      );
    } catch (e) {
      if (!mounted) return;
      notification.NotificationBar.error(context, 'Error: $e');
    }
  }

  Future<void> _unlockAllFloors(BuildContext context) async {
    if (!mounted) return;

    try {
      final profile = context.read<PlayerProfile>();
      for (int i = 0; i < 99; i++) {
        await profile.incrementTowerFloor();
      }
      if (!mounted) return;

      notification.NotificationBar.success(
        context,
        'Unlocked all floors (up to ${profile.towerFloor})!',
      );
    } catch (e) {
      if (!mounted) return;
      notification.NotificationBar.error(context, 'Error: $e');
    }
  }

  Future<void> _incrementCareStreak(BuildContext context) async {
    if (!mounted) return;

    try {
      final profile = context.read<PlayerProfile>();
      await profile.incrementCareStreak();
      if (!mounted) return;

      notification.NotificationBar.success(
        context,
        'Care streak increased to ${profile.careStreak}! 🔥',
      );
    } catch (e) {
      if (!mounted) return;
      notification.NotificationBar.error(context, 'Error: $e');
    }
  }

  Future<void> _resetCareStreak(BuildContext context) async {
    if (!mounted) return;

    try {
      final profile = context.read<PlayerProfile>();
      await profile.resetCareStreak();
      if (!mounted) return;

      notification.NotificationBar.success(context, 'Care streak reset to 0!');
    } catch (e) {
      if (!mounted) return;
      notification.NotificationBar.error(context, 'Error: $e');
    }
  }

  Future<void> _levelUpPlayer(BuildContext context) async {
    if (!mounted) return;

    try {
      final profile = context.read<PlayerProfile>();
      final gardenState = context.read<GardenState>();

      await profile.addExp(profile.expToNextLevel);
      await gardenState.unlockSlotsForLevel(profile.level);

      if (!mounted) return;

      notification.NotificationBar.success(
        context,
        'Leveled up! Now level ${profile.level}',
      );
    } catch (e) {
      if (!mounted) return;
      notification.NotificationBar.error(context, 'Error: $e');
    }
  }

  Future<void> _completeAllAchievements(BuildContext context) async {
    if (!mounted) return;

    notification.NotificationBar.info(
      context,
      'Complete achievements feature needs implementation',
    );
  }
}
