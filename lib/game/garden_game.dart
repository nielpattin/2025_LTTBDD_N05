import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/painting.dart' show TextStyle;
import '../models/plantmon.dart';
import '../models/slot.dart';

class GardenGame extends FlameGame {
  GardenGame({
    required this.slots,
    required this.onTapSlot,
    required this.onTapPlant,
  });

  List<Slot> slots;
  final void Function(int slotIndex) onTapSlot;
  final void Function(int slotIndex) onTapPlant;

  final List<PlantEntity> _plantEntities = [];
  final math.Random _random = math.Random();

  @override
  Future<void> onLoad() async {
    images.prefix = '';

    try {
      final bgImage = await images.load('assets/images/Garden_BG.png');
      final bgSprite = SpriteComponent(
        sprite: Sprite(bgImage),
        size: size,
        position: Vector2.zero(),
      );
      add(bgSprite);
    } catch (e) {
      // Fallback: solid color background if image fails to load
      final bgRect = RectangleComponent(
        size: size,
        position: Vector2.zero(),
        paint: ui.Paint()..color = const ui.Color(0xFF4CAF50),
      );
      add(bgRect);
    }

    _spawnPlantmons();
  }

  void _spawnPlantmons() {
    _plantEntities.clear();

    final plantsWithIndex = <(Plantmon, int)>[];
    for (final slot in slots) {
      if (slot.isUnlocked && slot.plantmon != null) {
        plantsWithIndex.add((slot.plantmon!, slot.index));
      }
    }

    final safeMargin = 60.0;
    final minX = safeMargin;
    final maxX = size.x - safeMargin;
    final minY = safeMargin + 60;
    final maxY = size.y - safeMargin - 80;

    for (final (plant, slotIndex) in plantsWithIndex) {
      final spawnX = minX + _random.nextDouble() * (maxX - minX);
      final spawnY = minY + _random.nextDouble() * (maxY - minY);

      final entity = PlantEntity(
        plantmon: plant,
        slotIndex: slotIndex,
        onTap: onTapPlant,
        spawnPosition: Vector2(spawnX, spawnY),
        wanderBounds: ui.Rect.fromLTRB(minX, minY, maxX, maxY),
      );
      _plantEntities.add(entity);
      add(entity);
    }
  }

  void updateSlots(List<Slot> newSlots) {
    if (!isMounted) {
      return;
    }

    slots = newSlots;

    for (final entity in _plantEntities) {
      remove(entity);
    }
    _plantEntities.clear();

    _spawnPlantmons();
  }
}

class PlantEntity extends PositionComponent
    with TapCallbacks, HasGameReference<GardenGame> {
  PlantEntity({
    required this.plantmon,
    required this.slotIndex,
    required this.onTap,
    required this.spawnPosition,
    required this.wanderBounds,
  });

  final Plantmon plantmon;
  final int slotIndex;
  final void Function(int slotIndex) onTap;
  final Vector2 spawnPosition;
  final ui.Rect wanderBounds;

  late Vector2 _targetPosition;
  double _wanderTimer = 0;
  final double _wanderInterval = 3.0;
  final double _moveSpeed = 40.0;
  final math.Random _random = math.Random();

  @override
  Future<void> onLoad() async {
    size = Vector2(80, 80);
    position = spawnPosition.clone();
    anchor = Anchor.center;

    _pickNewTarget();

    add(
      MoveByEffect(
        Vector2(0, -6),
        EffectController(
          duration: 1.2,
          reverseDuration: 1.2,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );

    try {
      final imagePath = 'assets/images/plants/${plantmon.name}.png';

      final image = await game.images.load(imagePath);
      add(
        SpriteComponent(
          sprite: Sprite(image),
          size: size,
          anchor: Anchor.center,
        ),
      );
    } catch (e) {
      // Fallback: green box with name
      add(
        RectangleComponent(
          size: size,
          paint: ui.Paint()..color = const ui.Color(0xFF2e7d32),
        ),
      );

      add(
        TextComponent(
          text: plantmon.name.length > 8
              ? plantmon.name.substring(0, 8)
              : plantmon.name,
          anchor: Anchor.center,
          position: size / 2,
          textRenderer: TextPaint(
            style: const TextStyle(color: ui.Color(0xFFECEFF1), fontSize: 12),
          ),
        ),
      );
    }
  }

  void _pickNewTarget() {
    _targetPosition = Vector2(
      wanderBounds.left + _random.nextDouble() * wanderBounds.width,
      wanderBounds.top + _random.nextDouble() * wanderBounds.height,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    final direction = _targetPosition - position;
    final distance = direction.length;

    if (distance > 5) {
      direction.normalize();
      final movement = direction * _moveSpeed * dt;

      if (movement.length > distance) {
        position = _targetPosition.clone();
      } else {
        position.add(movement);
      }
    }

    _wanderTimer += dt;
    if (_wanderTimer >= _wanderInterval) {
      _wanderTimer = 0;
      _pickNewTarget();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(slotIndex);
    super.onTapDown(event);
  }
}
