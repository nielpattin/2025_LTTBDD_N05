import 'package:flutter/material.dart';
import '../models/plantmon.dart';
import '../services/care_service.dart';

/// Widget for displaying care system UI and interactions
class CareActionsWidget extends StatelessWidget {
  final Plantmon plantmon;
  final VoidCallback onCareAction;

  const CareActionsWidget({
    super.key,
    required this.plantmon,
    required this.onCareAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite, color: Colors.cyan, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Chăm Sóc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Energy Status
          _buildEnergyBar(),
          const SizedBox(height: 14),

          // Cooldown Status
          _buildCooldownStatus(),
          const SizedBox(height: 14),

          // Care Rewards Info
          _buildRewardsInfo(),
          const SizedBox(height: 16),

          // Care Buttons
          _buildCareButtons(context),
        ],
      ),
    );
  }

  Widget _buildEnergyBar() {
    return SizedBox.shrink();
  }

  Widget _buildCooldownStatus() {
    return const SizedBox.shrink();
  }

  Widget _buildRewardsInfo() {
    final quality = CareService.calculateCareQuality(plantmon);
    final qualityDesc = CareService.getQualityDescription(quality);
    final exp = CareService.getExpReward(plantmon);
    final qualityColor = Color(
      int.parse(CareService.getQualityHex(quality).replaceFirst('#', '0xff')),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quality Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: qualityColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            qualityDesc,
            style: TextStyle(
              color: qualityColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Rewards Grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Next Reward EXP
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Thưởng',
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  Row(
                    children: [
                      Text(
                        '$exp',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Text(
                        ' EXP',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCareButtons(BuildContext context) {
    final canCare = CareService.canCare(plantmon);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canCare ? onCareAction : null,
            icon: const Icon(Icons.water_drop, size: 20),
            label: const Text(
              'Water',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              disabledBackgroundColor: Colors.grey[700],
              disabledForegroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canCare ? onCareAction : null,
            icon: const Icon(Icons.local_florist, size: 20),
            label: const Text(
              'Fertilize',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              disabledBackgroundColor: Colors.grey[700],
              disabledForegroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
