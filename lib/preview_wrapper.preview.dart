import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/auth/auth_manager.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';
import 'package:not_so_tic_tac_toe_game/firebase_options.dart';

import './presentation/app/game_app.dart';

Widget wrapPreview(Widget Function() buildPreviewWidget) {
  // This wrapper replicates the provider setup from main.dart.
  // It assumes that Firebase has been initialized by the preview environment.
  final authManager = FirebaseAuthManager(FirebaseAuth.instance);

  return ProviderScope(
    overrides: [
      authManagerProvider.overrideWithValue(authManager),
    ],
    // The original MaterialApp.router from GameApp is replaced with a
    // simpler MaterialApp to resolve errors from missing router and theme
    // dependencies. This focuses on providing the necessary app structure
    // for the preview.
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: buildPreviewWidget(),
    ),
  );
}
