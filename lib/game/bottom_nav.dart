import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'upgrades_screen.dart';
import 'missions_screen.dart';
import 'ranks_screen.dart';

class BottomNavBar extends StatelessWidget {
  final String currentPage;
  
  const BottomNavBar({super.key, required this.currentPage});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          _buildNavItem(context, 'home', Icons.home, 'Home', currentPage == 'home'),
          _buildNavItem(context, 'upgrades', Icons.trending_up, 'Upgrades', currentPage == 'upgrades'),
          _buildNavItem(context, 'missions', Icons.map, 'Missions', currentPage == 'missions'),
          _buildNavItem(context, 'ranks', Icons.leaderboard, 'Ranks', currentPage == 'ranks'),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(BuildContext context, String page, IconData icon, String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateToPage(context, page),
        child: Container(
          color: Colors.transparent, // Make entire area tappable
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? Colors.green : Colors.white.withOpacity(0.6), size: 24),
              SizedBox(height: 4),
              Text(label, style: TextStyle(color: isActive ? Colors.green : Colors.white.withOpacity(0.6), fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToPage(BuildContext context, String page) {
    Widget targetPage;
    switch (page) {
      case 'home':
        targetPage = HomeScreen();
        break;
      case 'upgrades':
        targetPage = UpgradesMenuScreen();
        break;
      case 'missions':
        targetPage = MissionsMenuScreen();
        break;
      case 'ranks':
        targetPage = RanksMenuScreen();
        break;
      default:
        return;
    }
    
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }
}