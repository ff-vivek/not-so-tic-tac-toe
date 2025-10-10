import 'package:not_so_tic_tac_toe_game/domain/modifiers/game_modifier.dart';

typedef GameModifierBuilder = GameModifier Function();

class ModifierRegistry {
  ModifierRegistry();

  final Map<String, GameModifierBuilder> _builders = {};

  void register(GameModifierBuilder builder) {
    final modifier = builder();
    if (_builders.containsKey(modifier.id)) {
      throw ArgumentError('Modifier with id ${modifier.id} already registered');
    }
    _builders[modifier.id] = builder;
  }

  GameModifier create(String id) {
    final builder = _builders[id];
    if (builder == null) {
      throw ArgumentError('Modifier with id $id is not registered');
    }
    return builder();
  }

  List<GameModifier> get registeredModifiers {
    return _builders.values.map((builder) => builder()).toList(growable: false);
  }

  bool get isEmpty => _builders.isEmpty;
}