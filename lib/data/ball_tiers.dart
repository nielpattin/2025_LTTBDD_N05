import '../models/shop_item.dart';

const Map<BallTier, List<String>> ballTierPools = {
  BallTier.common: [
    'Bellsprout',
    'Budew',
    'Sunkern',
    'Cherubi',
    'Bounsweet',
    'Cottonee',
    'Cacnea',
    'Petilil',
    'Bonsly',
    'Skiploom',
  ],
  BallTier.rare: [
    'Roselia',
    'Weepinbell',
    'Sunflora',
    'Fomantis',
    'Flabebe',
    'Maractus',
    'Smoliv',
    'Dolliv',
    'Swadloon',
    'Carnivine',
  ],
  BallTier.legendary: [
    'Victreebel',
    'Lilligant',
    'Bellossom',
    'Arboliva',
    'Scovillain',
    'Cradily',
  ],
};

List<String> getPlantmonPoolByTier(BallTier tier) {
  return ballTierPools[tier] ?? [];
}
