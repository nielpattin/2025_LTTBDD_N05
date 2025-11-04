import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game/home_screen.dart';
import 'game/game_state.dart';
import 'game/player_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final playerProfile = PlayerProfile();
  await playerProfile.load();

  runApp(MyApp(playerProfile: playerProfile));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.playerProfile});

  final PlayerProfile playerProfile;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: playerProfile),
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: MaterialApp(
        title: 'Plantmon',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
