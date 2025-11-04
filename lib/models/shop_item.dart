enum ShopItemType { seedBall, fertilizer, potUpgrade }

const shopItemTypeNames = {
  ShopItemType.seedBall: 'Quả Cầu Hạt Giống',
  ShopItemType.fertilizer: 'Phân Bón',
  ShopItemType.potUpgrade: 'Nâng Cấp Chậu',
};

class ShopItem {
  final String id;
  final String name;
  final ShopItemType type;
  final int cost;
  final String description;
  final String sprite;
  final Map<String, dynamic> data;

  const ShopItem({
    required this.id,
    required this.name,
    required this.type,
    required this.cost,
    required this.description,
    required this.sprite,
    this.data = const {},
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
    );
  }
}
