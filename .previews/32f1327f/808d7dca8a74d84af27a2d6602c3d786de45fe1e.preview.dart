import 'package:flutter/widgets.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/tic_tac_toe_board.dart';
import 'package:flutter/foundation.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';

@Preview(name: 'Default')
Widget previewTicTacToeBoard_808d7dca8a74d84af27a2d6602c3d786de45fe1e() {
  return TicTacToeBoard(
    key: /* TODO: provide optional Key value for key: */ Key(
      /* TODO: provide String value for value: */ '',
    ),
    game: /* TODO: provide TicTacToeGame value for game: */ TicTacToeGame.newGame(
      startingPlayer: /* TODO: provide PlayerMark value for startingPlayer: */ PlayerMark.x,
    ),
    onCellSelected: /* TODO: provide function value for onCellSelected: */ (
      BoardPosition position,
    ) {
      // TODO: implement callback
    },
    canSelectCell: /* TODO: provide optional function value for canSelectCell: */ (
      BoardPosition position,
    ) {
      return /* TODO: provide bool for return type */ false;
    },
    localPlayerMark: /* TODO: provide optional PlayerMark value for localPlayerMark: */ PlayerMark.x,
    blockedPositions: /* TODO: provide Set value for blockedPositions: */ <BoardPosition>{},
    spinnerOptions: /* TODO: provide List value for spinnerOptions: */ <BoardPosition>[],
    isSpinnerActive: /* TODO: provide bool value for isSpinnerActive: */ false,
    isSpinnerTurnForLocalPlayer: /* TODO: provide bool value for isSpinnerTurnForLocalPlayer: */ false,
    gravityDropPath: /* TODO: provide List value for gravityDropPath: */ <BoardPosition>[],
  );
}
