import '../config/game_balance.dart';

class CareResources {
  final int waterCharges;
  final int fertilizerCharges;
  final DateTime? lastWaterRegen;
  final DateTime? lastFertilizerRegen;

  CareResources({
    this.waterCharges = GameBalance.maxWaterCharges,
    this.fertilizerCharges = GameBalance.maxFertilizerCharges,
    this.lastWaterRegen,
    this.lastFertilizerRegen,
  });

  bool canUseWater() => waterCharges > 0;
  bool canUseFertilizer() => fertilizerCharges > 0;

  CareResources useWater() {
    if (!canUseWater()) return this;
    return copyWith(
      waterCharges: waterCharges - 1,
      lastWaterRegen: lastWaterRegen ?? DateTime.now(),
    );
  }

  CareResources useFertilizer() {
    if (!canUseFertilizer()) return this;
    return copyWith(
      fertilizerCharges: fertilizerCharges - 1,
      lastFertilizerRegen: lastFertilizerRegen ?? DateTime.now(),
    );
  }

  CareResources regenerate() {
    final now = DateTime.now();
    int newWater = waterCharges;
    DateTime? newWaterRegen = lastWaterRegen;
    int newFert = fertilizerCharges;
    DateTime? newFertRegen = lastFertilizerRegen;

    if (waterCharges < GameBalance.maxWaterCharges && lastWaterRegen != null) {
      final hoursSince = now.difference(lastWaterRegen!).inHours;
      if (hoursSince > 0) {
        newWater = (waterCharges + hoursSince).clamp(
          0,
          GameBalance.maxWaterCharges,
        );
        if (newWater < GameBalance.maxWaterCharges) {
          newWaterRegen = lastWaterRegen!.add(Duration(hours: hoursSince));
        } else {
          newWaterRegen = null;
        }
      }
    }

    if (fertilizerCharges < GameBalance.maxFertilizerCharges &&
        lastFertilizerRegen != null) {
      final hoursSince = now.difference(lastFertilizerRegen!).inHours;
      if (hoursSince > 0) {
        newFert = (fertilizerCharges + hoursSince).clamp(
          0,
          GameBalance.maxFertilizerCharges,
        );
        if (newFert < GameBalance.maxFertilizerCharges) {
          newFertRegen = lastFertilizerRegen!.add(Duration(hours: hoursSince));
        } else {
          newFertRegen = null;
        }
      }
    }

    if (newWater != waterCharges ||
        newFert != fertilizerCharges ||
        newWaterRegen != lastWaterRegen ||
        newFertRegen != lastFertilizerRegen) {}

    return copyWith(
      waterCharges: newWater,
      fertilizerCharges: newFert,
      lastWaterRegen: newWaterRegen,
      lastFertilizerRegen: newFertRegen,
    );
  }

  Duration? getWaterRegenTimeRemaining() {
    if (waterCharges >= GameBalance.maxWaterCharges || lastWaterRegen == null) {
      return null;
    }
    final nextRegen = lastWaterRegen!.add(
      Duration(hours: GameBalance.chargeRegenHours),
    );
    final remaining = nextRegen.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Duration? getFertilizerRegenTimeRemaining() {
    if (fertilizerCharges >= GameBalance.maxFertilizerCharges ||
        lastFertilizerRegen == null) {
      return null;
    }
    final nextRegen = lastFertilizerRegen!.add(
      Duration(hours: GameBalance.chargeRegenHours),
    );
    final remaining = nextRegen.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static String formatDuration(Duration? duration) {
    if (duration == null) return 'Full';
    if (duration.inSeconds <= 0) return 'Ready';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toJson() => {
    'waterCharges': waterCharges,
    'fertilizerCharges': fertilizerCharges,
    'lastWaterRegen': lastWaterRegen?.toIso8601String(),
    'lastFertilizerRegen': lastFertilizerRegen?.toIso8601String(),
  };

  factory CareResources.fromJson(Map<String, dynamic> json) => CareResources(
    waterCharges: json['waterCharges'] as int? ?? GameBalance.maxWaterCharges,
    fertilizerCharges:
        json['fertilizerCharges'] as int? ?? GameBalance.maxFertilizerCharges,
    lastWaterRegen: json['lastWaterRegen'] != null
        ? DateTime.parse(json['lastWaterRegen'])
        : null,
    lastFertilizerRegen: json['lastFertilizerRegen'] != null
        ? DateTime.parse(json['lastFertilizerRegen'])
        : null,
  );

  CareResources copyWith({
    int? waterCharges,
    int? fertilizerCharges,
    DateTime? lastWaterRegen,
    DateTime? lastFertilizerRegen,
  }) => CareResources(
    waterCharges: waterCharges ?? this.waterCharges,
    fertilizerCharges: fertilizerCharges ?? this.fertilizerCharges,
    lastWaterRegen: lastWaterRegen ?? this.lastWaterRegen,
    lastFertilizerRegen: lastFertilizerRegen ?? this.lastFertilizerRegen,
  );

  @override
  String toString() {
    return 'CareResources(water: $waterCharges/5, fert: $fertilizerCharges/5)';
  }
}
