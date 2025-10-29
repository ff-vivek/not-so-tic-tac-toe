import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/auth/auth_manager.dart';
import 'package:not_so_tic_tac_toe_game/data/matchmaking/firebase_match_repository.dart';
import 'package:not_so_tic_tac_toe_game/data/matchmaking/firebase_matchmaking_repository.dart';
import 'package:not_so_tic_tac_toe_game/data/modifiers/stub_modifiers.dart';
import 'package:not_so_tic_tac_toe_game/data/player/firebase_player_profile_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_registry.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/match_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/matchmaking_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/player_profile_repository.dart';

final modifierRegistryProvider = Provider<ModifierRegistry>((ref) {
  final registry = ModifierRegistry();
  registry
    ..register(() => NoOpModifier())
    ..register(() => ReservedModifier(modifierId: 'blocked_squares'))
    ..register(() => ReservedModifier(modifierId: 'spinner'))
    ..register(() => ReservedModifier(modifierId: 'gravity_well'))
    ..register(() => ReservedModifier(modifierId: 'ultimate'));
  return registry;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authManagerProvider = Provider<AuthManager>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthManager(firebaseAuth);
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final playerIdProvider = Provider<String>((ref) {
  final authManager = ref.watch(authManagerProvider);
  final userId = authManager.currentUserId;
  if (userId == null) {
    throw StateError('Player is not authenticated');
  }
  return userId;
});

final matchmakingRepositoryProvider = Provider<MatchmakingRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseMatchmakingRepository(firestore);
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseMatchRepository(firestore);
});

final playerProfileRepositoryProvider = Provider<PlayerProfileRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebasePlayerProfileRepository(firestore);
});