import 'skill.dart';
import 'seed.dart';

class Plantmon {
  final String id;
  final String name;
  final String plantType;
  final int level;
  final int exp;
  final int power;
  final int defense;
  final int speed;
  final int maxHp;
  final int currentHp;
  final List<Skill> skills;
  final int evolutionStage;
  final String sprite;
  final Rarity rarity;
  final DateTime createdAt;
  final DateTime lastCaredAt;

  const Plantmon({
    required this.id,
    required this.name,
    required this.plantType,
    required this.level,
    required this.exp,
    required this.power,
    required this.defense,
    required this.speed,
    required this.maxHp,
    required this.currentHp,
    required this.skills,
    required this.evolutionStage,
    required this.sprite,
    required this.rarity,
    required this.createdAt,
    required this.lastCaredAt,
  });

  int get expToNextLevel => _calculateExpRequirement(level);

  static int _calculateExpRequirement(int level) => level * 100;

  bool get isDead => currentHp <= 0;

  Plantmon addExp(int amount) {
    final newExp = exp + amount;
    final expNeeded = expToNextLevel;

    if (newExp >= expNeeded) {
      return levelUp().copyWith(exp: newExp - expNeeded);
    }

    return copyWith(exp: newExp);
  }

  Plantmon levelUp() {
    final statIncrease = 2;
    final hpIncrease = 5;

    return copyWith(
      level: level + 1,
      exp: 0,
      power: power + statIncrease,
      defense: defense + statIncrease,
      speed: speed + statIncrease,
      maxHp: maxHp + hpIncrease,
      currentHp: maxHp + hpIncrease,
    );
  }

  bool canEvolve() {
    if (evolutionStage == 0 && level >= 5) return true;
    if (evolutionStage == 1 && level >= 15) return true;
    if (evolutionStage == 2 && level >= 30) return true;
    return false;
  }

  Plantmon evolve() {
    if (!canEvolve()) return this;

    final statBoost = 5;
    final hpBoost = 20;

    return copyWith(
      evolutionStage: evolutionStage + 1,
      power: power + statBoost,
      defense: defense + statBoost,
      speed: speed + statBoost,
      maxHp: maxHp + hpBoost,
      currentHp: maxHp + hpBoost,
      sprite: '${plantType}_stage${evolutionStage + 1}',
    );
  }

  Plantmon heal(int amount) {
    final newHp = (currentHp + amount).clamp(0, maxHp);
    return copyWith(currentHp: newHp);
  }

  Plantmon takeDamage(int amount) {
    final newHp = (currentHp - amount).clamp(0, maxHp);
    return copyWith(currentHp: newHp);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plantType': plantType,
      'level': level,
      'exp': exp,
      'power': power,
      'defense': defense,
      'speed': speed,
      'maxHp': maxHp,
      'currentHp': currentHp,
      'skills': skills.map((s) => s.toJson()).toList(),
      'evolutionStage': evolutionStage,
      'sprite': sprite,
      'rarity': rarity.name,
      'createdAt': createdAt.toIso8601String(),
      'lastCaredAt': lastCaredAt.toIso8601String(),
    };
  }

  factory Plantmon.fromJson(Map<String, dynamic> json) {
    return Plantmon(
      id: json['id'] as String,
      name: json['name'] as String,
      plantType: json['plantType'] as String,
      level: json['level'] as int,
      exp: json['exp'] as int,
      power: json['power'] as int,
      defense: json['defense'] as int,
      speed: json['speed'] as int,
      maxHp: json['maxHp'] as int,
      currentHp: json['currentHp'] as int,
      skills: (json['skills'] as List)
          .map((s) => Skill.fromJson(s as Map<String, dynamic>))
          .toList(),
      evolutionStage: json['evolutionStage'] as int,
      sprite: json['sprite'] as String,
      rarity: Rarity.values.firstWhere((e) => e.name == json['rarity']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastCaredAt: DateTime.parse(json['lastCaredAt'] as String),
    );
  }

  Plantmon copyWith({
    String? id,
    String? name,
    String? plantType,
    int? level,
    int? exp,
    int? power,
    int? defense,
    int? speed,
    int? maxHp,
    int? currentHp,
    List<Skill>? skills,
    int? evolutionStage,
    String? sprite,
    Rarity? rarity,
    DateTime? createdAt,
    DateTime? lastCaredAt,
  }) {
    return Plantmon(
      id: id ?? this.id,
      name: name ?? this.name,
      plantType: plantType ?? this.plantType,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      power: power ?? this.power,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      skills: skills ?? this.skills,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      sprite: sprite ?? this.sprite,
      rarity: rarity ?? this.rarity,
      createdAt: createdAt ?? this.createdAt,
      lastCaredAt: lastCaredAt ?? this.lastCaredAt,
    );
  }
}
