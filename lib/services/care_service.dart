import '../models/plantmon.dart';
import '../game/player_profile.dart';
import '../config/game_balance.dart';

enum CareQuality { poor, good, excellent }

class CareService {
  static const int waterExpReward = GameBalance.waterExpReward;
  static const int fertilizerExpReward = GameBalance.fertilizerExpReward;

  static bool canWater(PlayerProfile profile) {
    return profile.careResources.canUseWater();
  }

  static bool canFertilize(PlayerProfile profile) {
    return profile.careResources.canUseFertilizer();
  }

  static bool canCare(Plantmon plantmon) {
    return true;
  }

  static Future<Plantmon> performWater(
    PlayerProfile profile,
    Plantmon plantmon,
  ) async {
    if (!canWater(profile)) {
      return plantmon;
    }

    await profile.useWater();
    final updatedPlantmon = plantmon.addExp(waterExpReward);
    return updatedPlantmon;
  }

  static Future<Plantmon> performFertilize(
    PlayerProfile profile,
    Plantmon plantmon,
  ) async {
    if (!canFertilize(profile)) {
      return plantmon;
    }

    await profile.useFertilizer();
    final updatedPlantmon = plantmon.addExp(fertilizerExpReward);
    return updatedPlantmon;
  }

  static int getWaterExpReward(Plantmon plantmon) {
    return waterExpReward;
  }

  static int getFertilizerExpReward(Plantmon plantmon) {
    return fertilizerExpReward;
  }

  static int getExpReward(Plantmon plantmon) {
    return waterExpReward;
  }

  static CareQuality calculateCareQuality(Plantmon plantmon) {
    return CareQuality.good;
  }

  static bool shouldDropRareItem(Plantmon plantmon) {
    // 5% chance on any care action
    return DateTime.now().millisecond < 50;
  }

  /// Get care quality description
  static String getQualityDescription(CareQuality quality) {
    switch (quality) {
      case CareQuality.poor:
        return 'Care completed';
      case CareQuality.good:
        return 'Good care';
      case CareQuality.excellent:
        return 'Excellent care';
    }
  }

  static String getQualityHex(CareQuality quality) {
    switch (quality) {
      case CareQuality.poor:
        return '#FF5252';
      case CareQuality.good:
        return '#4CAF50';
      case CareQuality.excellent:
        return '#FFD700';
    }
  }
}
