import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/data/matchmaking/firebase_match_repository.dart';
import 'package:not_so_tic_tac_toe_game/data/matchmaking/firebase_matchmaking_repository.dart';
import 'package:not_so_tic_tac_toe_game/data/modifiers/stub_modifiers.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_registry.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/match_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/matchmaking_repository.dart';

final modifierRegistryProvider = Provider<ModifierRegistry>((ref) {
  final registry = ModifierRegistry();
  registry
    ..register(() => NoOpModifier())
    ..register(() => ReservedModifier(modifierId: 'blocked_squares'))
    ..register(() => ReservedModifier(modifierId: 'spinner'));
  return registry;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final playerIdProvider = Provider<String>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;
  if (user == null) {
    throw StateError('Player is not authenticated');
  }
  return user.uid;
});

final matchmakingRepositoryProvider = Provider<MatchmakingRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseMatchmakingRepository(firestore);
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseMatchRepository(firestore);
});