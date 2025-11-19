import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../game/battle_state.dart';
import '../models/timeline_entity.dart';
import 'package:flutter/services.dart';

class BattleCanvasGame extends FlameGame with TapCallbacks {
  BattleCanvasGame(this.battleState);

  final BattleState battleState;
  RectBackground? bg;
  final Map<String, PlantmonView> _plantViews = {};

  @override
  void onTapDown(TapDownEvent event) {
    final tapPos = event.canvasPosition;
    for (final view in _plantViews.values) {
      if (view.isMounted) {
        final viewPos = view.absolutePositionOf(Vector2.zero());
        final distance = (tapPos - viewPos).length;
        if (distance <= 60) {
          view.handleTap();
          break;
        }
      }
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Ensure background is added first (rendered behind)
    if (bg == null) {
      bg = RectBackground();
      add(bg!);
    }
    bg!
      ..size = size
      ..position = Vector2.zero()
      ..priority = -100; // Render background behind everything
  }

  @override
  void update(double dt) {
    super.update(dt);
    battleState.updateDeathAnimations(dt);
    _updatePlantViews();
  }

  void _updatePlantViews() {
    // Remove dead/missing views
    final currentIds = battleState.timeline.map((e) => e.id).toSet();
    _plantViews.removeWhere((id, view) {
      if (!currentIds.contains(id)) {
        view.removeFromParent();
        return true;
      }
      return false;
    });

    // Separate player and enemy entities for positioning
    final playerEntities = battleState.timeline
        .where((e) => e.isPlayer)
        .toList();
    final enemyEntities = battleState.timeline
        .where((e) => !e.isPlayer)
        .toList();

    // Update or create views
    for (final entity in battleState.timeline) {
      final bool highlightTarget =
          battleState.isSelectingTarget && !entity.isPlayer && !entity.isDead;

      if (!_plantViews.containsKey(entity.id)) {
        final view = PlantmonView(entity);
        _plantViews[entity.id] = view;
        view.priority = 10; // Render sprites above background
        add(view);
      }

      final view = _plantViews[entity.id]!;
      if (view.isLoaded) {
        view.updateEntity(entity, highlightTarget: highlightTarget);
      }

      if (!entity.isAttacking) {
        if (entity.isPlayer) {
          final playerIndex = playerEntities.indexOf(entity);
          final xOffset = playerIndex * 0.25;
          final targetPosition = Vector2(
            size.x * (0.15 + xOffset),
            size.y * 0.75,
          );

          if (view.originalPosition == null || !view.isAnimatingAttack) {
            view.originalPosition = targetPosition;
            view.position = targetPosition;
          }
        } else {
          final enemyIndex = enemyEntities.indexOf(entity);
          final xOffset = enemyIndex * 0.25;
          final targetPosition = Vector2(
            size.x * (0.85 - xOffset),
            size.y * 0.25,
          );

          if (view.originalPosition == null || !view.isAnimatingAttack) {
            view.originalPosition = targetPosition;
            view.position = targetPosition;
          }
        }
      }
    }
  }

  void showNotification(
    String message,
    String entityId, {
    required bool byPlayer,
  }) {
    // Position notification in game canvas frame based on player/enemy
    Vector2 notificationPosition;

    if (byPlayer) {
      // Player notifications: bottom of game canvas (will move upward)
      notificationPosition = Vector2(
        size.x / 2,
        size.y * 0.80, // Start at 80% down (near player sprites at 75%)
      );
    } else {
      // Enemy notifications: top of game canvas (will move downward)
      notificationPosition = Vector2(
        size.x / 2,
        size.y * 0.20, // Start at 20% down (near enemy sprites at 25%)
      );
    }

    // Ensure notification stays within screen bounds
    if (size.x > 0 && size.y > 0) {
      final boxWidth = 350.0; // Match the PopupNotification width
      final halfWidth = boxWidth / 2;
      final maxX = (size.x - halfWidth).clamp(halfWidth, size.x).toDouble();
      notificationPosition.x = notificationPosition.x.clamp(halfWidth, maxX);
    }

    final notification = PopupNotification(message, byPlayer: byPlayer)
      ..position = notificationPosition
      ..priority = 100; // Render notifications above all sprites
    add(notification);
  }
}

class RectBackground extends PositionComponent {
  ui.Image? _bgImage;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    try {
      final byteData = await rootBundle.load('assets/images/Garden_BG.png');
      final codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      _bgImage = frame.image;
    } catch (e) {
      // Fallback to gradient if image fails to load
    }
  }

