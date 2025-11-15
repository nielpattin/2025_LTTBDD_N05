import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
import 'garden_screen.dart';
import 'shop_screen.dart';
import 'tower_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    GardenScreen(),
    ShopScreen(),
    TowerScreen(),
    AchievementsScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = const [
    'Garden',
    'Shop',
    'Challenge Tower',
    'Achievements',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        automaticallyImplyLeading: false,
        actions: [
          if (_currentIndex == 0 || _currentIndex == 1)
            Consumer<PlayerProfile>(
              builder: (context, profile, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 26,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.stars}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentIndex == 2)
            Consumer<PlayerProfile>(
              builder: (context, profile, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Floor ${profile.towerFloor}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.stars}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentIndex == 3)
            Consumer<PlayerProfile>(
              builder: (context, profile, _) {
                final completedCount = profile.achievements
                    .where((a) => a.isCompleted)
                    .length;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '$completedCount / ${profile.achievements.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                );
              },
            ),
          if (_currentIndex == 4)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Garden',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, size: 28),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.castle, size: 28),
            label: 'Tower',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events, size: 28),
            label: 'Awards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
