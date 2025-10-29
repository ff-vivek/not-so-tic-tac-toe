import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_profile.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/player_profile_repository.dart';

final _playerProfileInitializationProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(playerProfileRepositoryProvider);
  final playerId = ref.watch(playerIdProvider);
  await repository.ensureProfileInitialized(playerId: playerId);
});

final playerProfileProvider = StreamProvider<PlayerProfile>((ref) {
  // Ensure the profile document exists before subscribing to changes.
  ref.watch(_playerProfileInitializationProvider);
  final repository = ref.watch(playerProfileRepositoryProvider);
  final playerId = ref.watch(playerIdProvider);
  return repository.watchProfile(playerId: playerId);
});