  @override
  void render(ui.Canvas canvas) {
    if (_bgImage != null) {
      // Draw image to fill the entire background
      final srcRect = Rect.fromLTWH(
        0,
        0,
        _bgImage!.width.toDouble(),
        _bgImage!.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(0, 0, size.x, size.y);
      canvas.drawImageRect(_bgImage!, srcRect, dstRect, ui.Paint());
    } else {
      // Fallback gradient
      final paint = ui.Paint()
        ..shader = ui.Gradient.linear(ui.Offset(0, 0), ui.Offset(0, size.y), [
          const ui.Color(0xFF4a1a1a),
          const ui.Color(0xFF2a0a0a),
        ]);
      canvas.drawRect(size.toRect(), paint);
    }
  }
}

class PopupNotification extends PositionComponent {
  late final TextComponent _textComponent;
  final bool byPlayer;

  PopupNotification(String text, {required this.byPlayer})
    : super(anchor: Anchor.center) {
    // Simple text with black outline - no boxes needed!
    _textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: ui.Color(0xFFFFFFFF), // White text
          fontSize: 18, // Large and readable
          fontWeight: FontWeight.bold,
          shadows: [
            // Black outline (8 directions for strong visibility)
            Shadow(offset: Offset(-2, -2), color: ui.Color(0xFF000000)),
            Shadow(offset: Offset(2, -2), color: ui.Color(0xFF000000)),
            Shadow(offset: Offset(-2, 2), color: ui.Color(0xFF000000)),
            Shadow(offset: Offset(2, 2), color: ui.Color(0xFF000000)),
            Shadow(offset: Offset(0, -2), color: ui.Color(0xFF000000)),
            Shadow(offset: Offset(0, 2), color: ui.Color(0xFF000000)),
            Shadow(offset: Offset(-2, 0), color: ui.Color(0xFF000000)),
            Shadow(offset: Offset(2, 0), color: ui.Color(0xFF000000)),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    add(_textComponent);
  }

  @override
  void onMount() {
    super.onMount();

    // Player: move from bottom to top (upward)
    // Enemy: move from top to bottom (downward)
    final moveOffset = byPlayer ? Vector2(0, -50) : Vector2(0, 50);

    // Animate: move in direction
    add(
      SequenceEffect([
        MoveByEffect(
          moveOffset,
          EffectController(duration: 1.0, curve: Curves.easeOut),
        ),
      ]),
    );

    // Remove after animation completes (1 second)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (isMounted) removeFromParent();
    });
  }
}

class PlantmonView extends PositionComponent {
  TimelineEntity entity;
  SpriteComponent? plantSprite;
  Vector2? originalPosition;
  bool isAnimatingAttack = false;
  PositionComponent? _hpHolder;
  RectangleComponent? _hpFill;
  CircleComponent? _targetRing;
  bool _pendingHighlight = false;
  TextComponent? _shieldIcon;
  TextComponent? _hpText;

  PlantmonView(this.entity) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _ensureTargetRing();
    _ensureShieldIcon();

