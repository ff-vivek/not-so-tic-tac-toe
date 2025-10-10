import 'package:flutter_test/flutter_test.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/match_state.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';

void main() {
  group('MatchState', () {
    const playerX = 'player_x';
    const playerO = 'player_o';

    TicTacToeGame buildGame({
      required PlayerMark active,
      GameStatus status = GameStatus.inProgress,
      PlayerMark? winner,
      BoardPosition? lastMove,
    }) {
      return TicTacToeGame.fromState(
        board: List<PlayerMark?>.filled(9, null),
        activePlayer: active,
        status: status,
        winner: winner,
        lastMove: lastMove,
        startingPlayer: PlayerMark.x,
      );
    }

    MatchState buildState(TicTacToeGame game) {
      return MatchState(
        id: 'match-1',
        playerXId: playerX,
        playerOId: playerO,
        game: game,
        status: game.status,
        playerStates: const {
          playerX: MatchParticipantState.active,
          playerO: MatchParticipantState.active,
        },
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );
    }

    test('returns correct mark for each player', () {
      final state = buildState(buildGame(active: PlayerMark.x));

      expect(state.markForPlayer(playerX), PlayerMark.x);
      expect(state.markForPlayer(playerO), PlayerMark.o);
      expect(state.markForPlayer('unknown'), isNull);
    });

    test('identifies active player turn', () {
      final state = buildState(buildGame(active: PlayerMark.x));
      expect(state.isPlayerTurn(playerX), isTrue);
      expect(state.isPlayerTurn(playerO), isFalse);

      final nextState = buildState(buildGame(active: PlayerMark.o));
      expect(nextState.isPlayerTurn(playerX), isFalse);
      expect(nextState.isPlayerTurn(playerO), isTrue);
    });

    test('returns winning player id when match has winner', () {
      final winningGame = buildGame(
        active: PlayerMark.x,
        status: GameStatus.won,
        winner: PlayerMark.o,
        lastMove: BoardPosition(row: 0, col: 0),
      );

      final state = buildState(winningGame);

      expect(state.winnerPlayerId(), equals(playerO));
    });
  });
}