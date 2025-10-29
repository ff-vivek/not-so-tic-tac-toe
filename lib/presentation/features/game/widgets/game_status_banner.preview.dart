import 'package:flutter/widgets.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/game_status_banner.dart' as i0;
import 'package:flutter/foundation.dart' as i1;
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart' as i2;
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart' as i3;
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart' as i4;
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart' as i5;
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_category.dart' as i6;
import 'package:flutter/widgets.dart' as i7;


@Preview(name: 'GameStatusBanner')
Widget previewGameStatusBanner() {
  return i0.GameStatusBanner(
    key: /* TODO: provide optional Key value for key: */ i1.Key(
      /* TODO: provide String value for value: */ '',
    ),
    gameState: /* TODO: provide TicTacToeGame value for gameState: */ i2.TicTacToeGame.newGame(
      startingPlayer: /* TODO: provide PlayerMark value for startingPlayer: */ i3.PlayerMark.x,
    ),
    localPlayerMark: /* TODO: provide optional PlayerMark value for localPlayerMark: */ i3.PlayerMark.x,
    onPlayAgain: /* TODO: provide optional function value for onPlayAgain: */ () {
      // TODO: implement callback
    },
    onReturnToMenu: /* TODO: provide optional function value for onReturnToMenu: */ () {
      // TODO: implement callback
    },
    onLeave: /* TODO: provide optional function value for onLeave: */ () {
      // TODO: implement callback
    },
    activeModifierCategory: /* TODO: provide optional ModifierCategory value for activeModifierCategory: */ i6.ModifierCategory.handYoureDealt,
    activeModifierId: /* TODO: provide optional String value for activeModifierId: */ '',
    postGameActions: /* TODO: provide List value for postGameActions: */ <i7.SizedBox>[],
  );
}

