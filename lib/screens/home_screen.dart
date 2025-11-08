import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/player_profile.dart';
import 'main_navigation.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showWelcomeDialog() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  void _navigateToGarden() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
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
          child: Center(
            child: Consumer<PlayerProfile>(
              builder: (context, profile, child) {
                // Avoid navigating while another route (like Battle) is active
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    return; // don't hijack if deeper route is visible
                  }

                  if (profile.isFirstTime) {
                    _showWelcomeDialog();
                  } else {
                    _navigateToGarden();
                  }
                });

                return const CircularProgressIndicator(color: Colors.white);
              },
            ),
          ),
        ),
      ),
    );
  }
}
