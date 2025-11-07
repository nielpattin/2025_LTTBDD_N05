enum SkillType { quick, power }

enum SkillCategory { attack, defend, special }

class Skill {
  final String id;
  final String name;
  final SkillType type;
  final SkillCategory category;
  final int baseDamage;
  final int energyCost;

  const Skill({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.baseDamage,
    required this.energyCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'category': category.name,
      'baseDamage': baseDamage,
      'energyCost': energyCost,
    };
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    // Handle missing type field for backward compatibility
    SkillType type = SkillType.quick;
    if (json['type'] != null) {
      try {
        type = SkillType.values.firstWhere(
          (e) => e.name == json['type'] as String,
        );
      } catch (e) {
        type = SkillType.quick;
      }
    }

    SkillCategory category = SkillCategory.attack;
    if (json['category'] != null) {
      try {
        category = SkillCategory.values.firstWhere(
          (e) => e.name == json['category'],
        );
      } catch (e) {
        category = SkillCategory.attack;
      }
    }

    return Skill(
      id: json['id'] as String,
      name: json['name'] as String,
      type: type,
      category: category,
      baseDamage: json['baseDamage'] as int,
      energyCost: json['energyCost'] as int,
    );
  }

  Skill copyWith({
    String? id,
    String? name,
    SkillType? type,
    SkillCategory? category,
    int? baseDamage,
    int? energyCost,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      baseDamage: baseDamage ?? this.baseDamage,
      energyCost: energyCost ?? this.energyCost,
    );
  }
}
