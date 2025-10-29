import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/exceptions/invalid_move_exception.dart';

class OfflineMatchState {
  const OfflineMatchState({
    required this.game,
    required this.round,
    required this.nextStartingPlayer,
  });

  final TicTacToeGame game;
  final int round;
  final PlayerMark nextStartingPlayer;

  OfflineMatchState copyWith({
    TicTacToeGame? game,
    int? round,
    PlayerMark? nextStartingPlayer,
  }) {
    return OfflineMatchState(
      game: game ?? this.game,
      round: round ?? this.round,
      nextStartingPlayer: nextStartingPlayer ?? this.nextStartingPlayer,
    );
  }
}

class OfflineMatchController extends Notifier<OfflineMatchState?> {
  @override
  OfflineMatchState? build() => null;

  void startNewMatch({PlayerMark? startingPlayer}) {
    final resolvedStarter =
        startingPlayer ?? state?.nextStartingPlayer ?? PlayerMark.x;
    final nextStarter = resolvedStarter.opponent;
    final round = (state?.round ?? 0) + 1;

    state = OfflineMatchState(
      game: TicTacToeGame.newGame(startingPlayer: resolvedStarter),
      round: round,
      nextStartingPlayer: nextStarter,
    );
  }

  void playMove(BoardPosition position) {
    final current = state;
    if (current == null) {
      return;
    }

    try {
      final updatedGame = current.game.playMove(position);
      state = current.copyWith(game: updatedGame);
    } on InvalidMoveException {
      // Ignore invalid local taps so the board feels responsive.
    }
  }

  void rematch() {
    final nextStarter = state?.nextStartingPlayer ?? PlayerMark.x;
    startNewMatch(startingPlayer: nextStarter);
  }

  void exitToMenu() {
    state = null;
  }
}

final offlineMatchControllerProvider =
    NotifierProvider<OfflineMatchController, OfflineMatchState?>(
  OfflineMatchController.new,
);