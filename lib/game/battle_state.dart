import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/plantmon.dart';
import '../models/battle_result.dart';
import '../models/timeline_entity.dart';
import '../data/plants_data.dart';
import '../data/tower_floors_data.dart';
import '../config/game_balance.dart';

class BattleState extends ChangeNotifier {
  BattleState();

  // Timeline entities
  final List<TimelineEntity> _timeline = [];
  int _currentFloor = 1;
  String? _selectedEntityId; // for player action selection
  bool _isRunning = false;
  Timer? _updateTimer;
  double _energyRegenRemainder = 0;
  bool _isTimelinePaused = false;
  bool _isSelectingTarget = false;
  ActionType? _pendingActionType;
  String? _pendingActorId;
  bool _started = false; // Track if battle has actually started
  bool _suppressBattleOverCheck = false; // Hot reload protection
  bool _isExecutingAction = false;
  bool _anyDeathAnimationsPlaying = false;
  int _turnCount = 0; // Prevent concurrent action execution

  // Notification callbacks
  void Function(String message, String entityId, {required bool byPlayer})?
  onNotification;
  void Function(String entityId)? onInterrupt;

  // Getters
  List<TimelineEntity> get timeline => List.unmodifiable(_timeline);
  int get currentFloor => _currentFloor;
  String? get selectedEntityId => _selectedEntityId;
  bool get isRunning => _isRunning;
  bool get isBattleOver =>
      _started &&
      !_suppressBattleOverCheck &&
      !_anyDeathAnimationsPlaying &&
      _checkBattleOver();
  bool get isSelectingTarget => _isSelectingTarget;
  ActionType? get pendingActionType => _pendingActionType;
  int get turnCount => _turnCount;

  List<TimelineEntity> get playerEntities =>
      _timeline.where((e) => e.isPlayer && !e.isDead).toList();
  List<TimelineEntity> get enemyEntities =>
      _timeline.where((e) => !e.isPlayer && !e.isDead).toList();

  // Start battle for tower with timeline system
  void startBattleForTower(List<Plantmon> playerParty, int floor) {
    _currentFloor = floor;
    _timeline.clear();
    _selectedEntityId = null;
    _isTimelinePaused = false;
    _isSelectingTarget = false;
    _pendingActionType = null;
    _pendingActorId = null;
    _started = true;
    _suppressBattleOverCheck = false;
    _isExecutingAction = false;
    _turnCount = 0;

    // Add player entities
    for (int i = 0; i < playerParty.length; i++) {
      final double speed = _getEntitySpeed(isPlayer: true);
      _timeline.add(
        TimelineEntity(
          id: 'P${i + 1}',
          plantmon: playerParty[i],
          isPlayer: true,
          position: GameBalance.playerMidStart,
          speed: speed,
        ),
      );
    }

    // Generate and add enemy entities
    final enemiesData = _generateTowerEnemies(floor);
    for (int i = 0; i < enemiesData.length; i++) {
      final double speed = _getEntitySpeed(isPlayer: false);
      _timeline.add(
        TimelineEntity(
          id: 'E${i + 1}',
          plantmon: enemiesData[i]['plantmon'] as Plantmon,
          isPlayer: false,
          spriteOverride: enemiesData[i]['sprite'] as String?,
          position: GameBalance.enemyStart,
          speed: speed,
        ),
      );
    }

    _startTimeline();
    notifyListeners();
  }

