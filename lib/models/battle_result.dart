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
}
