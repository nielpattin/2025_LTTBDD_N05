enum SkillType { quick, power }

class Skill {
  final String id;
  final String name;
  final SkillType type;
  final int baseDamage;
  final int energyCost;
  final String description;

  const Skill({
    required this.id,
    required this.name,
    required this.type,
    required this.baseDamage,
    required this.energyCost,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'baseDamage': baseDamage,
      'energyCost': energyCost,
      'description': description,
    };
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      name: json['name'] as String,
      type: SkillType.values.firstWhere((e) => e.name == json['type']),
      baseDamage: json['baseDamage'] as int,
      energyCost: json['energyCost'] as int,
      description: json['description'] as String,
    );
  }

  Skill copyWith({
    String? id,
    String? name,
    SkillType? type,
    int? baseDamage,
    int? energyCost,
    String? description,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      baseDamage: baseDamage ?? this.baseDamage,
      energyCost: energyCost ?? this.energyCost,
      description: description ?? this.description,
    );
  }
}
