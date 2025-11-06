import 'plantmon.dart';

class Slot {
  final String id;
  final int index;
  final bool isUnlocked;
  final int unlockLevel;
  final Plantmon? plantmon;

  const Slot({
    required this.id,
    required this.index,
    required this.isUnlocked,
    required this.unlockLevel,
    this.plantmon,
  });

  bool get isEmpty => plantmon == null;

  Slot plant(Plantmon p) {
    return copyWith(plantmon: p);
  }

  Slot harvest() {
    return copyWith(plantmon: null, clearPlantmon: true);
  }

  Slot unlock() {
    return copyWith(isUnlocked: true);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
      'isUnlocked': isUnlocked,
      'unlockLevel': unlockLevel,
      'plantmon': plantmon?.toJson(),
    };
  }

  factory Slot.fromJson(Map<String, dynamic> json) {
    try {
      final idVal = json['id'];
      final indexVal = json['index'];
      final isUnlockedVal = json['isUnlocked'];
      final unlockLevelVal = json['unlockLevel'];

      if (idVal == null) throw Exception('Slot id is null');
      if (indexVal == null) throw Exception('Slot index is null');
      if (isUnlockedVal == null) throw Exception('Slot isUnlocked is null');
      if (unlockLevelVal == null) throw Exception('Slot unlockLevel is null');

      return Slot(
        id: idVal as String,
        index: indexVal as int,
        isUnlocked: isUnlockedVal as bool,
        unlockLevel: unlockLevelVal as int,
        plantmon: json['plantmon'] != null
            ? Plantmon.fromJson(json['plantmon'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      throw Exception('Error in Slot.fromJson: $e, JSON: $json');
    }
  }

  Slot copyWith({
    String? id,
    int? index,
    bool? isUnlocked,
    int? unlockLevel,
    Plantmon? plantmon,
    bool clearPlantmon = false,
  }) {
    return Slot(
      id: id ?? this.id,
      index: index ?? this.index,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockLevel: unlockLevel ?? this.unlockLevel,
      plantmon: clearPlantmon ? null : (plantmon ?? this.plantmon),
    );
  }
}

Map<int, int> slotUnlockLevels = {
  0: 1,
  1: 3,
  2: 3,
  3: 5,
  4: 5,
  5: 8,
  6: 8,
  7: 12,
  8: 12,
  9: 16,
  10: 16,
  11: 20,
};

int getSlotUnlockLevel(int slotIndex) {
  return slotUnlockLevels[slotIndex] ?? 99;
}
