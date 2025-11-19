import '../config/game_balance.dart';

class Plantmon {
  final String id;
  final String name;
  final int level;
  final int exp;
  final int hp;
  final int maxHp;
  final int attack;
  final int defense;

  Plantmon({
    required this.id,
    required this.name,
    required this.level,
    required this.exp,
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
  });

  int get expToNextLevel => GameBalance.getPlantmonExpRequirement(level);

  Plantmon addExp(int amount) {
    final int newExp = exp + amount;
    final int expNeeded = expToNextLevel;

    if (newExp >= expNeeded) {
      return levelUp().copyWith(exp: newExp - expNeeded);
    }

    return copyWith(exp: newExp);
  }

  Plantmon levelUp() {
    const int statIncrease = GameBalance.levelUpStatIncrease;
    const int hpIncrease = GameBalance.levelUpHpIncrease;

    return copyWith(
      level: level + 1,
      exp: 0,
      hp: hp + hpIncrease,
      maxHp: maxHp + hpIncrease,
      attack: attack + statIncrease,
      defense: defense + statIncrease,
    );
  }

  // ===== JSON SERIALIZATION =====

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'level': level,
      'exp': exp,
      'hp': hp,
      'maxHp': maxHp,
      'attack': attack,
      'defense': defense,
    };
  }

  factory Plantmon.fromJson(Map<String, dynamic> json) {
    try {
      final Object? idVal = json['id'];
      final Object? nameVal = json['name'];
      final Object? levelVal = json['level'];
      final Object? expVal = json['exp'];
      final Object? hpVal = json['hp'];
      final Object? maxHpVal = json['maxHp'];
      final Object? attackVal = json['attack'];
      final Object? defenseVal = json['defense'];

      if (idVal == null) throw Exception('Plantmon id is null');
      if (nameVal == null) throw Exception('Plantmon name is null');
      if (levelVal == null) throw Exception('Plantmon level is null');
      if (expVal == null) throw Exception('Plantmon exp is null');
      if (hpVal == null) throw Exception('Plantmon hp is null');
      if (maxHpVal == null) throw Exception('Plantmon maxHp is null');
      if (attackVal == null) throw Exception('Plantmon attack is null');
      if (defenseVal == null) throw Exception('Plantmon defense is null');

      return Plantmon(
        id: idVal as String,
        name: nameVal as String,
        level: levelVal as int,
        exp: expVal as int,
        hp: hpVal as int,
        maxHp: maxHpVal as int,
        attack: attackVal as int,
        defense: defenseVal as int,
      );
    } catch (e) {
      rethrow;
    }
  }

  Plantmon copyWith({
    String? id,
    String? name,
    int? level,
    int? exp,
    int? hp,
    int? maxHp,
    int? attack,
    int? defense,
  }) {
    return Plantmon(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
    );
  }

  @override
  String toString() {
    return 'Plantmon(id: $id, name: $name, level: $level)';
  }
}
