import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';

enum MatchParticipantState { active, done }

class MatchState {
  MatchState({
    required this.id,
    required this.playerXId,
    required this.playerOId,
    required this.game,
    required this.status,
    required this.playerStates,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String playerXId;
  final String playerOId;
  final TicTacToeGame game;
  final GameStatus status;
  final Map<String, MatchParticipantState> playerStates;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlayerMark? markForPlayer(String playerId) {
    if (playerId == playerXId) return PlayerMark.x;
    if (playerId == playerOId) return PlayerMark.o;
    return null;
  }

  bool isPlayerTurn(String playerId) {
    final playerMark = markForPlayer(playerId);
    return playerMark != null &&
        status == GameStatus.inProgress &&
        game.activePlayer == playerMark;
  }

  String? winnerPlayerId() {
    final winnerMark = game.winner;
    if (winnerMark == null) return null;
    return winnerMark == PlayerMark.x ? playerXId : playerOId;
  }

  MatchParticipantState stateForPlayer(String playerId) {
    return playerStates[playerId] ?? MatchParticipantState.done;
  }
}