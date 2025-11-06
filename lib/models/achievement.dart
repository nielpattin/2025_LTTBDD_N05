class Achievement {
  final String id;
  final String name;
  final String description;
  final int progress;
  final int target;
  final String icon;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.progress,
    required this.target,
    required this.icon,
  });

  bool get isCompleted => progress >= target;

  double get progressPercent =>
      target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    int? progress,
    int? target,
    String? icon,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'progress': progress,
      'target': target,
      'icon': icon,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      progress: json['progress'] as int,
      target: json['target'] as int,
      icon: json['icon'] as String,
    );
  }
}

final List<Achievement> defaultAchievements = [
  const Achievement(
    id: 'first_plantmon',
    name: 'Plantmon Đầu Tiên',
    description: 'Trồng Plantmon đầu tiên của bạn',
    progress: 0,
    target: 1,
    icon: 'eco',
  ),
  const Achievement(
    id: 'collector_i',
    name: 'Nhà Sưu Tập I',
    description: 'Sở hữu 5 Plantmon',
    progress: 0,
    target: 5,
    icon: 'inventory',
  ),
  const Achievement(
    id: 'collector_ii',
    name: 'Nhà Sưu Tập II',
    description: 'Sở hữu 10 Plantmon',
    progress: 0,
    target: 10,
    icon: 'inventory_2',
  ),
  const Achievement(
    id: 'battle_ready',
    name: 'Sẵn Sàng Chiến Đấu',
    description: 'Giành chiến thắng đầu tiên',
    progress: 0,
    target: 1,
    icon: 'sports_kabaddi',
  ),
  const Achievement(
    id: 'warrior',
    name: 'Chiến Binh',
    description: 'Thắng 10 trận đấu',
    progress: 0,
    target: 10,
    icon: 'military_tech',
  ),
  const Achievement(
    id: 'champion',
    name: 'Vô Địch',
    description: 'Thắng 50 trận đấu',
    progress: 0,
    target: 50,
    icon: 'emoji_events',
  ),
  const Achievement(
    id: 'level_5',
    name: 'Thăng Cấp!',
    description: 'Đạt cấp độ 5',
    progress: 0,
    target: 5,
    icon: 'trending_up',
  ),
  const Achievement(
    id: 'expert_trainer',
    name: 'Huấn Luyện Viên Chuyên Nghiệp',
    description: 'Đạt cấp độ 10',
    progress: 0,
    target: 10,
    icon: 'stars',
  ),
  const Achievement(
    id: 'master_trainer',
    name: 'Bậc Thầy Huấn Luyện',
    description: 'Đạt cấp độ 20',
    progress: 0,
    target: 20,
    icon: 'workspace_premium',
  ),
  const Achievement(
    id: 'star_collector',
    name: 'Nhà Sưu Tập Sao',
    description: 'Tích luỹ 100 sao',
    progress: 0,
    target: 100,
    icon: 'star',
  ),
  const Achievement(
    id: 'evolver',
    name: 'Tiến Hóa',
    description: 'Tiến hóa 1 Plantmon',
    progress: 0,
    target: 1,
    icon: 'auto_awesome',
  ),
  const Achievement(
    id: 'full_garden',
    name: 'Vườn Đầy',
    description: 'Lấp đầy tất cả các slot',
    progress: 0,
    target: 12,
    icon: 'park',
  ),
];
