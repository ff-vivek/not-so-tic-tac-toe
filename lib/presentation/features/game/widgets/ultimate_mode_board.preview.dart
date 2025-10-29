import 'package:flutter/widgets.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/ultimate_mode_board.dart' as i0;
import 'package:flutter/foundation.dart' as i1;
import 'package:not_so_tic_tac_toe_game/domain/entities/ultimate_board_state.dart' as i2;
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart' as i3;
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart' as i4;
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart' as i5;


@Preview(name: 'UltimateModeBoard')
Widget previewUltimateModeBoard() {
  return i0.UltimateModeBoard(
    key: /* TODO: provide optional Key value for key: */ i1.Key(
      /* TODO: provide String value for value: */ '',
    ),
    state: /* TODO: provide UltimateBoardState value for state: */ i2.UltimateBoardState(
      miniBoards: /* TODO: provide List value for miniBoards: */ <i2.UltimateMiniBoard>[],
      activeBoardIndex: /* TODO: provide optional int value for activeBoardIndex: */ 0,
      lastMove: /* TODO: provide optional BoardPosition value for lastMove: */ i5.BoardPosition(
        row: /* TODO: provide int value for row: */ 0,
        col: /* TODO: provide int value for col: */ 0,
        dimension: /* TODO: provide int value for dimension: */ 0,
      ),
    ),
    onCellSelected: /* TODO: provide function value for onCellSelected: */ (
      i5.BoardPosition position,
    ) {
      // TODO: implement callback
    },
    canSelectCell: /* TODO: provide function value for canSelectCell: */ (
      i5.BoardPosition position,
    ) {
      return /* TODO: provide bool for return type */ false;
    },
    matchStatus: /* TODO: provide GameStatus value for matchStatus: */ i4.GameStatus.inProgress,
    localPlayerMark: /* TODO: provide optional PlayerMark value for localPlayerMark: */ i3.PlayerMark.x,
    lastMove: /* TODO: provide optional BoardPosition value for lastMove: */ i5.BoardPosition(
      row: /* TODO: provide int value for row: */ 0,
      col: /* TODO: provide int value for col: */ 0,
      dimension: /* TODO: provide int value for dimension: */ 0,
    ),
  );
}

