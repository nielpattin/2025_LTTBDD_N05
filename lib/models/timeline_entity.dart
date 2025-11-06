import '../models/plantmon.dart';

enum ActionType { attack, defend, heavyAttack }

enum TimelinePhase { waiting, awaitingInput, casting }

class TimelineEntity {
  final String id;
  Plantmon plantmon; // mutable so battle state can update hp/mp
  final bool isPlayer;
  final String? spriteOverride; // For enemies with specific sprite paths
  double position; // 0.0 - 1.0 overall timeline progress
  TimelinePhase phase;
  ActionType? queuedAction;
  String? targetId;
  bool isInterrupted;
  bool isAttacking;
  int mp;
  bool isDefending;
  bool isPlayingDeathAnimation;
  double deathAnimationProgress;

  TimelineEntity({
    required this.id,
    required this.plantmon,
    required this.isPlayer,
    this.spriteOverride,
    this.position = 0.0,
    this.phase = TimelinePhase.waiting,
    this.queuedAction,
    this.targetId,
    this.isInterrupted = false,
    this.isAttacking = false,
    this.mp = 0,
    this.isDefending = false,
    this.isPlayingDeathAnimation = false,
    this.deathAnimationProgress = 0.0,
  });

  bool get isDead => plantmon.hp <= 0;
  bool get isCasting => phase == TimelinePhase.casting;
  bool get isAwaitingInput => phase == TimelinePhase.awaitingInput;
}
