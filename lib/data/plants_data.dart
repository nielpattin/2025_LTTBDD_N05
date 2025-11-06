import 'dart:math';
import '../models/seed.dart';
import '../models/plantmon.dart';
import '../config/game_balance.dart';

final availablePlantmonSprites = [
  'assets/images/plants/Bellsprout.png',
  'assets/images/plants/Victreebel.png',
  'assets/images/plants/Bellossom.png',
  'assets/images/plants/Skiploom.png',
  'assets/images/plants/Sunkern.png',
  'assets/images/plants/Sunflora.png',
  'assets/images/plants/Roselia.png',
  'assets/images/plants/Cacnea.png',
  'assets/images/plants/Cradily.png',
  'assets/images/plants/Budew.png',
  'assets/images/plants/Cherubi.png',
  'assets/images/plants/Bonsly.png',
  'assets/images/plants/Carnivine.png',
  'assets/images/plants/Swadloon.png',
  'assets/images/plants/Cottonee.png',
  'assets/images/plants/Petilil.png',
  'assets/images/plants/Lilligant.png',
  'assets/images/plants/Maractus.png',
  'assets/images/plants/Flabebe.png',
  'assets/images/plants/Fomantis.png',
  'assets/images/plants/Bounsweet.png',
  'assets/images/plants/Applin.png',
  'assets/images/plants/Smoliv.png',
  'assets/images/plants/Dolliv.png',
  'assets/images/plants/Arboliva.png',
  'assets/images/plants/Scovillain.png',
];

final rarityStatMultipliers = {
  Rarity.common: GameBalance.commonMultiplier,
  Rarity.uncommon: GameBalance.uncommonMultiplier,
  Rarity.rare: GameBalance.rareMultiplier,
  Rarity.epic: GameBalance.epicMultiplier,
  Rarity.legendary: GameBalance.legendaryMultiplier,
};

class StatRanges {
  static const powerMin = GameBalance.basePowerMin;
  static const powerMax = GameBalance.basePowerMax;
  static const defenseMin = GameBalance.baseDefenseMin;
  static const defenseMax = GameBalance.baseDefenseMax;
  static const speedMin = GameBalance.baseSpeedMin;
  static const speedMax = GameBalance.baseSpeedMax;
  static const hpMin = GameBalance.baseHpMin;
  static const hpMax = GameBalance.baseHpMax;
}

String generatePlantmonId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(9999);
  return 'plantmon_${timestamp}_$random';
}

String getPlantNameFromSprite(String spritePath) {
  final filename = spritePath.split('/').last;
  final nameWithExt = filename.replaceAll(RegExp(r'^\d+_'), '');
  final name = nameWithExt.replaceAll('.png', '');
  return name;
}

Plantmon generateRandomPlantmon({
  required String sprite,
  required Rarity rarity,
  int? level,
}) {
  final random = Random();
  final targetLevel = level ?? 1;

  final basePower =
      random.nextInt(StatRanges.powerMax - StatRanges.powerMin + 1) +
      StatRanges.powerMin;
  final baseDefense =
      random.nextInt(StatRanges.defenseMax - StatRanges.defenseMin + 1) +
      StatRanges.defenseMin;
  final baseSpeed =
      random.nextInt(StatRanges.speedMax - StatRanges.speedMin + 1) +
      StatRanges.speedMin;
  final baseHp =
      random.nextInt(StatRanges.hpMax - StatRanges.hpMin + 1) +
      StatRanges.hpMin;

  final multiplier = rarityStatMultipliers[rarity] ?? 1.0;
  final levelMultiplier = 1.0 + ((targetLevel - 1) * GameBalance.statScalingPerLevel);

  return Plantmon(
    id: generatePlantmonId(),
    type: getPlantNameFromSprite(sprite),
    name: getPlantNameFromSprite(sprite),
    level: targetLevel,
    exp: 0,
    attack: (basePower * multiplier * levelMultiplier).round(),
    defense: (baseDefense * multiplier * levelMultiplier).round(),
    speed: (baseSpeed * multiplier * levelMultiplier).round(),
    hp: (baseHp * multiplier * levelMultiplier).round(),
    maxHp: (baseHp * multiplier * levelMultiplier).round(),
  );
}

List<Plantmon> generateSeedBall() {
  final random = Random();
  final result = <Plantmon>[];

  for (int i = 0; i < 3; i++) {
    final rarityRoll = random.nextDouble() * 100;
    Rarity rarity;
    if (rarityRoll < 70) {
      rarity = Rarity.common;
    } else if (rarityRoll < 90) {
      rarity = Rarity.uncommon;
    } else if (rarityRoll < 98) {
      rarity = Rarity.rare;
    } else if (rarityRoll < 99.5) {
      rarity = Rarity.epic;
    } else {
      rarity = Rarity.legendary;
    }

    final sprite =
        availablePlantmonSprites[random.nextInt(
          availablePlantmonSprites.length,
        )];

    result.add(generateRandomPlantmon(sprite: sprite, rarity: rarity));
  }

  return result;
}
