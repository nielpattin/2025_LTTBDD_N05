class BattleResult {
  final bool isVictory;
  final bool isWin;
  final int expGained;
  final int starsEarned;
  final String message;

  const BattleResult({
    required this.isVictory,
    required this.isWin,
    required this.expGained,
    required this.starsEarned,
    required this.message,
  });

  factory BattleResult.victory({
    required int playerLevel,
    required int floorNumber,
  }) {
    final baseExp = 100 + (playerLevel * 20);
    
    int stars = 3;
    if (floorNumber >= 51) {
      stars = 15;
    } else if (floorNumber >= 21) {
      stars = 10;
    } else if (floorNumber >= 11) {
      stars = 5;
    }
    
    if (floorNumber % 10 == 0) {
      stars += 5;
    }

    return BattleResult(
      isVictory: true,
      isWin: true,
      expGained: baseExp,
      starsEarned: stars,
      message: 'Victory!',
    );
  }

  factory BattleResult.defeat() {
    return const BattleResult(
      isVictory: false,
      isWin: false,
      expGained: 10,
      starsEarned: 0,
      message: 'Defeated...',
    );
  }
}
