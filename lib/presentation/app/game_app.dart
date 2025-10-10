import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/theme/app_theme.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/pages/game_home_page.dart';

class GameApp extends ConsumerWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Gridlock X & O Evolved',
      theme: buildAppTheme(),
      home: const GameHomePage(),
    );
  }
}