class BoardPosition {
  BoardPosition({required this.row, required this.col}) {
    if (row < 0 || row > 2 || col < 0 || col > 2) {
      throw ArgumentError('BoardPosition must be within 0-2 for both row and col');
    }
  }

  final int row;
  final int col;

  int get index => row * 3 + col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardPosition && other.row == row && other.col == col;
  }

  @override
  String toString() => 'BoardPosition(row: $row, col: $col)';
}