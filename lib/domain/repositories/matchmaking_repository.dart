import 'package:not_so_tic_tac_toe_game/domain/value_objects/match_join_result.dart';

abstract class MatchmakingRepository {
  Future<MatchJoinResult> joinQueue(String playerId);

  Future<void> leaveQueue(String playerId);
}