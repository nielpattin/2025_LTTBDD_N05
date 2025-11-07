import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../models/care_reward_item.dart';

/// Manages care system rewards and inventory
class RewardsState extends ChangeNotifier {
  late final SharedPreferencesAsync _prefs = StorageService().prefs;
  List<CareRewardItem> _earnedRewards = [];

  List<CareRewardItem> get earnedRewards => List.unmodifiable(_earnedRewards);

  int get totalRewards => _earnedRewards.length;

  /// Check if player has received a specific reward
  bool hasReward(String rewardId) {
    return _earnedRewards.any((r) => r.id == rewardId);
  }

  /// Count rewards by type
  int countByType(RewardItemType type) {
    return _earnedRewards.where((r) => r.type == type).length;
  }

  Future<void> load() async {
    final rewardsJson = await _prefs.getString('earned_rewards');

    if (rewardsJson != null) {
      final List<dynamic> decoded = jsonDecode(rewardsJson);
      _earnedRewards = decoded
          .map((json) => CareRewardItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      _earnedRewards = [];
    }

    notifyListeners();
  }

  Future<void> save() async {
    final rewardsJson = jsonEncode(
      _earnedRewards.map((r) => r.toJson()).toList(),
    );
    await _prefs.setString('earned_rewards', rewardsJson);
  }

  /// Add a reward when milestone is reached
  Future<void> addReward(CareRewardItem reward) async {
    if (!hasReward(reward.id)) {
      _earnedRewards.add(reward);
      await save();
      notifyListeners();
    }
  }

  /// Add rare item drop during excellent care
  Future<void> addRareItemDrop() async {
    await addReward(CareRewardItem.rareItem());
  }

  /// Get all earned rewards of a specific type
  List<CareRewardItem> getRewardsByType(RewardItemType type) {
    return _earnedRewards.where((r) => r.type == type).toList();
  }

  /// Clear all rewards (used for reset)
  Future<void> reset() async {
    _earnedRewards.clear();
    await save();
    notifyListeners();
  }
}
