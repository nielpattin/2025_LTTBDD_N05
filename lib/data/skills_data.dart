import '../models/skill.dart';

// ===== ATTACK SKILLS (Tấn công thường) =====
const attackSkills = [
  Skill(
    id: 'attack_001',
    name: 'Đâm',
    type: SkillType.quick,
    category: SkillCategory.attack,
    baseDamage: 20,
    energyCost: 30,
  ),
  Skill(
    id: 'attack_002',
    name: 'Chém',
    type: SkillType.quick,
    category: SkillCategory.attack,
    baseDamage: 22,
    energyCost: 30,
  ),
  Skill(
    id: 'attack_003',
    name: 'Cắn',
    type: SkillType.quick,
    category: SkillCategory.attack,
    baseDamage: 18,
    energyCost: 30,
  ),
  Skill(
    id: 'attack_004',
    name: 'Roi',
    type: SkillType.quick,
    category: SkillCategory.attack,
    baseDamage: 19,
    energyCost: 30,
  ),
];

// ===== DEFEND SKILLS (Phòng thủ) =====
const defendSkills = [
  Skill(
    id: 'defend_001',
    name: 'Bảo Vệ',
    type: SkillType.quick,
    category: SkillCategory.defend,
    baseDamage: 0,
    energyCost: 40,
  ),
  Skill(
    id: 'defend_002',
    name: 'Cứng Cáp',
    type: SkillType.quick,
    category: SkillCategory.defend,
    baseDamage: 0,
    energyCost: 40,
  ),
  Skill(
    id: 'defend_003',
    name: 'Che Chắn',
    type: SkillType.quick,
    category: SkillCategory.defend,
    baseDamage: 0,
    energyCost: 40,
  ),
];

// ===== DAMAGE SKILLS (Tấn công nâng cao) =====
const damageSkills = [
  Skill(
    id: 'damage_001',
    name: 'Tia Mặt Trời',
    type: SkillType.power,
    category: SkillCategory.special,
    baseDamage: 60,
    energyCost: 80,
  ),
  Skill(
    id: 'damage_002',
    name: 'Đập Mạnh',
    type: SkillType.power,
    category: SkillCategory.special,
    baseDamage: 65,
    energyCost: 80,
  ),
  Skill(
    id: 'damage_003',
    name: 'Bão',
    type: SkillType.power,
    category: SkillCategory.special,
    baseDamage: 55,
    energyCost: 80,
  ),
  Skill(
    id: 'damage_004',
    name: 'Nổ',
    type: SkillType.power,
    category: SkillCategory.special,
    baseDamage: 58,
    energyCost: 80,
  ),
  Skill(
    id: 'damage_005',
    name: 'Vụ Nổ',
    type: SkillType.power,
    category: SkillCategory.special,
    baseDamage: 62,
    energyCost: 80,
  ),
  Skill(
    id: 'damage_006',
    name: 'Xoay',
    type: SkillType.quick,
    category: SkillCategory.special,
    baseDamage: 45,
    energyCost: 50,
  ),
];

final allSkills = [...attackSkills, ...defendSkills, ...damageSkills];

Skill? getSkillById(String id) {
  try {
    return allSkills.firstWhere((skill) => skill.id == id);
  } catch (e) {
    return null;
  }
}

/// Get a random attack skill
Skill getRandomAttackSkill() {
  return attackSkills[DateTime.now().millisecond % attackSkills.length];
}

/// Get a random defend skill
Skill getRandomDefendSkill() {
  return defendSkills[DateTime.now().millisecond % defendSkills.length];
}

/// Get a random damage skill
Skill getRandomDamageSkill() {
  return damageSkills[DateTime.now().millisecond % damageSkills.length];
}

/// Get 2-3 balanced skills: 1 attack, 1 defend, 1 damage
List<Skill> getBalancedSkillSet({int totalSkills = 3}) {
  assert(totalSkills >= 2 && totalSkills <= 3, 'totalSkills must be 2-3');

  final skills = <Skill>[];

  // Always add 1 attack and 1 defend
  skills.add(getRandomAttackSkill());
  skills.add(getRandomDefendSkill());

  // Add damage skill if totalSkills >= 3
  if (totalSkills >= 3) {
    skills.add(getRandomDamageSkill());
  }

  return skills;
}
