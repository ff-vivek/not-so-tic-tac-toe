import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';

/// Represents a gameplay modifier that can transform game rules or state.
abstract class GameModifier {
  String get id;
  String get name;
  String get description;

  /// Called before a game starts so modifiers can adjust initial conditions.
  TicTacToeGame applyPreGame(TicTacToeGame game) => game;

  /// Called after each valid move to let modifiers react to new state.
  TicTacToeGame applyPostMove(TicTacToeGame game) => game;
}