import 'package:flutter/material.dart';
import 'providers/provider_setup.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ProviderSetup.initialize();

  final isFirstTime = ProviderSetup.playerProfile.isFirstTime;
  final home = isFirstTime ? const OnboardingScreen() : const MainNavigation();

  runApp(ProviderSetup.createApp(home: home));
}
