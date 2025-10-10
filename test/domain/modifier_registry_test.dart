import 'package:flutter_test/flutter_test.dart';
import 'package:not_so_tic_tac_toe_game/data/modifiers/stub_modifiers.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/game_modifier.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_registry.dart';

class _MockModifier extends GameModifier {
  _MockModifier(this.identifier);

  final String identifier;

  @override
  String get id => identifier;

  @override
  String get name => 'Mock';

  @override
  String get description => 'Mock modifier for testing';
}

void main() {
  group('ModifierRegistry', () {
    test('registers default modifiers without conflict', () {
      final registry = ModifierRegistry();
      registry.register(() => NoOpModifier());

      expect(registry.registeredModifiers.map((m) => m.id), contains('noop'));
    });

    test('throws when registering duplicate modifier id', () {
      final registry = ModifierRegistry();
      registry.register(() => _MockModifier('duplicate'));

      expect(
        () => registry.register(() => _MockModifier('duplicate')),
        throwsArgumentError,
      );
    });

    test('creates modifier instances by id', () {
      final registry = ModifierRegistry();
      registry
        ..register(() => _MockModifier('first'))
        ..register(() => ReservedModifier(modifierId: 'reserved'));

      final created = registry.create('reserved');
      expect(created.id, 'reserved');
      expect(created.name, 'Reserved Slot');
    });
  });
}