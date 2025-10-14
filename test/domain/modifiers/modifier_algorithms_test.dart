import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_algorithms.dart';

void main() {
  group('generateBlockedSquares', () {
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

    test('returns two distinct indices within range that keep a winning line open', () {
      final random = Random(1234);
      for (var i = 0; i < 25; i++) {
        final pair = generateBlockedSquares(random);
        expect(pair.length, 2);
        expect(pair.toSet().length, 2);
        expect(pair.every((index) => index >= 0 && index < 9), isTrue);

        final hasOpenLine = winningLines.any(
          (line) => !line.contains(pair[0]) && !line.contains(pair[1]),
        );
        expect(hasOpenLine, isTrue);
      }
    });
  });

  group('generateSpinnerChoices', () {
    test('returns two distinct indices drawn from available squares', () {
      final random = Random(42);
      final board = List<PlayerMark?>.filled(9, null);
      board[0] = PlayerMark.x;
      board[4] = PlayerMark.o;

      final choices = generateSpinnerChoices(random: random, board: board);
      expect(choices.length, 2);
      expect(choices.toSet().length, 2);
      expect(choices.every((index) => board[index] == null), isTrue);
    });

    test('returns single option when one square remains', () {
      final random = Random(9);
      final board = List<PlayerMark?>.filled(9, PlayerMark.x);
      board[8] = null;

      final choices = generateSpinnerChoices(random: random, board: board);
      expect(choices, [8]);
    });

    test('returns empty list when no squares remain', () {
      final random = Random(55);
      final board = List<PlayerMark?>.filled(9, PlayerMark.o);

      final choices = generateSpinnerChoices(random: random, board: board);
      expect(choices, isEmpty);
    });
  });
}