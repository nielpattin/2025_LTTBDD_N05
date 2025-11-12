import 'package:flutter/material.dart';
import 'providers/provider_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ProviderSetup.initialize();
  runApp(ProviderSetup.createApp());
}
