enum PlayerMark { x, o }

extension PlayerMarkX on PlayerMark {
  PlayerMark get opponent => this == PlayerMark.x ? PlayerMark.o : PlayerMark.x;

  String get label => this == PlayerMark.x ? 'X' : 'O';
}