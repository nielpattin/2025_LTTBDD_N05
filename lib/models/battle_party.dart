class BattleParty {
  final List<int> plantmonSlotIndices;
  final List<String>? consumableSeedIds;

  const BattleParty({
    required this.plantmonSlotIndices,
    this.consumableSeedIds,
  });

  bool get isValid =>
      plantmonSlotIndices.isNotEmpty && plantmonSlotIndices.length <= 2;

  int get size => plantmonSlotIndices.length;

  BattleParty copyWith({
    List<int>? plantmonSlotIndices,
    List<String>? consumableSeedIds,
  }) {
    return BattleParty(
      plantmonSlotIndices: plantmonSlotIndices ?? this.plantmonSlotIndices,
      consumableSeedIds: consumableSeedIds ?? this.consumableSeedIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plantmonSlotIndices': plantmonSlotIndices,
      'consumableSeedIds': consumableSeedIds,
    };
  }

  factory BattleParty.fromJson(Map<String, dynamic> json) {
    return BattleParty(
      plantmonSlotIndices: List<int>.from(json['plantmonSlotIndices'] as List),
      consumableSeedIds: json['consumableSeedIds'] != null
          ? List<String>.from(json['consumableSeedIds'] as List)
          : null,
    );
  }
}
