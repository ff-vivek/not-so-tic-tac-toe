import 'package:flutter_test/flutter_test.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/ultimate_board_state.dart';

void main() {
  group('UltimateBoardState', () {
    test('breakdownFor maps absolute coordinates correctly', () {
      final miniBoards = List.generate(
        9,
        (index) => UltimateMiniBoard(
          index: index,
          cells: List<PlayerMark?>.filled(9, null),
          status: GameStatus.inProgress,
          winner: null,
        ),
      );

      final state = UltimateBoardState(miniBoards: miniBoards);
      final position = BoardPosition(row: 7, col: 2, dimension: 9);

      final breakdown = state.resolveAbsolute(position);

      expect(breakdown.miniIndex, equals(6));
      expect(breakdown.cellIndex, equals(5));
      expect(breakdown.cellRow, equals(2));
      expect(breakdown.cellCol, equals(2));
    });

    test('toMap and fromMap round-trip integrity', () {
      final miniBoards = List.generate(
        9,
        (index) => UltimateMiniBoard(
          index: index,
          cells: List<PlayerMark?>.filled(9, null),
          status: index == 3 ? GameStatus.won : GameStatus.inProgress,
          winner: index == 3 ? PlayerMark.x : null,
        ),
      );

      final original = UltimateBoardState(
        miniBoards: miniBoards,
        activeBoardIndex: 5,
        lastMove: const BoardPosition(row: 4, col: 7, dimension: 9),
      );

      final map = original.toMap();
      final hydrated = UltimateBoardState.fromMap(map);

      expect(hydrated.activeBoardIndex, equals(5));
      expect(hydrated.lastMove, equals(const BoardPosition(row: 4, col: 7, dimension: 9)));
      expect(hydrated.boardAt(3).winner, equals(PlayerMark.x));
    });
  });
}