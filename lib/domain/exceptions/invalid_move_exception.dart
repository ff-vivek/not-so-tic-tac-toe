class InvalidMoveException implements Exception {
  InvalidMoveException(this.message);

  final String message;

  @override
  String toString() => 'InvalidMoveException: $message';
}