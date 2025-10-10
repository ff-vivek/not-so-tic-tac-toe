import 'package:flutter_test/flutter_test.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/exceptions/invalid_move_exception.dart';

void main() {
  group('TicTacToeGame', () {
    test('starts with empty board and X begins', () {
      final game = TicTacToeGame.newGame();

      expect(game.board.whereType<PlayerMark>().length, 0);
      expect(game.activePlayer, PlayerMark.x);
      expect(game.status, GameStatus.inProgress);
    });

    test('alternates turns between players', () {
      final game = TicTacToeGame.newGame();

      final afterFirstMove = game.playMove(BoardPosition(row: 0, col: 0));
      expect(afterFirstMove.activePlayer, PlayerMark.o);

      final afterSecondMove =
          afterFirstMove.playMove(BoardPosition(row: 1, col: 1));
      expect(afterSecondMove.activePlayer, PlayerMark.x);
    });

    test('prevents moves on occupied cells', () {
      final game = TicTacToeGame.newGame();
      final afterMove = game.playMove(BoardPosition(row: 0, col: 0));

      expect(
        () => afterMove.playMove(BoardPosition(row: 0, col: 0)),
        throwsA(isA<InvalidMoveException>()),
      );
    });

    test('detects row wins', () {
      final game = TicTacToeGame.newGame()
          .playMove(BoardPosition(row: 0, col: 0))
          .playMove(BoardPosition(row: 1, col: 0))
          .playMove(BoardPosition(row: 0, col: 1))
          .playMove(BoardPosition(row: 1, col: 1))
          .playMove(BoardPosition(row: 0, col: 2));

      expect(game.status, GameStatus.won);
      expect(game.winner, PlayerMark.x);
    });

    test('detects diagonal wins', () {
      final game = TicTacToeGame.newGame()
          .playMove(BoardPosition(row: 0, col: 0))
          .playMove(BoardPosition(row: 0, col: 1))
          .playMove(BoardPosition(row: 1, col: 1))
          .playMove(BoardPosition(row: 0, col: 2))
          .playMove(BoardPosition(row: 2, col: 2));

      expect(game.status, GameStatus.won);
      expect(game.winner, PlayerMark.x);
    });

    test('detects draw', () {
      final game = TicTacToeGame.newGame()
          .playMove(BoardPosition(row: 0, col: 0))
          .playMove(BoardPosition(row: 0, col: 1))
          .playMove(BoardPosition(row: 0, col: 2))
          .playMove(BoardPosition(row: 1, col: 1))
          .playMove(BoardPosition(row: 1, col: 0))
          .playMove(BoardPosition(row: 1, col: 2))
          .playMove(BoardPosition(row: 2, col: 1))
          .playMove(BoardPosition(row: 2, col: 0))
          .playMove(BoardPosition(row: 2, col: 2));

      expect(game.status, GameStatus.draw);
      expect(game.winner, isNull);
    });

    test('prevents moves once game is complete', () {
      final game = TicTacToeGame.newGame()
          .playMove(BoardPosition(row: 0, col: 0))
          .playMove(BoardPosition(row: 1, col: 0))
          .playMove(BoardPosition(row: 0, col: 1))
          .playMove(BoardPosition(row: 1, col: 1))
          .playMove(BoardPosition(row: 0, col: 2));

      expect(game.status, GameStatus.won);
      expect(
        () => game.playMove(BoardPosition(row: 2, col: 2)),
        throwsA(isA<InvalidMoveException>()),
      );
    });
  });
}