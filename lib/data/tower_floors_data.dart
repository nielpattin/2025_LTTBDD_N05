/// Enemy sprite pool for random tower generation
const enemySpritePool = [
  'assets/images/enemy/Weedle.png',
  'assets/images/enemy/Caterpie.png',
  'assets/images/enemy/Beedrill.png',
  'assets/images/enemy/Combee.png',
  'assets/images/enemy/Starly.png',
  'assets/images/enemy/Ledyba.png',
  'assets/images/enemy/Yanma.png',
  'assets/images/enemy/Ledian.png',
  'assets/images/enemy/Scyther.png',
  'assets/images/enemy/Mothim.png',
  'assets/images/enemy/Kabuto.png',
  'assets/images/enemy/Omanyte.png',
  'assets/images/enemy/Kabutops.png',
];

/// Get enemy name from sprite path
String getEnemyNameFromSprite(String spritePath) {
  final filename = spritePath.split('/').last;
  return filename.replaceAll('.png', '');
}
