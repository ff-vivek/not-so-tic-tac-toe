import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/tic_tac_toe_board.dart'
    as i0;
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart'
    as i1;
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart' as i2;
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart'
    as i3;
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart' as i4;

@Preview(name: 'TicTacToeBoard - In Progress')
Widget previewTicTacToeBoardInProgress() {
  return i0.TicTacToeBoard(
    game: i1.TicTacToeGame.newGame(startingPlayer: i2.PlayerMark.x),
    onCellSelected: (position) {
      print('Cell selected: $position');
    },
    localPlayerMark: i2.PlayerMark.x,
  );
}

@Preview(name: 'TicTacToeBoard - Player X Wins')
Widget previewTicTacToeBoardPlayerXWins() {
  final game = i1.TicTacToeGame.newGame(startingPlayer: i2.PlayerMark.x)
      .playMove(const i3.BoardPosition(row: 0, col: 0)) // X
      .playMove(const i3.BoardPosition(row: 1, col: 0)) // O
      .playMove(const i3.BoardPosition(row: 0, col: 1)) // X
      .playMove(const i3.BoardPosition(row: 1, col: 1)) // O
      .playMove(const i3.BoardPosition(row: 0, col: 2)); // X wins
  return i0.TicTacToeBoard(
    game: game,
    onCellSelected: (position) {
      print('Cell selected: $position');
    },
    localPlayerMark: i2.PlayerMark.x,
  );
}

@Preview(name: 'TicTacToeBoard - Draw')
Widget previewTicTacToeBoardDraw() {
  final game = i1.TicTacToeGame.newGame(startingPlayer: i2.PlayerMark.x)
      .playMove(const i3.BoardPosition(row: 0, col: 0)) // X
      .playMove(const i3.BoardPosition(row: 0, col: 1)) // O
      .playMove(const i3.BoardPosition(row: 0, col: 2)) // X
      .playMove(const i3.BoardPosition(row: 1, col: 1)) // O
      .playMove(const i3.BoardPosition(row: 1, col: 0)) // X
      .playMove(const i3.BoardPosition(row: 2, col: 0)) // O
      .playMove(const i3.BoardPosition(row: 1, col: 2)) // X
      .playMove(const i3.BoardPosition(row: 2, col: 2)) // O
      .playMove(const i3.BoardPosition(row: 2, col: 1)); // X (draw)
  return i0.TicTacToeBoard(
    game: game,
    onCellSelected: (position) {
      print('Cell selected: $position');
    },
    localPlayerMark: i2.PlayerMark.x,
  );
}

@Preview(name: 'TicTacToeBoard - With Blocked Positions')
Widget previewTicTacToeBoardBlocked() {
  return i0.TicTacToeBoard(
    game: i1.TicTacToeGame.newGame(startingPlayer: i2.PlayerMark.x),
    onCellSelected: (position) {
      print('Cell selected: $position');
    },
    blockedPositions: {
      const i3.BoardPosition(row: 0, col: 0),
      const i3.BoardPosition(row: 1, col: 1),
      const i3.BoardPosition(row: 2, col: 2),
    },
    localPlayerMark: i2.PlayerMark.x,
  );
}

@Preview(name: 'TicTacToeBoard - With Spinner Active')
Widget previewTicTacToeBoardSpinnerActive() {
  return i0.TicTacToeBoard(
    game: i1.TicTacToeGame.newGame(startingPlayer: i2.PlayerMark.x),
    onCellSelected: (position) {
      print('Cell selected: $position');
    },
    spinnerOptions: [
      const i3.BoardPosition(row: 0, col: 0),
      const i3.BoardPosition(row: 0, col: 1),
      const i3.BoardPosition(row: 0, col: 2),
    ],
    isSpinnerActive: true,
    isSpinnerTurnForLocalPlayer: true,
    localPlayerMark: i2.PlayerMark.x,
  );
}

@Preview(name: 'TicTacToeBoard - With Gravity Drop Path')
Widget previewTicTacToeBoardGravityDrop() {
  final game = i1.TicTacToeGame.newGame(startingPlayer: i2.PlayerMark.x)
      .playMove(const i3.BoardPosition(row: 0, col: 0)); // X
  return i0.TicTacToeBoard(
    game: game,
    onCellSelected: (position) {
      print('Cell selected: $position');
    },
    gravityDropPath: [
      const i3.BoardPosition(row: 0, col: 0),
      const i3.BoardPosition(row: 1, col: 0),
    ],
    localPlayerMark: i2.PlayerMark.x,
  );
}
