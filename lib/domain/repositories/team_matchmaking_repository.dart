abstract class TeamMatchmakingRepository {
  Future<String> createTeamMatch({
    required List<String> teamXIds,
    required List<String> teamOIds,
  });
}
