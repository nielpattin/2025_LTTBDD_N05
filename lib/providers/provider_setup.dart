import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';
import '../game/player_profile.dart';
import '../providers/rewards_state.dart';
import '../theme/app_theme.dart';
 
class ProviderSetup {
  static final PlayerProfile _playerProfileInstance = PlayerProfile();
  static final RewardsState _rewardsStateInstance = RewardsState();


  static PlayerProfile get playerProfile => _playerProfileInstance;

  static Future<void> initialize() async {
    await _playerProfileInstance.load();
    await _rewardsStateInstance.load();
  }
 
  static Widget createApp({required Widget home}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerProfile>.value(
          value: _playerProfileInstance,
        ),
        ChangeNotifierProvider<RewardsState>.value(
          value: _rewardsStateInstance,
        ),
        ChangeNotifierProvider(create: (_) => GameState()),
      ],

      child: MaterialApp(
        title: 'Plantmon',
        theme: AppTheme.darkTheme,
        home: home,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
