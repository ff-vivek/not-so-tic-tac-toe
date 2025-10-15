import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/ultimate_board_state.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_category.dart';

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
    this.modifierCategory,
    this.modifierId,
    Set<BoardPosition> blockedPositions = const {},
    List<BoardPosition> spinnerOptions = const [],
    List<BoardPosition> gravityDropPath = const [],
    this.ultimateState,
  })  : blockedPositions = Set<BoardPosition>.unmodifiable(blockedPositions),
        spinnerOptions = List<BoardPosition>.unmodifiable(spinnerOptions),
        gravityDropPath = List<BoardPosition>.unmodifiable(gravityDropPath);

  final String id;
  final String playerXId;
  final String playerOId;
  final TicTacToeGame game;
  final GameStatus status;
  final Map<String, MatchParticipantState> playerStates;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ModifierCategory? modifierCategory;
  final String? modifierId;
  final Set<BoardPosition> blockedPositions;
  final List<BoardPosition> spinnerOptions;
  final List<BoardPosition> gravityDropPath;
  final UltimateBoardState? ultimateState;

  PlayerMark? markForPlayer(String playerId) {
    if (playerId == playerXId) return PlayerMark.x;
    if (playerId == playerOId) return PlayerMark.o;
    return null;
  }

  bool get hasBlockedSquares => blockedPositions.isNotEmpty;

  bool get hasSpinnerRestriction =>
      modifierId == 'spinner' && spinnerOptions.isNotEmpty;

  bool get isGravityWellMatch => modifierId == 'gravity_well';

  bool get isUltimateModeMatch => modifierId == 'ultimate';

  bool isSquareBlocked(BoardPosition position) => blockedPositions.contains(position);

  bool isSpinnerOption(BoardPosition position) =>
      spinnerOptions.contains(position);

  bool isPlayerTurn(String playerId) {
    final playerMark = markForPlayer(playerId);
    return playerMark != null &&
        status == GameStatus.inProgress &&
        game.activePlayer == playerMark;
  }

  bool canPlayerSelectCell(String playerId, BoardPosition position) {
    if (!isPlayerTurn(playerId)) return false;
    if (!game.canPlayAt(position)) return false;
    if (isSquareBlocked(position)) return false;
    if (hasSpinnerRestriction && !isSpinnerOption(position)) return false;
    return true;
  }

  bool canPlayerSelectUltimateCell(String playerId, BoardPosition position) {
    if (!isUltimateModeMatch) return false;
    if (!isPlayerTurn(playerId)) return false;
    if (position.dimension != 9) return false;
    final data = ultimateState;
    if (data == null) return false;
    final breakdown = data.resolveAbsolute(position);
    if (data.activeBoardIndex != null &&
        data.activeBoardIndex != breakdown.miniIndex) {
      return false;
    }
    final miniBoard = data.boardAt(breakdown.miniIndex);
    if (!miniBoard.isPlayable) return false;
    return miniBoard.cells[breakdown.cellIndex] == null;
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