  List<Map<String, dynamic>> _generateTowerEnemies(int floor) {
    final random = Random();
    final enemies = <Map<String, dynamic>>[];

    final enemyCount = GameBalance.getEnemyCount(floor, random);
    final enemyLevel = floor;

    for (int i = 0; i < enemyCount; i++) {
      final spriteIndex = random.nextInt(enemySpritePool.length);
      final spritePath = enemySpritePool[spriteIndex];
      final enemyName = getEnemyNameFromSprite(spritePath);

      final basePower =
          random.nextInt(
            GameBalance.basePowerMax - GameBalance.basePowerMin + 1,
          ) +
          GameBalance.basePowerMin;

      final baseDefense =
          random.nextInt(
            GameBalance.baseDefenseMax - GameBalance.baseDefenseMin + 1,
          ) +
          GameBalance.baseDefenseMin;

      final baseHp =
          random.nextInt(GameBalance.baseHpMax - GameBalance.baseHpMin + 1) +
          GameBalance.baseHpMin;

      final levelMultiplier =
          1.0 + ((enemyLevel - 1) * GameBalance.statScalingPerLevel);
      final enemyMultiplier = GameBalance.enemyStatMultiplier * levelMultiplier;

      final plantmon = Plantmon(
        id: generatePlantmonId(),
        type: enemyName,
        name: enemyName,
        level: enemyLevel,
        exp: 0,
        attack: (basePower * enemyMultiplier).round(),
        defense: (baseDefense * enemyMultiplier).round(),
        hp: (baseHp * enemyMultiplier).round(),
        maxHp: (baseHp * enemyMultiplier).round(),
      );

      enemies.add({'plantmon': plantmon, 'sprite': spritePath});
    }

    return enemies;
  }

