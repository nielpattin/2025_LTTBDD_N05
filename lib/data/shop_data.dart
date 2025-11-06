import '../models/shop_item.dart';
import '../config/game_balance.dart';

final shopInventory = [
  const ShopItem(
    id: 'shop_seedball_common',
    name: 'Common Ball',
    type: ShopItemType.seedBall,
    cost: 0,
    starCost: GameBalance.commonBallCost,
    description: 'Choose 1 of 3 Common Plantmon (Level 1-3)',
    sprite: 'spa',
    tier: BallTier.common,
    unlockFloor: GameBalance.commonBallUnlockFloor,
    data: {'plantmonCount': 3},
  ),
  const ShopItem(
    id: 'shop_seedball_rare',
    name: 'Rare Ball',
    type: ShopItemType.seedBall,
    cost: 0,
    starCost: GameBalance.rareBallCost,
    description: 'Choose 1 of 3 Rare Plantmon (Level 4-7)',
    sprite: 'spa',
    tier: BallTier.rare,
    unlockFloor: GameBalance.rareBallUnlockFloor,
    data: {'plantmonCount': 3},
  ),
  const ShopItem(
    id: 'shop_seedball_legendary',
    name: 'Legendary Ball',
    type: ShopItemType.seedBall,
    cost: 0,
    starCost: GameBalance.legendaryBallCost,
    description: 'Choose 1 of 3 Legendary Plantmon (Level 8-10)',
    sprite: 'spa',
    tier: BallTier.legendary,
    unlockFloor: GameBalance.legendaryBallUnlockFloor,
    data: {'plantmonCount': 3},
  ),
];

ShopItem? getShopItemById(String id) {
  try {
    return shopInventory.firstWhere((item) => item.id == id);
  } catch (e) {
    return null;
  }
}

List<ShopItem> getShopItemsByType(ShopItemType type) {
  return shopInventory.where((item) => item.type == type).toList();
}
