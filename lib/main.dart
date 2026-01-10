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

  AuthManager authManager;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }

    authManager = FirebaseAuthManager(FirebaseAuth.instance);
    await authManager.ensureAuthenticated();
  } catch (e, st) {
    debugPrint('Firebase not initialized. Running in offline mode. Error: $e');
    debugPrint('$st');
    // Guidance for Dreamflow users about enabling backend via panel.
    debugPrint('Hint: To use Firebase features, open the Firebase panel in Dreamflow and complete setup.');
    authManager = LocalAuthManager();
    await authManager.ensureAuthenticated();
  }

  runApp(
    ProviderScope(
      overrides: [
        authManagerProvider.overrideWithValue(authManager),
      ],
      child: const GameApp(),
    ),
  );
}
