import '../config/game_balance.dart';

class Plantmon {
  final String id;
  final String type;
  final String name;
  final int level;
  final int exp;
  final int hp;
  final int maxHp;
  final int attack;
  final int defense;
  final int speed;

  Plantmon({
    required this.id,
    required this.type,
    required this.name,
    required this.level,
    required this.exp,
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
  });

  int get expToNextLevel => GameBalance.getPlantmonExpRequirement(level);

  Plantmon addExp(int amount) {
    final newExp = exp + amount;
    final expNeeded = expToNextLevel;

    if (newExp >= expNeeded) {
      return levelUp().copyWith(exp: newExp - expNeeded);
    }

    return copyWith(exp: newExp);
  }

  Plantmon levelUp() {
    const statIncrease = GameBalance.levelUpStatIncrease;
    const hpIncrease = GameBalance.levelUpHpIncrease;

    return copyWith(
      level: level + 1,
      exp: 0,
      hp: hp + hpIncrease,
      maxHp: maxHp + hpIncrease,
      attack: attack + statIncrease,
      defense: defense + statIncrease,
      speed: speed + statIncrease,
    );
  }

  // ===== JSON SERIALIZATION =====

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'level': level,
      'exp': exp,
      'hp': hp,
      'maxHp': maxHp,
      'attack': attack,
      'defense': defense,
      'speed': speed,
    };
  }

  factory Plantmon.fromJson(Map<String, dynamic> json) {
    try {
      final idVal = json['id'];
      final typeVal = json['type'];
      final nameVal = json['name'];
      final levelVal = json['level'];
      final expVal = json['exp'];
      final hpVal = json['hp'];
      final attackVal = json['attack'];
      final defenseVal = json['defense'];
      final speedVal = json['speed'];

      if (idVal == null) throw Exception('Plantmon id is null');
      if (typeVal == null) throw Exception('Plantmon type is null');
      if (nameVal == null) throw Exception('Plantmon name is null');
      if (levelVal == null) throw Exception('Plantmon level is null');
      if (expVal == null) throw Exception('Plantmon exp is null');
      if (hpVal == null) throw Exception('Plantmon hp is null');
      if (attackVal == null) throw Exception('Plantmon attack is null');
      if (defenseVal == null) throw Exception('Plantmon defense is null');
      if (speedVal == null) throw Exception('Plantmon speed is null');

      return Plantmon(
        id: idVal as String,
        type: typeVal as String,
        name: nameVal as String,
        level: levelVal as int,
        exp: expVal as int,
        hp: hpVal as int,
        maxHp: json['maxHp'] as int? ?? hpVal,
        attack: attackVal as int,
        defense: defenseVal as int,
        speed: speedVal as int,
      );
    } catch (e) {
      rethrow;
    }
  }

  Plantmon copyWith({
    String? id,
    String? type,
    String? name,
    int? level,
    int? exp,
    int? hp,
    int? maxHp,
    int? attack,
    int? defense,
    int? speed,
  }) {
    return Plantmon(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
    );
  }

  @override
  String toString() {
    return 'Plantmon(id: $id, name: $name, level: $level, type: $type)';
  }
}
