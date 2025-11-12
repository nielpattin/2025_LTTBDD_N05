import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';
import '../game/player_profile.dart';
import '../game/garden_state.dart';
import '../providers/rewards_state.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';

class ProviderSetup {
  static final PlayerProfile _playerProfileInstance = PlayerProfile();
  static final GardenState _gardenStateInstance = GardenState();
  static final RewardsState _rewardsStateInstance = RewardsState();

  static Future<void> initialize() async {
    await _playerProfileInstance.load();
    await _gardenStateInstance.load();
    await _rewardsStateInstance.load();
  }

  static Widget createApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerProfile>.value(
          value: _playerProfileInstance,
        ),
        ChangeNotifierProvider<GardenState>.value(value: _gardenStateInstance),
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
  }
}
