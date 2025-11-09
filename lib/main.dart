import 'package:flutter/material.dart';
import 'providers/provider_setup.dart';
import 'widgets/restart_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    RestartWidget(
      child: ProviderSetup.createApp(),
    ),
  );
}
