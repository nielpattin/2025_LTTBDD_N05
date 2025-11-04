import 'plantmon.dart';

enum PotType { basic, wooden, ceramic, golden }

const potTypeNames = {
  PotType.basic: 'Chậu Cơ Bản',
  PotType.wooden: 'Chậu Gỗ',
  PotType.ceramic: 'Chậu Sứ',
  PotType.golden: 'Chậu Vàng',
};

const potExpMultipliers = {
  PotType.basic: 1.0,
  PotType.wooden: 1.1,
  PotType.ceramic: 1.25,
  PotType.golden: 1.5,
};

class Pot {
  final String id;
  final int slotIndex;
  final bool isUnlocked;
  final int unlockCost;
  final Plantmon? plantmon;
  final PotType type;

  const Pot({
    required this.id,
    required this.slotIndex,
    required this.isUnlocked,
    required this.unlockCost,
    this.plantmon,
    this.type = PotType.basic,
  });

  bool get isEmpty => plantmon == null;

  double get expMultiplier => potExpMultipliers[type] ?? 1.0;

  Pot plant(Plantmon p) {
    return copyWith(plantmon: p);
  }

  Pot harvest() {
    return copyWith(plantmon: null, clearPlantmon: true);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slotIndex': slotIndex,
      'isUnlocked': isUnlocked,
      'unlockCost': unlockCost,
      'plantmon': plantmon?.toJson(),
      'type': type.name,
    };
  }

  factory Pot.fromJson(Map<String, dynamic> json) {
    return Pot(
      id: json['id'] as String,
      slotIndex: json['slotIndex'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      unlockCost: json['unlockCost'] as int,
      plantmon: json['plantmon'] != null
          ? Plantmon.fromJson(json['plantmon'] as Map<String, dynamic>)
          : null,
      type: PotType.values.firstWhere((e) => e.name == json['type']),
    );
  }

  Pot copyWith({
    String? id,
    int? slotIndex,
    bool? isUnlocked,
    int? unlockCost,
    Plantmon? plantmon,
    PotType? type,
    bool clearPlantmon = false,
  }) {
    return Pot(
      id: id ?? this.id,
      slotIndex: slotIndex ?? this.slotIndex,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockCost: unlockCost ?? this.unlockCost,
      plantmon: clearPlantmon ? null : (plantmon ?? this.plantmon),
      type: type ?? this.type,
    );
  }
}
