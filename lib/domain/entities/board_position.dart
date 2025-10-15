class BoardPosition {
  const BoardPosition({
    required this.row,
    required this.col,
    this.dimension = 3,
  })  : assert(dimension > 0, 'Board dimension must be positive'),
        assert(row >= 0 && row < dimension,
            'Row index $row must be within 0 and ${dimension - 1}.'),
        assert(col >= 0 && col < dimension,
            'Column index $col must be within 0 and ${dimension - 1}.');

  final int row;
  final int col;
  final int dimension;

  int get index => row * dimension + col;

  factory BoardPosition.fromIndex(int index, {int dimension = 3}) {
    if (dimension <= 0) {
      throw ArgumentError.value(dimension, 'dimension', 'Must be positive');
    }
    final maxIndex = dimension * dimension;
    if (index < 0 || index >= maxIndex) {
      throw ArgumentError(
        'BoardPosition index must be between 0 and ${maxIndex - 1}.',
      );
    }
    final row = index ~/ dimension;
    final col = index % dimension;
    return BoardPosition(row: row, col: col, dimension: dimension);
  }

  BoardPosition copyWith({int? row, int? col, int? dimension}) {
    return BoardPosition(
      row: row ?? this.row,
      col: col ?? this.col,
      dimension: dimension ?? this.dimension,
    );
  }

  @override
  int get hashCode => Object.hash(row, col, dimension);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardPosition &&
        other.row == row &&
        other.col == col &&
        other.dimension == dimension;
  }

  @override
  String toString() =>
      'BoardPosition(row: $row, col: $col, dimension: $dimension)';
}