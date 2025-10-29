import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/theme/app_theme.dart';
import 'package:not_so_tic_tac_toe_game/presentation/app/app_shell.dart';

class GameApp extends ConsumerWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Gridlock X & O Evolved',
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}