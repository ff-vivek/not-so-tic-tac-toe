import 'package:flutter/widgets.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/game_status_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_category.dart';
import 'package:flutter/widgets.dart';

@Preview(name: 'Default')
Widget previewGameStatusBanner_808d7dca8a74d84af27a2d6602c3d786de45fe1e() {
  return GameStatusBanner(
    key: /* TODO: provide optional Key value for key: */ Key(
      /* TODO: provide String value for value: */ '',
    ),
    gameState: /* TODO: provide TicTacToeGame value for gameState: */ TicTacToeGame.newGame(
      startingPlayer: /* TODO: provide PlayerMark value for startingPlayer: */ PlayerMark.x,
    ),
    localPlayerMark: /* TODO: provide optional PlayerMark value for localPlayerMark: */ PlayerMark.x,
    onPlayAgain: /* TODO: provide optional function value for onPlayAgain: */ () {
      // TODO: implement callback
    },
    onReturnToMenu: /* TODO: provide optional function value for onReturnToMenu: */ () {
      // TODO: implement callback
    },
    onLeave: /* TODO: provide optional function value for onLeave: */ () {
      // TODO: implement callback
    },
    activeModifierCategory: /* TODO: provide optional ModifierCategory value for activeModifierCategory: */ ModifierCategory.handYoureDealt,
    activeModifierId: /* TODO: provide optional String value for activeModifierId: */ '',
    postGameActions: /* TODO: provide List value for postGameActions: */ <SizedBox>[],
  );
}
