import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tournament.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/tournament_repository.dart';

class FirebaseTournamentRepository implements TournamentRepository {
  FirebaseTournamentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tournaments =>
      _firestore.collection('tournaments');

  @override
  Stream<List<Tournament>> watchOpenTournaments() {
    return _tournaments
        .where('status', whereIn: ['recruiting', 'scheduled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Tournament.fromMap(d.id, d.data())).toList());
  }

  @override
  Stream<List<Tournament>> watchMyTournaments(String playerId) {
    return _tournaments
        .where('participants', arrayContains: playerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Tournament.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<String> createTournament({
    required String name,
    required int maxPlayers,
    DateTime? startsAt,
  }) async {
    final ref = _tournaments.doc();
    final now = FieldValue.serverTimestamp();
    await ref.set({
      'name': name,
      'status': startsAt == null ? 'recruiting' : 'scheduled',
      'participants': <String>[],
      'maxPlayers': maxPlayers,
      'createdAt': now,
      'startsAt': startsAt == null ? null : Timestamp.fromDate(startsAt),
    });
    return ref.id;
  }

  @override
  Future<void> joinTournament({
    required String tournamentId,
    required String playerId,
  }) async {
    final ref = _tournaments.doc(tournamentId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw StateError('Tournament not found');
      }
      final data = snap.data()!;
      final participants = List<String>.from((data['participants'] as List?) ?? <String>[]);
      final maxPlayers = (data['maxPlayers'] as num?)?.toInt() ?? 16;
      if (!participants.contains(playerId)) {
        if (participants.length >= maxPlayers) {
          throw StateError('Tournament is already full');
        }
        participants.add(playerId);
        tx.update(ref, {
          'participants': participants,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
