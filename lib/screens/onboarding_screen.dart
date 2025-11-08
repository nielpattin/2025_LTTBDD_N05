import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
import '../game/garden_state.dart';
import '../data/ball_tiers.dart';
import '../data/plants_data.dart';
import '../models/plantmon.dart';
import '../models/shop_item.dart';
import '../models/seed.dart';
import 'main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  late PageController _pageController;
  List<Plantmon>? _starterChoices;
  Plantmon? _selectedStarter;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _generateStarterChoices();
  }

  void _generateStarterChoices() {
    final commonPool = List<String>.from(getPlantmonPoolByTier(BallTier.common));
    commonPool.shuffle();
    final selectedNames = commonPool.take(3).toList();
    
    _starterChoices = selectedNames.map((name) {
      final spritePath = 'assets/images/plants/$name.png';
      return generateRandomPlantmon(
        sprite: spritePath,
        rarity: Rarity.common,
        level: 1,
      );
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToGame() async {
    if (_selectedStarter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a starter Plantmon!')),
      );
      return;
    }

    final profile = context.read<PlayerProfile>();
    final gardenState = context.read<GardenState>();
    
    await profile.completeOnboarding();
    
    await gardenState.plantInSlot(0, _selectedStarter!);
    await profile.updatePlantmonCount(gardenState.getTotalPlantmons());
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2d5016), Color(0xFF1a2e0f)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildGameplayPage(),
                    _buildGardenPage(),
                    _buildProgressPage(),
                    _buildStarterSelectionPage(),
                  ],
                ),
              ),
              _buildBottomNavigation(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.eco, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            'Welcome to Plantmon!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Collect, nurture, and battle with plant-based creatures',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Column(
              children: [
                Text(
                  '🎁 Free Starter Plantmon!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Choose your first companion to begin your journey',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earn Stars from Tower Battles',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Use stars to unlock powerful Plantmon',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameplayPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.sports_martial_arts, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Battle & Progress',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildGameplayCard(
            icon: Icons.castle,
            title: 'Challenge Tower',
            description:
                'Conquer floors with your Plantmon team to earn stars and EXP',
          ),
          _buildGameplayCard(
            icon: Icons.trending_up,
            title: 'Level Up & Evolve',
            description:
                'Train your Plantmon to increase their level and unlock evolutions',
          ),
          _buildGameplayCard(
            icon: Icons.star,
            title: 'Earn Star Currency',
            description:
                'Collect stars from victories to unlock rare Plantmon',
          ),
        ],
      ),
    );
  }

  Widget _buildGardenPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.park, size: 80, color: Colors.lightGreen),
          const SizedBox(height: 24),
          const Text(
            'Garden Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildGameplayCard(
            icon: Icons.water_drop,
            title: 'Daily Care',
            description: 'Water and fertilize your Plantmon to boost their EXP',
          ),
          _buildGameplayCard(
            icon: Icons.energy_savings_leaf,
            title: 'Care Resources',
            description: 'Manage water and fertilizer charges that regenerate daily',
          ),
          _buildGameplayCard(
            icon: Icons.grass,
            title: 'Free Roam Garden',
            description: 'Watch your Plantmon walk around and interact in the garden',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.flag, size: 80, color: Colors.purple),
          const SizedBox(height: 24),
          const Text(
            'Progress & Goals',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildProgressCard(
            '📈 Level System',
            'Increase your player level to unlock new features and slots',
          ),
          _buildProgressCard(
            '🏆 Achievements',
            'Complete achievements to track progress and earn rewards',
          ),
          _buildProgressCard(
            '⭐ Star Shop',
            'Common (10⭐) → Rare (50⭐) → Legendary (100⭐) Plantmon',
          ),
          _buildProgressCard(
            '🏰 Tower Progression',
            'Floor 1-10: 3⭐ • Floor 11-20: 5⭐ • Floor 21+: 10⭐',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: const Text(
              '💡 Tip: Defeat Tower floors to earn stars, then unlock better balls as you progress!',
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameplayCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Choose Your Starter!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Choose 1 of 3 Plantmon to begin your journey',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_starterChoices != null)
            ...List.generate(_starterChoices!.length, (index) {
              final plantmon = _starterChoices![index];
              final isSelected = _selectedStarter == plantmon;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStarter = plantmon;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF66BB6A).withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF66BB6A)
                          : Colors.white24,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF66BB6A),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildPlantmonImage(plantmon),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plantmon.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF66BB6A),
                                    size: 24,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildStatRow('HP', plantmon.hp, 100),
                            _buildStatRow('ATK', plantmon.attack, 150),
                            _buildStatRow('DEF', plantmon.defense, 150),
                            _buildStatRow('SPD', plantmon.speed, 150),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPlantmonImage(Plantmon plantmon) {
    final typeCapitalized = plantmon.type.replaceFirst(
      plantmon.type[0],
      plantmon.type[0].toUpperCase(),
    );
    final spritePath = 'assets/images/plants/$typeCapitalized.png';

    return Image.asset(
      spritePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.eco,
            color: Colors.white,
            size: 32,
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, int value, int maxValue) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: const Color(0xFF3a3a3a),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF66BB6A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 25,
            child: Text(
              '$value',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Column(
      children: [
        // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.green : Colors.white30,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                    ),
                    child: const Text('Back'),
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentPage == 4
                      ? _navigateToGame
                      : () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    _currentPage == 4 ? 'Start Game!' : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
