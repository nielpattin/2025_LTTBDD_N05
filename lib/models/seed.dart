enum Rarity { common, uncommon, rare, epic, legendary }

const rarityNames = {
  Rarity.common: 'Phổ Biến',
  Rarity.uncommon: 'Không Phổ Biến',
  Rarity.rare: 'Hiếm',
  Rarity.epic: 'Cực Hiếm',
  Rarity.legendary: 'Huyền Thoại',
};

class Seed {
  final String id;
  final String plantType;
  final Rarity rarity;
  final String name;
  final String description;
  final String sprite;

  const Seed({
    required this.id,
    required this.plantType,
    required this.rarity,
    required this.name,
    required this.description,
    required this.sprite,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantType': plantType,
      'rarity': rarity.name,
      'name': name,
      'description': description,
      'sprite': sprite,
    };
  }

  factory Seed.fromJson(Map<String, dynamic> json) {
    return Seed(
      id: json['id'] as String,
      plantType: json['plantType'] as String,
      rarity: Rarity.values.firstWhere((e) => e.name == json['rarity']),
      name: json['name'] as String,
      description: json['description'] as String,
      sprite: json['sprite'] as String,
    );
  }

  Seed copyWith({
    String? id,
    String? plantType,
    Rarity? rarity,
    String? name,
    String? description,
    String? sprite,
  }) {
    return Seed(
      id: id ?? this.id,
      plantType: plantType ?? this.plantType,
      rarity: rarity ?? this.rarity,
      name: name ?? this.name,
      description: description ?? this.description,
      sprite: sprite ?? this.sprite,
    );
  }
}
