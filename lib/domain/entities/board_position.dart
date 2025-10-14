class BoardPosition {
  const BoardPosition({required this.row, required this.col}) : assert(row < 0 || row > 2 || col < 0 || col > 2,'BoardPosition must be within 0-2 for both row and col');

  final int row;
  final int col;

  int get index => row * 3 + col;

  factory BoardPosition.fromIndex(int index) {
    if (index < 0 || index > 8) {
      throw ArgumentError('BoardPosition index must be between 0 and 8.');
    }
    final row = index ~/ 3;
    final col = index % 3;
    return BoardPosition(row: row, col: col);
  }

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