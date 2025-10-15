import 'package:flutter_test/flutter_test.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';

void main() {
  test('BoardPosition computes index based on dimension', () {
    const position = BoardPosition(row: 2, col: 1, dimension: 4);
    expect(position.index, equals(9));

    final fromIndex = BoardPosition.fromIndex(9, dimension: 4);
    expect(fromIndex, equals(position));
  });
}