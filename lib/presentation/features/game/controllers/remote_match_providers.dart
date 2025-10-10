import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/match_state.dart';

final activeMatchProvider = StreamProvider<MatchState?>((ref) {
  final repository = ref.watch(matchRepositoryProvider);
  final playerId = ref.watch(playerIdProvider);
  return repository.watchActiveMatch(playerId: playerId);
});