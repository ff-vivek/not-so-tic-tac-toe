import 'package:not_so_tic_tac_toe_game/domain/entities/player_profile.dart';

abstract class PlayerProfileRepository {
  Stream<PlayerProfile> watchProfile({required String playerId});

  Future<void> ensureProfileInitialized({required String playerId});
}