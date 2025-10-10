enum MatchJoinStatus {
  waiting,
  matchReady,
  alreadyInMatch,
}

class MatchJoinResult {
  const MatchJoinResult._(this.status, {this.matchId});

  const MatchJoinResult.waiting() : this._(MatchJoinStatus.waiting);

  const MatchJoinResult.matchReady(String matchId)
      : this._(MatchJoinStatus.matchReady, matchId: matchId);

  const MatchJoinResult.alreadyInMatch(String matchId)
      : this._(MatchJoinStatus.alreadyInMatch, matchId: matchId);

  final MatchJoinStatus status;
  final String? matchId;

  bool get hasMatch => matchId != null;
}