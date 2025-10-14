import 'dart:math';

import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';

// Winning line definitions reused by both modifier generators.
const List<List<int>> _winningLines = [
  [0, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
  [0, 3, 6],
  [1, 4, 7],
  [2, 5, 8],
  [0, 4, 8],
  [2, 4, 6],
];

final List<List<int>> _validBlockedPairs = _computeValidBlockedPairs();

/// Randomly selects a pair of blocked squares for the "Blocked Squares" modifier.
///
/// The returned indices are guaranteed to preserve at least one fully open
/// winning line so the round always remains winnable.
List<int> generateBlockedSquares(Random random) {
  if (_validBlockedPairs.isEmpty) {
    throw StateError('No valid blocked-square combinations available.');
  }

  final pair = _validBlockedPairs[random.nextInt(_validBlockedPairs.length)];
  return List<int>.from(pair)..sort();
}

/// Computes the spinner-highlighted squares for the "Spinner" modifier.
///
/// Returns up to [desiredChoices] distinct indices that correspond to the
/// currently available board squares. If fewer squares remain, all available
/// indices are returned. When the board is full the result is empty.
List<int> generateSpinnerChoices({
  required Random random,
  required List<PlayerMark?> board,
  int desiredChoices = 2,
}) {
  if (board.length != 9) {
    throw ArgumentError('Spinner choices require a 3x3 board (9 cells).');
  }
  if (desiredChoices <= 0) {
    return const [];
  }

  final availableIndices = <int>[];
  for (var i = 0; i < board.length; i++) {
    if (board[i] == null) {
      availableIndices.add(i);
    }
  }

  if (availableIndices.isEmpty) {
    return const [];
  }

  if (availableIndices.length <= desiredChoices) {
    return List<int>.from(availableIndices)..sort();
  }

  final shuffled = List<int>.from(availableIndices);
  shuffled.shuffle(random);
  final selection = shuffled.take(desiredChoices).toList()..sort();
  return selection;
}

List<List<int>> _computeValidBlockedPairs() {
  final pairs = <List<int>>[];
  for (var i = 0; i < 9; i++) {
    for (var j = i + 1; j < 9; j++) {
      final blocksWinningLine = _winningLines.every(
        (line) => line.contains(i) || line.contains(j),
      );

      if (!blocksWinningLine) {
        pairs.add([i, j]);
      }
    }
  }
  return pairs;
}