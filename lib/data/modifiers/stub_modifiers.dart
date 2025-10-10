import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/game_modifier.dart';

class NoOpModifier extends GameModifier {
  @override
  String get id => 'noop';

  @override
  String get name => 'Standard Rules';

  @override
  String get description => 'Play a classic game with no modifiers.';
}

class ReservedModifier extends GameModifier {
  ReservedModifier({required this.modifierId});

  final String modifierId;

  @override
  String get id => modifierId;

  @override
  String get name => 'Reserved Slot';

  @override
  String get description =>
      'Placeholder modifier to be implemented in a future milestone.';

  @override
  TicTacToeGame applyPreGame(TicTacToeGame game) {
    return game;
  }
}