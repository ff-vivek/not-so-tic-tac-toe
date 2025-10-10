import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/match_state.dart';

abstract class MatchRepository {
  Stream<MatchState?> watchActiveMatch({required String playerId});

  Future<void> submitMove({
    required String matchId,
    required String playerId,
    required BoardPosition position,
  });

  Future<void> leaveMatch({
    required String matchId,
    required String playerId,
  });
}