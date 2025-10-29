import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/auth/auth_manager.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';
import 'package:not_so_tic_tac_toe_game/firebase_options.dart';

import './presentation/app/game_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure session persistence is robust on web.
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  final authManager = FirebaseAuthManager(FirebaseAuth.instance);
  await authManager.ensureAuthenticated();

  runApp(
    ProviderScope(
      overrides: [
        authManagerProvider.overrideWithValue(authManager),
      ],
      child: const GameApp(),
    ),
  );
}
