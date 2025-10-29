import 'package:flutter/widgets.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/ultimate_mode_board.dart';
import 'package:flutter/foundation.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/ultimate_board_state.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';

@Preview(name: 'Default')
Widget previewUltimateModeBoard_808d7dca8a74d84af27a2d6602c3d786de45fe1e() {
  return UltimateModeBoard(
    key: /* TODO: provide optional Key value for key: */ Key(
      /* TODO: provide String value for value: */ '',
    ),
    state: /* TODO: provide UltimateBoardState value for state: */ UltimateBoardState(
      miniBoards: /* TODO: provide List value for miniBoards: */ <UltimateMiniBoard>[],
      activeBoardIndex: /* TODO: provide optional int value for activeBoardIndex: */ 0,
      lastMove: /* TODO: provide optional BoardPosition value for lastMove: */ BoardPosition(
        row: /* TODO: provide int value for row: */ 0,
        col: /* TODO: provide int value for col: */ 0,
        dimension: /* TODO: provide int value for dimension: */ 0,
      ),
    ),
    onCellSelected: /* TODO: provide function value for onCellSelected: */ (
      BoardPosition position,
    ) {
      // TODO: implement callback
    },
    canSelectCell: /* TODO: provide function value for canSelectCell: */ (
      BoardPosition position,
    ) {
      return /* TODO: provide bool for return type */ false;
    },
    matchStatus: /* TODO: provide GameStatus value for matchStatus: */ GameStatus.inProgress,
    localPlayerMark: /* TODO: provide optional PlayerMark value for localPlayerMark: */ PlayerMark.x,
    lastMove: /* TODO: provide optional BoardPosition value for lastMove: */ BoardPosition(
      row: /* TODO: provide int value for row: */ 0,
      col: /* TODO: provide int value for col: */ 0,
      dimension: /* TODO: provide int value for dimension: */ 0,
    ),
  );
}
