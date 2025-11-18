import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../models/achievement.dart';
import '../models/care_resources.dart';
import '../config/game_balance.dart';
import '../models/slot.dart';
import '../models/plantmon.dart';
 
class PlayerProfile extends ChangeNotifier {
  late final SharedPreferencesAsync _prefs = StorageService().prefs;

  // Core profile fields
  int _stars = 0;
  bool _isFirstTime = true;
  int _level = 1;
  int _exp = 0;
  int _currentTowerFloor = 1;
  List<Achievement> _achievements = [];
  int _careStreak = 0;
  CareResources _careResources = CareResources();

  List<Slot> _slots = [];
  final int maxSlots = 12;

  List<Slot> get slots => List.unmodifiable(_slots);


  int get stars => _stars;
  bool get isFirstTime => _isFirstTime;
  int get level => _level;
  int get exp => _exp;
  int get currentTowerFloor => _currentTowerFloor;
  List<Achievement> get achievements => List.unmodifiable(_achievements);
  int get careStreak => _careStreak;
  CareResources get careResources => _careResources.regenerate();

  int get expToNextLevel => GameBalance.getPlayerExpRequirement(_level);

  double get expProgress => exp / expToNextLevel;

  // Garden helpers
  List<Slot> getUnlockedSlots() {
    return _slots.where((slot) => slot.isUnlocked).toList();
  }

  List<Slot> getEmptySlots() {
    return _slots.where((slot) => slot.isUnlocked && slot.isEmpty).toList();
  }

  bool hasEmptySlot() {
    return _slots.any((slot) => slot.isUnlocked && slot.isEmpty);
  }

  int getTotalPlantmons() {
    return _slots.where((slot) => slot.plantmon != null).length;
  }

  Slot? getNextLockedSlot() {
    try {
      return _slots.firstWhere((slot) => !slot.isUnlocked);
    } catch (e) {
      return null;
    }
  }

  Future<void> plantInSlot(int slotIndex, Plantmon plantmon) async {
    if (slotIndex >= 0 && slotIndex < _slots.length) {
      final slot = _slots[slotIndex];
      if (slot.isUnlocked && slot.isEmpty) {
        _slots[slotIndex] = slot.plant(plantmon);
        await _saveGarden();
        await updatePlantmonCount(getTotalPlantmons());
        notifyListeners();
      }
    }
  }

  Plantmon? getPlantmon(int slotIndex) {
    if (slotIndex >= 0 && slotIndex < _slots.length) {
      return _slots[slotIndex].plantmon;
    }
    return null;
  }

  Future<void> updatePlantmonInSlot(int slotIndex, Plantmon plantmon) async {
    if (slotIndex >= 0 && slotIndex < _slots.length) {
      final slot = _slots[slotIndex];
      if (!slot.isEmpty) {
        _slots[slotIndex] = slot.plant(plantmon);
        await _saveGarden();
        notifyListeners();
      }
    }
  }

  Future<void> harvestPlantmon(int slotIndex) async {
    if (slotIndex >= 0 && slotIndex < _slots.length) {
      _slots[slotIndex] = _slots[slotIndex].harvest();
      await _saveGarden();
      await updatePlantmonCount(getTotalPlantmons());
      notifyListeners();
    }
  }

  bool canUnlockSlotWithCoins(int slotIndex) {
    if (slotIndex >= _slots.length) {
      return false;
    }
    final slot = _slots[slotIndex];
    return !slot.isUnlocked;
  }

  Future<void> unlockSlotWithCoins(int slotIndex) async {
    if (slotIndex >= 0 && slotIndex < _slots.length) {
      _slots[slotIndex] = _slots[slotIndex].unlock();
      await _saveGarden();
      notifyListeners();
    }
  }

  Future<void> unlockSlotsForLevel(int playerLevel) async {
    bool changed = false;
    for (int i = 0; i < maxSlots; i++) {
      if (i >= _slots.length) {
        _slots.add(
          Slot(
            id: 'slot_$i',
            index: i,
            isUnlocked: false,
            unlockLevel: getSlotUnlockLevel(i),
          ),
        );
        changed = true;
      }

      if (!_slots[i].isUnlocked && playerLevel >= _slots[i].unlockLevel) {
        _slots[i] = _slots[i].unlock();
        changed = true;
      }
    }

    if (changed) {
      await _saveGarden();
      notifyListeners();
    }
  }

  Future<void> _loadGarden() async {
    _slots.clear();

    try {
      final slotsJson = await _prefs.getString('garden_slots');

      if (slotsJson != null) {
        final List<dynamic> decoded = jsonDecode(slotsJson);
        _slots = decoded.map((json) {
          return Slot.fromJson(json as Map<String, dynamic>);
        }).toList();
      } else {
        final oldPotsJson = await _prefs.getString('garden_pots');
        if (oldPotsJson != null) {
          await _migrateGardenFromPots(oldPotsJson);
        } else {
          _initializeDefaultSlot();
        }
      }

      _ensureAllSlotsExist();
    } catch (e) {
      _initializeDefaultSlot();
    }
  }

  Future<void> _migrateGardenFromPots(String potsJson) async {
    try {
      final List<dynamic> decoded = jsonDecode(potsJson);
      _slots = decoded.map((json) {
        final slotIndex = json['slotIndex'] as int;
        return Slot(
          id: 'slot_$slotIndex',
          index: slotIndex,
          isUnlocked: json['isUnlocked'] as bool,
          unlockLevel: getSlotUnlockLevel(slotIndex),
          plantmon: json['plantmon'] != null
              ? Plantmon.fromJson(json['plantmon'] as Map<String, dynamic>)
              : null,
        );
      }).toList();

      await _saveGarden();
    } catch (e) {
      _initializeDefaultSlot();
    }
  }

