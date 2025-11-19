/// Enum for reward item types
enum RewardItemType {
  evolutionItem,
  newSkill,
  legendaryEvolution,
  rareItem,
  coin,
}

/// Model for care system reward items
class CareRewardItem {
  final String id;
  final String name;
  final String description;
  final RewardItemType type;
  final int rarity; // 1-5, where 5 is rarest
  final String? iconEmoji;

  const CareRewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    this.iconEmoji,
  });

  factory CareRewardItem.evolutionItem() {
    return const CareRewardItem(
      id: 'reward_evolution_item_7day',
      name: 'Evolution Crystal',
      description:
          'Unlocked after 7-day care streak. Allows special evolution branch.',
      type: RewardItemType.evolutionItem,
      rarity: 4,
      iconEmoji: '💎',
    );
  }

  factory CareRewardItem.newSkill() {
    return const CareRewardItem(
      id: 'reward_new_skill_14day',
      name: 'Skill Tome',
      description:
          'Unlocked after 14-day care streak. Teaches a new powerful skill.',
      type: RewardItemType.newSkill,
      rarity: 4,
      iconEmoji: '📖',
    );
  }

  factory CareRewardItem.legendaryEvolution() {
    return const CareRewardItem(
      id: 'reward_legendary_evo_30day',
      name: 'Legendary Evolution Stone',
      description: 'Unlocked after 30-day care streak. Enables ultimate form.',
      type: RewardItemType.legendaryEvolution,
      rarity: 5,
      iconEmoji: '👑',
    );
  }

  factory CareRewardItem.rareItem() {
    return const CareRewardItem(
      id: 'reward_rare_item',
      name: 'Rare Treasure',
      description: 'Dropped during excellent care quality moments.',
      type: RewardItemType.rareItem,
      rarity: 3,
      iconEmoji: '🎁',
    );
  }

  factory CareRewardItem.goldenHourBonus() {
    return const CareRewardItem(
      id: 'reward_golden_hour_bonus',
      name: 'Golden Hour Blessing',
      description: 'Care bonus during peak hours (12:00-13:00).',
      type: RewardItemType.coin,
      rarity: 2,
      iconEmoji: '⭐',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'rarity': rarity,
      'iconEmoji': iconEmoji,
    };
  }

  factory CareRewardItem.fromJson(Map<String, dynamic> json) {
    return CareRewardItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: RewardItemType.values.firstWhere((e) => e.name == json['type']),
      rarity: json['rarity'] as int,
      iconEmoji: json['iconEmoji'] as String?,
    );
  }
}
