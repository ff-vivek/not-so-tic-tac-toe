import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/auth/auth_manager.dart';
import 'package:not_so_tic_tac_toe_game/core/analytics/analytics_service.dart';
import 'package:not_so_tic_tac_toe_game/data/matchmaking/firebase_match_repository.dart';
import 'package:not_so_tic_tac_toe_game/data/matchmaking/firebase_matchmaking_repository.dart';
import 'package:not_so_tic_tac_toe_game/data/modifiers/stub_modifiers.dart';
import 'package:not_so_tic_tac_toe_game/data/player/firebase_player_profile_repository.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/player/controllers/player_account_service.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_registry.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/match_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/matchmaking_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/player_profile_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/tournament_repository.dart';
import 'package:not_so_tic_tac_toe_game/data/tournaments/firebase_tournament_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/clan_repository.dart';
import 'package:not_so_tic_tac_toe_game/data/clans/firebase_clan_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/team_matchmaking_repository.dart';
import 'package:not_so_tic_tac_toe_game/data/matchmaking/firebase_team_matchmaking_repository.dart';

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

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final analytics = ref.watch(firebaseAnalyticsProvider);
  return AnalyticsService(analytics);
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

final playerAccountServiceProvider = Provider<PlayerAccountService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return PlayerAccountService(auth, firestore);
});

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseTournamentRepository(firestore);
});

final clanRepositoryProvider = Provider<ClanRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseClanRepository(firestore);
});

final teamMatchmakingRepositoryProvider = Provider<TeamMatchmakingRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseTeamMatchmakingRepository(firestore);
});