  void _startTimeline() {
    _isRunning = true;
    // Update at 60 FPS
    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _updateTimeline(0.016),
    );
  }

  double _getEntitySpeed({required bool isPlayer}) {
    final double minMultiplier = isPlayer
        ? GameBalance.playerSpeedMinMultiplier
        : GameBalance.enemySpeedMinMultiplier;
    final double maxMultiplier = isPlayer
        ? GameBalance.playerSpeedMaxMultiplier
        : GameBalance.enemySpeedMaxMultiplier;
    if (maxMultiplier <= minMultiplier) {
      return GameBalance.baseSpeed * minMultiplier;
    }

    final double midMultiplier = (minMultiplier + maxMultiplier) / 2;
    return GameBalance.baseSpeed * midMultiplier;
  }

  void _updateTimeline(double dt) {
    if (!_isRunning) return;

    bool timelineChanged = false;
    bool stateChanged = false;
    bool energyChanged = false;

    // Accumulate regen so we only emit energy changes on whole-number ticks
    _energyRegenRemainder += GameBalance.energyRegenPerSecond * dt;
    final int energyTicks = _energyRegenRemainder.floor();
    if (energyTicks > 0) {
      _energyRegenRemainder -= energyTicks;
    }

    for (int i = 0; i < _timeline.length; i++) {
      final entity = _timeline[i];

      if (entity.isDead) {
        continue;
      }

      if (_isTimelinePaused ||
          _isExecutingAction ||
          entity.isAwaitingInput ||
          entity.isAttacking) {
        continue;
      }

      final oldPosition = entity.position;
      final double increment = entity.speed * dt;

      if (entity.phase == TimelinePhase.waiting) {
        entity.position = (entity.position + increment).clamp(
          0.0,
          GameBalance.timelineCastStart,
        );
        if (entity.position >= GameBalance.timelineCastStart - 0.0001) {
          entity.position = GameBalance.timelineCastStart;
          if (entity.isPlayer) {
            _enterPlayerCast(entity);
          } else {
            _enterEnemyCast(entity);
          }
          stateChanged = true;
        }
      } else if (entity.phase == TimelinePhase.casting) {
        entity.position = (entity.position + increment).clamp(
          GameBalance.timelineCastStart,
          GameBalance.timelineCastEnd,
        );

        // Check if entity reaches end of cast zone
        if (entity.position >= GameBalance.timelineCastEnd) {
          if (entity.queuedAction != null) {
            _resolveAction(entity);
            stateChanged = true;
          } else if (entity.isDefending) {
            // Shield timeout: remove shield and reset entity
            entity.isDefending = false;
            _resetEntity(entity);
            stateChanged = true;
          }
        }
      }

      if (entity.position != oldPosition) {
        timelineChanged = true;
      }
    }

    final bool shouldNotify = timelineChanged || stateChanged || energyChanged;
    if (shouldNotify) {
      notifyListeners();
    }

    if (_checkBattleOver()) {
      _stopTimeline();
      notifyListeners();
    }
  }

  void _enterPlayerCast(TimelineEntity entity) {
    entity.phase = TimelinePhase.awaitingInput;
    entity.queuedAction = null;
    entity.targetId = null;
    _selectedEntityId = entity.id;
    _pendingActorId = null;
    _pendingActionType = null;
    _isSelectingTarget = false;
    _pauseTimeline();
  }

  void _enterEnemyCast(TimelineEntity entity) {
    entity.phase = TimelinePhase.casting;
    _queueEnemyAction(entity);
  }

  void _queueEnemyAction(TimelineEntity entity) {
    final random = Random();

    final canUseHeavyAttack = entity.mp >= GameBalance.heavyAttackMpCost;
    final roll = random.nextDouble();

    if (canUseHeavyAttack) {
      // With MP: 35% Heavy Attack, 20% Defend, 45% Attack
      if (roll < 0.35) {
        entity.queuedAction = ActionType.heavyAttack;
      } else if (roll < 0.55) {
        entity.isDefending = true;
        entity.position = 0.0;
        entity.phase = TimelinePhase.waiting;
        entity.queuedAction = null;
        entity.targetId = null;

        onNotification?.call(
          '${entity.plantmon.name} defends!',
          entity.id,
          byPlayer: false,
        );
        return;
      } else {
        entity.queuedAction = ActionType.attack;
      }
    } else {
      // Without MP: 30% Defend, 70% Attack
      if (roll < 0.30) {
        entity.isDefending = true;
        entity.position = 0.0;
        entity.phase = TimelinePhase.waiting;
        entity.queuedAction = null;
        entity.targetId = null;

        onNotification?.call(
          '${entity.plantmon.name} defends!',
          entity.id,
          byPlayer: false,
        );
        return;
      } else {
        entity.queuedAction = ActionType.attack;
      }
    }

    // Select random target
    final targets = playerEntities;
    if (targets.isNotEmpty) {
      entity.targetId = targets[random.nextInt(targets.length)].id;
    }
  }

  // Player taps an action button while awaiting input
  void queueAction(ActionType action) {
    if (_selectedEntityId == null) return;

    final entityIndex = _timeline.indexWhere((e) => e.id == _selectedEntityId);
    if (entityIndex == -1) return;

    final entity = _timeline[entityIndex];
    if (!entity.isPlayer) {
      return;
    }

    // Check if the entity is ready to choose an action
    if (!entity.isAwaitingInput) {
      return;
    }

    // Check MP cost for Heavy Attack
    if (action == ActionType.heavyAttack &&
        entity.mp < GameBalance.heavyAttackMpCost) {
      onNotification?.call(
        'Not enough MP! Need ${GameBalance.heavyAttackMpCost} MP',
        entity.id,
        byPlayer: true,
      );
      return;
    }

    // DEFEND is self-targeting, no enemy selection needed
    if (action == ActionType.defend) {
      // Apply shield immediately and reset to position 0.0
      entity.isDefending = true;
      entity.position = 0.0;
      entity.phase = TimelinePhase.waiting;
      entity.queuedAction = null;
      entity.targetId = null;
      _selectedEntityId = null;

      onNotification?.call(
        '${entity.plantmon.name} defends!',
        entity.id,
        byPlayer: true,
      );

      _resumeTimelineIfPossible();
      notifyListeners();
      return;
    }

    if (enemyEntities.isEmpty) {
      onNotification?.call('No targets available!', entity.id, byPlayer: true);
      return;
    }

    entity.queuedAction = action;
    entity.targetId = null;
    _pendingActorId = entity.id;
    _pendingActionType = action;
    _isSelectingTarget = true;

    notifyListeners();
  }

  bool trySelectTarget(String targetId) {
    if (!_isSelectingTarget || _pendingActorId == null) {
      return false;
    }

    final actorIndex = _timeline.indexWhere((e) => e.id == _pendingActorId);
    if (actorIndex == -1) {
      return false;
    }

    final actor = _timeline[actorIndex];
    if (!actor.isPlayer || !actor.isAwaitingInput) {
      return false;
    }

    final targetIndex = _timeline.indexWhere(
      (entity) => entity.id == targetId && !entity.isPlayer,
    );
    if (targetIndex == -1) {
      return false;
    }

    final target = _timeline[targetIndex];
    if (target.isDead) {
      return false;
    }

    actor.targetId = target.id;
    actor.phase = TimelinePhase.casting;
    _isSelectingTarget = false;
    _selectedEntityId = null;
    _pendingActorId = null;
    _pendingActionType = null;
    _resumeTimelineIfPossible();

    notifyListeners();
    return true;
  }

  void _resolveAction(TimelineEntity attacker) {
    if (attacker.queuedAction == null || attacker.targetId == null) {
      _resetEntity(attacker);
      _resumeTimelineIfPossible();
      return;
    }

    final targetIndex = _timeline.indexWhere((e) => e.id == attacker.targetId);
    if (targetIndex == -1) {
      _resetEntity(attacker);
      _resumeTimelineIfPossible();
      return;
    }

    final target = _timeline[targetIndex];
    if (target.isDead) {
      _resetEntity(attacker);
      _resumeTimelineIfPossible();
      return;
    }

    // Prevent concurrent action execution
    if (_isExecutingAction) {
      return;
    }

    _isExecutingAction = true;
    _pauseTimeline();

    // Winner interrupts any opponents that were still casting
    _interruptOpponents(attacker);

    // Set attacking flag to trigger animation
    attacker.isAttacking = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 400), () {
      int damage;
      if (attacker.queuedAction == ActionType.heavyAttack) {
        // Consume MP for heavy attack
        attacker.mp = max(0, attacker.mp - GameBalance.heavyAttackMpCost);

        damage = _calculateHeavyAttackDamage(
          attacker.plantmon,
          target.plantmon,
        );
        onNotification?.call(
          '${attacker.plantmon.name} uses Heavy Attack!',
          attacker.id,
          byPlayer: attacker.isPlayer,
        );
      } else {
        // ATTACK action - remove attacker's shield if they were attacking
        if (attacker.isDefending) {
          attacker.isDefending = false;
        }

        // Check if target is defending
        if (target.isDefending) {
          damage = _calculateAttackDamage(attacker.plantmon, target.plantmon);
          damage = (damage * 0.5).ceil(); // Reduce damage by 50%
          target.isDefending = false; // Shield breaks
          onNotification?.call(
            '${attacker.plantmon.name} attacks! Shield broken!',
            attacker.id,
            byPlayer: attacker.isPlayer,
          );
        } else {
          damage = _calculateAttackDamage(attacker.plantmon, target.plantmon);
          onNotification?.call(
            '${attacker.plantmon.name} attacks!',
            attacker.id,
            byPlayer: attacker.isPlayer,
          );
        }
      }

      final newHp = max(0, target.plantmon.hp - damage);
      target.plantmon = target.plantmon.copyWith(hp: newHp);

      if (target.isDead && !target.isPlayingDeathAnimation) {
        _triggerDeathAnimation(target);
      }

      _turnCount++;

      // Wait for notification animation to complete (1.1s total)
      Future.delayed(const Duration(milliseconds: 1200), () {
        _resetEntity(attacker);
        _isExecutingAction = false;
        _resumeTimelineIfPossible();

        notifyListeners();
      });
    });
  }

  void _interruptOpponents(TimelineEntity winner) {
    for (final entity in _timeline) {
      if (entity == winner || entity.isDead) {
        continue;
      }
      if (entity.isPlayer == winner.isPlayer) {
        continue;
      }
      if (entity.phase != TimelinePhase.casting) {
        continue;
      }
      if (entity.position >= GameBalance.timelineCastEnd) {
        continue;
      }
      _interruptEntity(entity);
    }
  }

  int _calculateAttackDamage(Plantmon attacker, Plantmon defender) {
    return GameBalance.calculateAttackDamage(attacker.attack, defender.defense);
  }

  int _calculateHeavyAttackDamage(Plantmon attacker, Plantmon defender) {
    return GameBalance.calculateHeavyAttackDamage(
      attacker.attack,
      defender.defense,
    );
  }

  void _interruptEntity(TimelineEntity entity) {
    entity.isInterrupted = true;
    entity.position = GameBalance.playerMidStart;
    entity.phase = TimelinePhase.waiting;
    entity.queuedAction = null;
    entity.targetId = null;
    entity.isAttacking = false;

    if (_selectedEntityId == entity.id) {
      _selectedEntityId = null;
    }

    onInterrupt?.call(entity.id);
    onNotification?.call(
      '${entity.plantmon.name} interrupted!',
      entity.id,
      byPlayer: !entity.isPlayer,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      entity.isInterrupted = false;
      notifyListeners();
    });
  }

  void _resetEntity(TimelineEntity entity) {
    entity.position = 0.0;
    entity.phase = TimelinePhase.waiting;
    entity.queuedAction = null;
    entity.targetId = null;
    entity.isAttacking = false;
    entity.isInterrupted = false;
    entity.mp += GameBalance.mpGainPerLoop;
  }

  bool _checkBattleOver() {
    final playersAlive = _timeline.any((e) => e.isPlayer && !e.isDead);
    final enemiesAlive = _timeline.any((e) => !e.isPlayer && !e.isDead);
    return !playersAlive || !enemiesAlive;
  }

  void _pauseTimeline() {
    _isTimelinePaused = true;
  }

  void _resumeTimelineIfPossible() {
    final awaitingInput = _timeline.any(
      (entity) => entity.phase == TimelinePhase.awaitingInput,
    );
    if (!awaitingInput && !_isSelectingTarget) {
      _isTimelinePaused = false;
    }
  }

  void _stopTimeline() {
    _isRunning = false;
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  void _triggerDeathAnimation(TimelineEntity entity) {
    entity.isPlayingDeathAnimation = true;
    entity.deathAnimationProgress = 0.0;
    _anyDeathAnimationsPlaying = true;
    notifyListeners();
  }

  void updateDeathAnimations(double dt) {
    bool anyStillPlaying = false;

    for (final entity in _timeline) {
      if (entity.isPlayingDeathAnimation) {
        entity.deathAnimationProgress += dt / 2.0;

        if (entity.deathAnimationProgress >= 1.0) {
          entity.deathAnimationProgress = 1.0;
          entity.isPlayingDeathAnimation = false;
        } else {
          anyStillPlaying = true;
        }
      }
    }

    if (_anyDeathAnimationsPlaying != anyStillPlaying) {
      _anyDeathAnimationsPlaying = anyStillPlaying;
      notifyListeners();
    }
  }

  BattleResult getBattleResult() {
    final playersAlive = _timeline.any((e) => e.isPlayer && !e.isDead);

    if (playersAlive) {
      final multiplier =
          1 + (_currentFloor * GameBalance.rewardMultiplierPerFloor);
      final exp = (GameBalance.baseExpReward * multiplier).round();

      final stars = GameBalance.getStarRewardForFloor(_currentFloor);

      return BattleResult(
        isWin: true,
        isVictory: true,
        message: 'VICTORY!',
        expGained: exp,
        starsEarned: stars,
      );
    } else {
      return const BattleResult(
        isWin: false,
        isVictory: false,
        message: 'DEFEAT',
        expGained: 10,
        starsEarned: 0,
      );
    }
  }

  void reset() {
    _stopTimeline();
    _timeline.clear();
    _selectedEntityId = null;
    _currentFloor = 1;
    _isTimelinePaused = false;
    _isSelectingTarget = false;
    _pendingActionType = null;
    _pendingActorId = null;
    _started = false;
    _isExecutingAction = false;
    _anyDeathAnimationsPlaying = false;
    _turnCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimeline();
    super.dispose();
  }
}
