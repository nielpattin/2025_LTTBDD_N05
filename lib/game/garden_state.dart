import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../models/slot.dart';
import '../models/plantmon.dart';

class GardenState extends ChangeNotifier {
  late final SharedPreferencesAsync _prefs = StorageService().prefs;
  List<Slot> _slots = [];
  final int maxSlots = 12;

  List<Slot> get slots => List.unmodifiable(_slots);

  GardenState() {
    _initializeDefaultSlot();
  }

  void _initializeDefaultSlot() {
    if (_slots.isEmpty) {
      _slots.add(
        Slot(id: 'slot_0', index: 0, isUnlocked: true, unlockLevel: 1),
      );
    }
  }

  Future<void> load() async {
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
          await _migrateFromPots(oldPotsJson);
        } else {
          _initializeDefaultSlot();
        }
      }

      _ensureAllSlotsExist();
    } catch (e) {
      _initializeDefaultSlot();
    }

    notifyListeners();
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

  Future<void> _migrateFromPots(String potsJson) async {
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

      await save();
    } catch (e) {
      _initializeDefaultSlot();
    }
  }

  Future<void> save() async {
    try {
      final slotsJson = jsonEncode(_slots.map((s) => s.toJson()).toList());

      await _prefs.setString('garden_slots', slotsJson);
    } catch (e) {
      // Handle save error if necessary
    }
  }

  Future<void> plantInSlot(int slotIndex, Plantmon plantmon) async {
    if (slotIndex >= 0 && slotIndex < _slots.length) {
      final slot = _slots[slotIndex];
      if (slot.isUnlocked && slot.isEmpty) {
        _slots[slotIndex] = slot.plant(plantmon);

        await save();

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

  Future<void> updatePlantmon(int slotIndex, Plantmon plantmon) async {
    if (slotIndex >= 0 && slotIndex < _slots.length) {
      final slot = _slots[slotIndex];
      if (!slot.isEmpty) {
        _slots[slotIndex] = slot.plant(plantmon);
        await save();
        notifyListeners();
      }
    }
  }

  Future<void> harvestPlantmon(int slotIndex) async {
    if (slotIndex >= 0 && slotIndex < _slots.length) {
      _slots[slotIndex] = _slots[slotIndex].harvest();
      await save();
      notifyListeners();
    }
  }

  List<Slot> getUnlockedSlots() {
    return _slots.where((slot) => slot.isUnlocked).toList();
  }

  List<Slot> getEmptySlots() {
    return _slots.where((slot) => slot.isUnlocked && slot.isEmpty).toList();
  }

  bool hasEmptySlot() {
    return _slots.any((slot) => slot.isUnlocked && slot.isEmpty);
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
      await save();
      notifyListeners();
    }
  }

  bool canUnlockSlotWithCoins(int slotIndex) {
    if (slotIndex >= _slots.length) return false;
    final slot = _slots[slotIndex];
    return !slot.isUnlocked;
  }

  Future<void> unlockSlotWithCoins(int slotIndex) async {
    if (slotIndex >= 0 && slotIndex < _slots.length) {
      _slots[slotIndex] = _slots[slotIndex].unlock();
      await save();
      notifyListeners();
    }
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
}
