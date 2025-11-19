import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/battle_state.dart';
import '../models/timeline_entity.dart';

class TimelineBarWidget extends StatelessWidget {
  const TimelineBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const double timelineHeight = 26.0;
    const double markerSize = 30.0;
    const double markerGap = 6.0;
    const double trackTop = 40.0;
    const double horizontalPadding = 24.0;

    return Consumer<BattleState>(
      builder: (context, battleState, _) {
        return SizedBox(
          height: 105,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final timelineWidth = totalWidth - (horizontalPadding * 2);
              final playerMarkerTop = trackTop - markerSize - markerGap;
              final enemyMarkerTop = trackTop + timelineHeight + markerGap;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: trackTop,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    child: _buildBackgroundBar(timelineHeight),
                  ),
                  ...battleState.timeline.map(
                    (entity) => _buildMarker(
                      entity,
                      timelineWidth,
                      horizontalPadding,
                      playerMarkerTop,
                      enemyMarkerTop,
                      markerSize,
                      markerGap,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBackgroundBar(double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 70,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(6),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                'WAIT',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.25),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(6),
                ),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.8),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'CAST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(
    TimelineEntity entity,
    double timelineWidth,
    double horizontalPadding,
    double playerMarkerTop,
    double enemyMarkerTop,
    double markerSize,
    double markerGap,
  ) {
    final double clampedLeft =
        (horizontalPadding +
                (entity.position * timelineWidth) -
                (markerSize / 2))
            .clamp(
              horizontalPadding - (markerSize / 2),
              horizontalPadding + timelineWidth - (markerSize / 2),
            );

    final bool isPlayer = entity.isPlayer;

    final Color baseColor = isPlayer ? Colors.white : Colors.redAccent;
    final Color borderColor = baseColor;
    final Color fillColor = const Color(0xFF1e1e1e); // Opaque dark background

    final double stemHeight = markerGap + 26;
    final double top = isPlayer
        ? playerMarkerTop
        : (enemyMarkerTop - stemHeight);

    return Positioned(
      left: clampedLeft,
      top: top,
      child: SizedBox(
        width: markerSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isPlayer)
              Container(width: 4, height: stemHeight, color: borderColor),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: markerSize,
              height: markerSize,
              decoration: BoxDecoration(
                color: fillColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Center(
                child: Text(
                  entity.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (isPlayer)
              Container(width: 4, height: stemHeight, color: borderColor),
          ],
        ),
      ),
    );
  }
}