    // Load plant sprite from assets
    try {
      // Use sprite override if available (for enemies), otherwise construct path
      final spritePath =
          entity.spriteOverride ??
          'assets/images/plants/${entity.plantmon.name}.png';

      final spriteImage = await Sprite.load(spritePath);
      plantSprite = SpriteComponent(
        sprite: spriteImage,
        size: Vector2(100, 100),
        anchor: Anchor.center,
      );
      add(plantSprite!);

      _addIdleAnimation();
      _attachEnemyHpBar();
    } catch (e) {
      // Fallback: still attach HP bar for consistency
      _attachEnemyHpBar();
    }
  }

  void _addIdleAnimation() {
    if (plantSprite == null) return;

    // Create infinite up-down floating effect
    final upEffect = MoveByEffect(
      Vector2(0, -8), // Move up 8 pixels
      EffectController(duration: 1.5, curve: Curves.easeInOut),
    );

    final downEffect = MoveByEffect(
      Vector2(0, 8), // Move down 8 pixels
      EffectController(duration: 1.5, curve: Curves.easeInOut),
    );

    // Sequence: up then down, repeat infinitely
    plantSprite!.add(SequenceEffect([upEffect, downEffect], infinite: true));
  }

  void _ensureShieldIcon() {
    if (_shieldIcon != null) return;
    _shieldIcon = TextComponent(
      text: '🛡️',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 32, height: 1.0),
      ),
      anchor: Anchor.center,
      position: Vector2(30, -40), // Top-right of sprite
    );
    _shieldIcon!.priority = 10; // Render above sprite
    add(_shieldIcon!);
    _updateShieldVisibility();
  }

  void _ensureTargetRing() {
    if (_targetRing != null) return;
    _targetRing = CircleComponent(
      radius: 58,
      paint: ui.Paint()
        ..color = Colors.transparent
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3,
      anchor: Anchor.center,
    )..priority = -5;
    add(_targetRing!);
    _updateTargetHighlight(_pendingHighlight);
  }

  void _attachEnemyHpBar() {
    if (entity.isPlayer || _hpHolder != null) {
      return;
    }
    final spriteBottom = (plantSprite?.size.y ?? 80) / 2;

    // Add name label above HP bar
    final nameLabelOffset = spriteBottom + 2;
    final nameLabel = TextComponent(
      text: '${entity.plantmon.name} Lv${entity.plantmon.level}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: ui.Color(0xFFFFFFFF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: ui.Color(0xFF000000),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(0, nameLabelOffset),
    );
    add(nameLabel);

    // Add HP bar with overlaid text (cleaner 2-line layout)
    final verticalOffset =
        nameLabelOffset + 14; // 14px = label height + small gap
    final holder = PositionComponent(
      anchor: Anchor.topCenter,
      position: Vector2(0, verticalOffset),
    );
    const double fullWidth = 90;
    const double barHeight = 14; // Taller bar to accommodate text
    const double offsetX = -fullWidth / 2;

    final background = RectangleComponent(
      anchor: Anchor.topLeft,
      position: Vector2(offsetX, 0),
      size: Vector2(fullWidth, barHeight),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.65),
    );
    final fill = RectangleComponent(
      anchor: Anchor.topLeft,
      position: Vector2(offsetX + 1, 1),
      size: Vector2(fullWidth - 2, barHeight - 2),
      paint: Paint()..color = Colors.greenAccent,
    );

    // HP text overlaid on the bar (centered)
    final hpText = TextComponent(
      text: '${entity.plantmon.hp}/${entity.plantmon.maxHp}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: ui.Color(0xFFFFFFFF),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: ui.Color(0xFF000000),
              offset: Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, barHeight / 2), // Center vertically in bar
    );

    holder.add(background);
    holder.add(fill);
    holder.add(hpText); // Add text on top of bar
    add(holder);
    _hpHolder = holder;
    _hpFill = fill;
    _hpText = hpText;
    _updateEnemyHpBar();
  }

  void _updateEnemyHpBar() {
    if (_hpFill == null) return;
    // Use actual maxHp instead of estimate
    final ratio = (entity.plantmon.hp / entity.plantmon.maxHp).clamp(0.0, 1.0);
    const double maxWidth = 88;
    const double fillHeight =
        12; // Match new bar height (14px outer, 12px inner)
    _hpFill!.size = Vector2(maxWidth * ratio, fillHeight);
    _hpFill!.paint.color = ratio <= 0.25
        ? Colors.redAccent
        : Colors.greenAccent;
  }

  void _updateEnemyHpText() {
    if (_hpText == null) return;
    _hpText!.text = '${entity.plantmon.hp}/${entity.plantmon.maxHp}';
  }

  void _updateTargetHighlight(bool isActive) {
    _pendingHighlight = isActive;
    if (_targetRing == null) {
      return;
    }

    if (!entity.isPlayer && !entity.isDead && isActive) {
      _targetRing!.paint
        ..color = const ui.Color(0xFFFF0000)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 5;

      // Add pulsing animation effect
      _targetRing!.removeWhere((component) => component is OpacityEffect);
      _targetRing!.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.6, alternate: true, infinite: true),
        ),
      );
    } else {
      _targetRing!.paint
        ..color = Colors.transparent
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3;

      // Remove pulsing animation
      _targetRing!.removeWhere((component) => component is OpacityEffect);
    }
  }

  void _updateShieldVisibility() {
    if (_shieldIcon == null) return;
    // Show/hide by changing text color opacity
    _shieldIcon!.textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 32,
        height: 1.0,
        color: entity.isDefending
            ? const ui.Color(0xFFFFFFFF)
            : const ui.Color(0x00FFFFFF), // Transparent
      ),
    );
  }

  void updateEntity(TimelineEntity newEntity, {required bool highlightTarget}) {
    final wasAttacking = entity.isAttacking;
    entity = newEntity;
    if (!wasAttacking && entity.isAttacking && !isAnimatingAttack) {
      _performAttackAnimation();
    }

    if (plantSprite != null) {
      if (entity.isPlayingDeathAnimation) {
        final progress = entity.deathAnimationProgress;
        final opacity = (255 * (1.0 - progress)).round().clamp(0, 255);

        final flashCycle = (progress * 10).floor() % 2;
        final isRed = flashCycle == 0;

        plantSprite!.paint.color = ui.Color.fromARGB(
          opacity,
          255,
          isRed ? 100 : 255,
          isRed ? 100 : 255,
        );

        final scale = 1.0 - (progress * progress);
        plantSprite!.scale = Vector2.all(scale);
      } else if (entity.isDead) {
        plantSprite!.paint.color = const ui.Color.fromARGB(0, 255, 255, 255);
        plantSprite!.scale = Vector2.all(0.0);
      } else {
        plantSprite!.paint.color = const ui.Color.fromARGB(255, 255, 255, 255);
        plantSprite!.scale = Vector2.all(1.0);
      }
    }

    _updateEnemyHpBar();
    _updateEnemyHpText();
    _updateTargetHighlight(highlightTarget);
    _updateShieldVisibility();
  }

  void handleTap() {
    final game = findGame() as BattleCanvasGame?;
    if (game == null) {
      return;
    }
    if (entity.isPlayer || entity.isDead) {
      return;
    }
    if (!game.battleState.isSelectingTarget) {
      return;
    }
    game.battleState.trySelectTarget(entity.id);
  }

  void _performAttackAnimation() {
    if (isAnimatingAttack) return;

    final game = findGame() as BattleCanvasGame?;
    if (game == null) {
      return;
    }

    // Find target position
    final targetEntity = game.battleState.timeline.firstWhere(
      (e) => e.id == entity.targetId,
      orElse: () => entity,
    );

    final targetView = game._plantViews[targetEntity.id];
    if (targetView == null) {
      return;
    }

    isAnimatingAttack = true;
    originalPosition ??= position.clone();

    // Calculate direction toward target
    final direction = (targetView.position - position).normalized();
    final attackDistance = 100.0; // Move 100 pixels toward target
    final attackOffset = direction * attackDistance;

    // Move toward target
    add(
      MoveByEffect(
        attackOffset,
        EffectController(duration: 0.2, curve: Curves.easeOut),
        onComplete: () {
          // Return to original position
          if (originalPosition != null) {
            add(
              MoveToEffect(
                originalPosition!,
                EffectController(duration: 0.2, curve: Curves.easeIn),
                onComplete: () {
                  isAnimatingAttack = false;
                },
              ),
            );
          }
        },
      ),
    );
  }
}
