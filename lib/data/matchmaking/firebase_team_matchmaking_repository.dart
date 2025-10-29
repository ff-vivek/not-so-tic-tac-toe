import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/team_matchmaking_repository.dart';

class FirebaseTeamMatchmakingRepository implements TeamMatchmakingRepository {
  FirebaseTeamMatchmakingRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection('matches');

  @override
  Future<String> createTeamMatch({
    required List<String> teamXIds,
    required List<String> teamOIds,
  }) async {
    if (teamXIds.isEmpty || teamOIds.isEmpty) {
      throw ArgumentError('Both teams must have at least one player');
    }
    final ref = _matches.doc();
    final timestamp = FieldValue.serverTimestamp();
    await ref.set({
      'playerXId': teamXIds.first,
      'playerOId': teamOIds.first,
      'teamXIds': teamXIds,
      'teamOIds': teamOIds,
      'participants': [...teamXIds, ...teamOIds],
      'teamMode': true,
      'activeMark': 'x',
      'activePlayerId': teamXIds.first,
      'startingMark': 'x',
      'status': 'in_progress',
      'board': List<dynamic>.filled(9, null),
      'winnerMark': null,
      'winnerPlayerId': null,
      'lastMoveIndex': null,
      'createdAt': timestamp,
      'updatedAt': timestamp,
      'modifierId': null,
      'modifierCategory': null,
      'modifierState': <String, dynamic>{},
      'playerStates': {
        for (final id in [...teamXIds, ...teamOIds]) id: 'active',
      },
    });
    return ref.id;
  }
}
