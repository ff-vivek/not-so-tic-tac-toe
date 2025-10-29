import 'package:not_so_tic_tac_toe_game/domain/entities/tournament.dart';

abstract class TournamentRepository {
  Stream<List<Tournament>> watchOpenTournaments();
  Stream<List<Tournament>> watchMyTournaments(String playerId);
  Future<String> createTournament({
    required String name,
    required int maxPlayers,
    DateTime? startsAt,
  });
  Future<void> joinTournament({required String tournamentId, required String playerId});
}
