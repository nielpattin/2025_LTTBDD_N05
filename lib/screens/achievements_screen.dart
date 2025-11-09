import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProfile>(
      builder: (context, profile, _) {
        return Container(
          color: const Color(0xFF0a0a0a),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profile.achievements.length,
            itemBuilder: (context, index) {
              final achievement = profile.achievements[index];
              return _buildAchievementCard(achievement);
            },
          ),
        );
      },
    );
  }

  Widget _buildAchievementCard(dynamic achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: const Color(0xFF1e1e1e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  achievement.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: achievement.isCompleted
                      ? const Color(0xFF66BB6A)
                      : Colors.white38,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    achievement.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: achievement.isCompleted
                          ? Colors.white
                          : Colors.white70,
                    ),
                  ),
                ),
                Text(
                  '${achievement.progress}/${achievement.target}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                achievement.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
            ),
            if (!achievement.isCompleted) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 36, right: 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: achievement.progressPercent,
                    backgroundColor: const Color(0xFF2a2a2a),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF66BB6A),
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