  Future<void> _saveGarden() async {
    try {
      final slotsJson = jsonEncode(_slots.map((s) => s.toJson()).toList());
      await _prefs.setString('garden_slots', slotsJson);
    } catch (e) {
      // ignore save errors for garden
    }
  }

  void _initializeDefaultSlot() {
    if (_slots.isEmpty) {
      _slots.add(
        Slot(id: 'slot_0', index: 0, isUnlocked: true, unlockLevel: 1),
      );
    }
  }

  void _ensureAllSlotsExist() {
    for (int i = 0; i < maxSlots; i++) {
      if (i >= _slots.length) {
        _slots.add(
          Slot(
            id: 'slot_$i',
            index: i,
            isUnlocked: false,
            unlockLevel: getSlotUnlockLevel(i),
          ),
        );
      }
    }
  }

  Future<void> load() async {
    _stars = await _prefs.getInt('stars') ?? 0;
    _isFirstTime = await _prefs.getBool('isFirstTime') ?? true;
    _level = await _prefs.getInt('level') ?? 1;
    _exp = await _prefs.getInt('exp') ?? 0;
    _currentTowerFloor = await _prefs.getInt('towerFloor') ?? 1;

    // Load garden slots
    await _loadGarden();


    // Load care streak system
    _careStreak = await _prefs.getInt('careStreak') ?? 0;

    final achievementsJson = await _prefs.getString('achievements');
    if (achievementsJson != null) {
      final List<dynamic> decoded = jsonDecode(achievementsJson);
      _achievements = decoded
          .map((json) => Achievement.fromJson(json))
          .toList();
    } else {
      _achievements = List.from(defaultAchievements);
    }

    final careResourcesJson = await _prefs.getString('careResources');
    if (careResourcesJson != null) {
      _careResources = CareResources.fromJson(jsonDecode(careResourcesJson));
    } else {
      _careResources = CareResources();
    }

    notifyListeners();
  }

  Future<void> save() async {
    await _prefs.setInt('stars', _stars);
    await _prefs.setBool('isFirstTime', _isFirstTime);
    await _prefs.setInt('level', _level);
    await _prefs.setInt('exp', _exp);
    await _prefs.setInt('towerFloor', _currentTowerFloor);

    // Persist garden slots
    await _saveGarden();

    // Save care streak system
    await _prefs.setInt('careStreak', _careStreak);

    final achievementsJson = jsonEncode(
      _achievements.map((a) => a.toJson()).toList(),
    );
    await _prefs.setString('achievements', achievementsJson);

    final careResourcesJson = jsonEncode(_careResources.toJson());
    await _prefs.setString('careResources', careResourcesJson);
  }

  Future<void> addStars(int amount) async {
    _stars += amount;
    await save();
    notifyListeners();
  }

  Future<void> spendStars(int amount) async {
    if (_stars >= amount) {
      _stars -= amount;
      await save();
      notifyListeners();
    }
  }

  bool canAffordStars(int amount) {
    return _stars >= amount;
  }

  Future<void> addExp(int amount) async {
    _exp += amount;
    _checkLevelUp();
    await save();
    notifyListeners();
  }

  void _checkLevelUp() {
    while (_exp >= expToNextLevel && _level < 99) {
      _exp -= expToNextLevel;
      _level++;
      _updateAchievement('level_5', _level);
      _updateAchievement('expert_trainer', _level);
      _updateAchievement('master_trainer', _level);
    }
  }

  Future<void> updatePlantmonCount(int count) async {

    _updateAchievement('first_plantmon', count);
    _updateAchievement('collector_i', count);
    _updateAchievement('collector_ii', count);
    _updateAchievement('full_garden', count);
    await save();
    notifyListeners();
  }

  void _updateAchievement(String id, int progress) {

    final index = _achievements.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _achievements[index] = _achievements[index].copyWith(progress: progress);
    }
  }

  Future<void> completeOnboarding() async {
    _isFirstTime = false;
    _stars = GameBalance.startingStars;
    _level = 1;
    _exp = 0;
    await save();
    notifyListeners();
  }

  Future<void> incrementTowerFloor() async {
    _currentTowerFloor++;
    await save();
    notifyListeners();
  }

  Future<void> resetProfile() async {
    _stars = 0;
    _isFirstTime = true;
    _level = 1;
    _exp = 0;
    _currentTowerFloor = 1;
    _careStreak = 0;
    _achievements = List.from(defaultAchievements);
    _careResources = CareResources();
    await save();
    notifyListeners();
  }

  Future<void> updateCareStreak() async {
    _careStreak++;
    await save();
    notifyListeners();
  }
 
  Future<void> resetCareStreak() async {
    _careStreak = 0;
    await save();
    notifyListeners();
  }
 
  Future<void> incrementCareStreak() async {
    _careStreak++;
    await save();
    notifyListeners();
  }


  Future<void> useWater() async {
    if (!_careResources.canUseWater()) {
      return;
    }
    _careResources = _careResources.useWater();
    await save();
    notifyListeners();
  }

  Future<void> useFertilizer() async {
    if (!_careResources.canUseFertilizer()) {
      return;
    }
    _careResources = _careResources.useFertilizer();
    await save();
    notifyListeners();
  }

  void triggerResourceRegeneration() {
    final before = _careResources;
    _careResources = _careResources.regenerate();
    if (before != _careResources) {
      save();
      notifyListeners();
    }
  }
}
