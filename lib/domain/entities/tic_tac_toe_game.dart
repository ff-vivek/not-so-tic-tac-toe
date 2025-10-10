import 'dart:collection';

import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/exceptions/invalid_move_exception.dart';

class TicTacToeGame {
  TicTacToeGame._({
    required List<PlayerMark?> board,
    required this.activePlayer,
    required this.status,
    required this.winner,
    BoardPosition? lastMovePosition,
    required this.startingPlayer,
  })  : _board = UnmodifiableListView<PlayerMark?>(board),
        lastMove = lastMovePosition;

  factory TicTacToeGame.newGame({PlayerMark startingPlayer = PlayerMark.x}) {
    return TicTacToeGame._(
      board: List<PlayerMark?>.filled(9, null),
      activePlayer: startingPlayer,
      status: GameStatus.inProgress,
      winner: null,
      lastMovePosition: null,
      startingPlayer: startingPlayer,
    );
  }

  factory TicTacToeGame.fromState({
    required List<PlayerMark?> board,
    required PlayerMark activePlayer,
    required GameStatus status,
    required PlayerMark? winner,
    required BoardPosition? lastMove,
    required PlayerMark startingPlayer,
  }) {
    if (board.length != 9) {
      throw ArgumentError('Board must contain exactly 9 cells.');
    }

    return TicTacToeGame._(
      board: board,
      activePlayer: activePlayer,
      status: status,
      winner: winner,
      lastMovePosition: lastMove,
      startingPlayer: startingPlayer,
    );
  }

  final UnmodifiableListView<PlayerMark?> _board;
  final PlayerMark activePlayer;
  final GameStatus status;
  final PlayerMark? winner;
  final BoardPosition? lastMove;
  final PlayerMark startingPlayer;

  List<PlayerMark?> get board => List<PlayerMark?>.from(_board);

  PlayerMark? markAt(BoardPosition position) => _board[position.index];

  bool get isComplete => status != GameStatus.inProgress;

  bool canPlayAt(BoardPosition position) {
    if (isComplete) return false;
    if (_board[position.index] != null) return false;
    return true;
  }

  TicTacToeGame playMove(BoardPosition position) {
    if (status != GameStatus.inProgress) {
      throw InvalidMoveException('Game has already completed');
    }

    if (_board[position.index] != null) {
      throw InvalidMoveException('Cell is already occupied');
    }

    final updatedBoard = List<PlayerMark?>.from(_board);
    updatedBoard[position.index] = activePlayer;

    final winningMark = _detectWinner(updatedBoard);
    final hasWinner = winningMark != null;
    final boardFull = updatedBoard.every((mark) => mark != null);

    final newStatus = hasWinner
        ? GameStatus.won
        : boardFull
            ? GameStatus.draw
            : GameStatus.inProgress;

    final nextPlayer = newStatus == GameStatus.inProgress
        ? activePlayer.opponent
        : activePlayer;

    return TicTacToeGame._(
      board: updatedBoard,
      activePlayer: nextPlayer,
      status: newStatus,
      winner: winningMark,
      lastMovePosition: position,
      startingPlayer: startingPlayer,
    );
  }

  static PlayerMark? _detectWinner(List<PlayerMark?> board) {
    const winningLines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final line in winningLines) {
      final a = board[line[0]];
      final b = board[line[1]];
      final c = board[line[2]];
      if (a != null && a == b && a == c) {
        return a;
      }
    }

    return null;
  }
}