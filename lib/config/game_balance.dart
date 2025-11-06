import 'dart:math';

/// Central configuration for all game balance values.
///
/// Edit this file to tune game difficulty, economy, and progression.
/// All values are organized by category for easy management.
class GameBalance {
  // ==========================================
  // SHOP & ECONOMY
  // ==========================================

  /// Shop prices (stars)
  static const int commonBallCost = 5;
  static const int rareBallCost = 20;
  static const int legendaryBallCost = 50;

  /// Shop unlock floors
  static const int commonBallUnlockFloor = 1;
  static const int rareBallUnlockFloor = 10;
  static const int legendaryBallUnlockFloor = 20;

  // ==========================================
  // BATTLE REWARDS
  // ==========================================

  /// Star rewards per floor tier
  static const int starsFloor1to10 = 5;
  static const int starsFloor11to20 = 8;
  static const int starsFloor21to50 = 15;
  static const int starsFloor51Plus = 20;
  static const int bossFloorBonusStars = 10; // Every 10th floor

  /// Battle rewards multiplier
  static const double rewardMultiplierPerFloor = 0.15;
  static const int baseExpReward = 50;

  // ==========================================
  // CARE SYSTEM
  // ==========================================

  /// Care action rewards
  static const int waterExpReward = 20;
  static const int fertilizerExpReward = 20;

  /// Care resource limits
  static const int maxWaterCharges = 5;
  static const int maxFertilizerCharges = 5;
  static const int chargeRegenHours = 1;

  // ==========================================
  // PLANTMON BASE STATS
  // ==========================================

  /// Base stat ranges (Level 1, before rarity multiplier)
  static const int basePowerMin = 8;
  static const int basePowerMax = 12;
  static const int baseDefenseMin = 6;
  static const int baseDefenseMax = 10;
  static const int baseSpeedMin = 5;
  static const int baseSpeedMax = 9;
  static const int baseHpMin = 40;
  static const int baseHpMax = 50;

  /// Rarity stat multipliers
  static const double commonMultiplier = 1.0;
  static const double uncommonMultiplier = 1.2; // Used for Rare Ball
  static const double rareMultiplier = 1.2;
  static const double epicMultiplier = 1.5;
  static const double legendaryMultiplier = 2.0;

  /// Level scaling multiplier per level
  static const double statScalingPerLevel = 0.1; // +10% stats per level

  // ==========================================
  // PLANTMON PROGRESSION
  // ==========================================

  /// Plantmon level-up bonuses
  static const int levelUpStatIncrease = 3; // +3 ATK/DEF/SPD per level
  static const int levelUpHpIncrease = 10; // +10 HP per level
  static const int expPerLevel = 100; // Level N needs N×100 EXP

  // ==========================================
  // PLAYER PROGRESSION
  // ==========================================

  /// Player level requirements
  static const int playerExpPerLevel = 120; // Level N needs N×120 EXP

  /// Starting resources
  static const int startingStars = 0;

  // ==========================================
  // COMBAT MECHANICS
  // ==========================================

  /// Damage formulas
  static const int minAttackDamage = 12;
  static const int minHeavyAttackDamage = 20;
  static const double heavyAttackMultiplier = 1.5;

  /// Heavy attack cost
  static const int heavyAttackMpCost = 20;

  /// Energy & MP
  static const int mpGainPerLoop = 10;
  static const int energyRegenPerSecond = 5;

  /// Timeline mechanics (advanced - don't change unless you know what you're doing)
  static const double timelineWaitRangeEnd = 0.7;
  static const double timelineCastStart = timelineWaitRangeEnd;
  static const double timelineCastEnd = 1.0;
  static const double playerMidStart = 0.35;
  static const double enemyStart = 0.0;
  static const int baseSpeed = 10;
  static const double speedScalar = 0.18;
  static const int baseSkillCooldown = 3;

  // ==========================================
  // TOWER FLOOR GENERATION
  // ==========================================

  /// Enemy generation rules
  static const int singleEnemyMaxFloor = 10;
  static const int singlePlayerMaxFloor = 10;
  
  /// Enemy stat multiplier for tower battles
  static const double enemyStatMultiplier = 1.2;

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Calculate attack damage: ATK - DEF/2, minimum 10
  static int calculateAttackDamage(int attackerAttack, int defenderDefense) {
    final baseDamage = attackerAttack;
    final finalDamage = max(
      minAttackDamage,
      baseDamage - (defenderDefense ~/ 2),
    );
    return finalDamage;
  }

  /// Calculate heavy attack damage: (ATK × 1.5) - DEF/2, minimum 15
  static int calculateHeavyAttackDamage(
    int attackerAttack,
    int defenderDefense,
  ) {
    final baseDamage = (attackerAttack * heavyAttackMultiplier).round();
    final finalDamage = max(
      minHeavyAttackDamage,
      baseDamage - (defenderDefense ~/ 2),
    );
    return finalDamage;
  }

  /// Get star reward for a specific floor
  static int getStarRewardForFloor(int floor) {
    int baseStars;
    if (floor >= 51) {
      baseStars = starsFloor51Plus;
    } else if (floor >= 21) {
      baseStars = starsFloor21to50;
    } else if (floor >= 11) {
      baseStars = starsFloor11to20;
    } else {
      baseStars = starsFloor1to10;
    }

    // Boss bonus every 10th floor
    if (floor % 10 == 0) {
      baseStars += bossFloorBonusStars;
    }

    return baseStars;
  }

  /// Calculate plantmon EXP requirement for level up
  static int getPlantmonExpRequirement(int level) => level * expPerLevel;

  /// Calculate player EXP requirement for level up
  static int getPlayerExpRequirement(int level) => level * playerExpPerLevel;

  /// Get max player party size for a specific floor
  static int getMaxPlayerPartySize(int floor) {
    return floor <= singlePlayerMaxFloor ? 1 : 2;
  }

  /// Get enemy count for a specific floor
  static int getEnemyCount(int floor, Random random) {
    if (floor <= singleEnemyMaxFloor) {
      return 1;
    } else {
      return random.nextInt(2) + 1;
    }
  }
}
