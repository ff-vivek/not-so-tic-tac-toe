import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/theme/app_theme.dart';
import 'package:not_so_tic_tac_toe_game/presentation/app/app_shell.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/settings/controllers/settings_controller.dart';

class GameApp extends ConsumerWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return MaterialApp(
      title: 'Gridlock X & O Evolved',
      theme: buildAppTheme(),
      darkTheme: buildDarkAppTheme(),
      themeMode: settings.themeMode,
      home: const AppShell(),
    );
  }
}