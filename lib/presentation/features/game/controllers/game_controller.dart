import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/exceptions/invalid_move_exception.dart';

class GameController extends Notifier<TicTacToeGame> {
  @override
  TicTacToeGame build() => TicTacToeGame.newGame();

  void playAt(BoardPosition position) {
    try {
      state = state.playMove(position);
    } on InvalidMoveException {
      // Ignore invalid interactions; UI can decide to surface feedback later.
    }
  }

  void reset() {
    state = TicTacToeGame.newGame(
      startingPlayer: state.startingPlayer.opponent,
    );
  }
}

final gameControllerProvider = NotifierProvider<GameController, TicTacToeGame>(
  GameController.new,
);