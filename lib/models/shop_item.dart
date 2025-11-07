enum ShopItemType { seedBall, fertilizer, slotExpansion }

enum BallTier { common, rare, legendary }

const ballTierNames = {
  BallTier.common: 'Common',
  BallTier.rare: 'Rare',
  BallTier.legendary: 'Legendary',
};

const shopItemTypeNames = {
  ShopItemType.seedBall: 'Quả Cầu Hạt Giống',
  ShopItemType.fertilizer: 'Phân Bón',
  ShopItemType.slotExpansion: 'Mở Rộng Vườn',
};

class ShopItem {
  final String id;
  final String name;
  final ShopItemType type;
  final int cost;
  final String description;
  final String sprite;
  final Map<String, dynamic> data;
  final BallTier? tier;
  final int? starCost;
  final int? unlockFloor;

  const ShopItem({
    required this.id,
    required this.name,
    required this.type,
    required this.cost,
    required this.description,
    required this.sprite,
    this.data = const {},
    this.tier,
    this.starCost,
    this.unlockFloor,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'cost': cost,
      'description': description,
      'sprite': sprite,
      'data': data,
      'tier': tier?.name,
      'starCost': starCost,
      'unlockFloor': unlockFloor,
    };
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ShopItemType.values.firstWhere((e) => e.name == json['type']),
      cost: json['cost'] as int,
      description: json['description'] as String,
      sprite: json['sprite'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      tier: json['tier'] != null 
          ? BallTier.values.firstWhere((e) => e.name == json['tier'])
          : null,
      starCost: json['starCost'] as int?,
      unlockFloor: json['unlockFloor'] as int?,
    );
  }
}
