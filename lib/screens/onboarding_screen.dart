import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
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
  // Max values for stat bars
  static const Map<String, int> _statMaxByName = {
    'health': 80,
    'attack': 20,
    'defense': 20,
  };
  int _currentPage = 0;
  final PageController _pageController = PageController();
  List<Plantmon>? _starterChoices;
  Plantmon? _selectedStarter;

  @override
  void initState() {
    super.initState();
    _generateStarterChoices();
  }

  void _generateStarterChoices() {
    final commonPool = List<String>.from(
      getPlantmonPoolByTier(BallTier.common),
    );
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

  // Clean up the page controller, free memory
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToGame() async {
    if (_selectedStarter == null) {
      return;
    }

    final profile = context.read<PlayerProfile>();

    await profile.completeOnboarding();

    await profile.plantInSlot(0, _selectedStarter!);

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
        color: const Color(0xFF0f2410),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                // PageView for onboarding steps
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [_buildWelcomePage(), _buildStarterSelectionPage()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'PLANTMON',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7cb87e),
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'GROW - BATTLE - DOMINATE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _buildFeatureCard(
                    icon: Icons.eco,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'GROW YOUR ARMY',
                    description: 'Nurture plants, level them up',
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    icon: Icons.sports_martial_arts,
                    iconColor: const Color(0xFFFF5252),
                    title: 'STRATEGIC COMBAT',
                    description: 'Turn based battles, smart tactics',
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    icon: Icons.castle,
                    iconColor: const Color(0xFF9C27B0),
                    title: 'CONQUER THE TOWER',
                    description: '30+ floors, earn rare Plantmon',
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPageIndicators(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2e0f),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterSelectionPage() {
    if (_starterChoices == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Choose Your Starter',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Pick one Plantmon to begin your journey',
            style: TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...List.generate(_starterChoices!.length, (index) {
            final plantmon = _starterChoices![index];
            final isSelected = _selectedStarter == plantmon;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedStarter = plantmon);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF213c22)
                      : const Color(0xFF1a2e0f),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF66BB6A)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildPlantmonImage(plantmon),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plantmon.type.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Level ${plantmon.level} • COMMON',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStatBar(
                            label: 'HEALTH',
                            current: plantmon.hp,
                            maxValue: _statMaxByName['health']!,
                          ),
                          _buildStatBar(
                            label: 'ATTACK',
                            current: plantmon.attack,
                            maxValue: _statMaxByName['attack']!,
                          ),
                          _buildStatBar(
                            label: 'DEFENSE',
                            current: plantmon.defense,
                            maxValue: _statMaxByName['defense']!,
                          ),
                          _buildStatBar(
                            label: 'ATTACK',
                            current: plantmon.attack,
                            maxValue: _statMaxByName['attack']!,
                          ),
                          _buildStatBar(
                            label: 'DEFENSE',
                            current: plantmon.defense,
                            maxValue: _statMaxByName['defense']!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedStarter != null ? _navigateToGame : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66BB6A),
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Adventure',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (_selectedStarter == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Select a starter to continue',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
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
        return const Center(
          child: Icon(Icons.eco, color: Colors.white, size: 32),
        );
      },
    );
  }

  Widget _buildStatBar({
    required String label,
    required int current,
    required int maxValue,
  }) {
    final double progress = maxValue <= 0
        ? 0.0
        : (current / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
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
            width: 40,
            child: Text(
              '$current',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: _currentPage == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF66BB6A)
                : Colors.grey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
