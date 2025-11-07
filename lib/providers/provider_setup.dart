import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';
import '../game/player_profile.dart';
import '../game/garden_state.dart';
import '../providers/rewards_state.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';

class ProviderSetup {
  static late final PlayerProfile _playerProfileInstance;
  static late final GardenState _gardenStateInstance;
  static late final RewardsState _rewardsStateInstance;
  static Future<void>? _initFuture;

  static Widget createApp() {
    // Always create a fresh future when called
    _initFuture = _initialize();

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2d5016), Color(0xFF1a2e0f)],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Init error: ${snapshot.error}')),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<PlayerProfile>.value(
              value: _playerProfileInstance,
            ),
            ChangeNotifierProvider<GardenState>.value(
              value: _gardenStateInstance,
            ),
            ChangeNotifierProvider<RewardsState>.value(
              value: _rewardsStateInstance,
            ),
            ChangeNotifierProvider(create: (_) => GameState()),
          ],
          child: MaterialApp(
            title: 'Plantmon',
            theme: AppTheme.darkTheme,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }

  static Future<void> _initialize() async {
    try {
      _playerProfileInstance = PlayerProfile();
      await _playerProfileInstance.load();

      _gardenStateInstance = GardenState();
      await _gardenStateInstance.load();

      _rewardsStateInstance = RewardsState();
      await _rewardsStateInstance.load();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset instances by reloading them from empty storage
  /// DON'T dispose - that causes "used after disposed" crashes
  /// The instances remain alive so existing listeners don't crash
  static Future<void> resetInstances() async {
    // Just reload the instances from storage (which is now cleared)
    // This keeps them alive so Consumer widgets don't crash
    await _playerProfileInstance.load();
    await _gardenStateInstance.load();
    await _rewardsStateInstance.load();
  }
}
