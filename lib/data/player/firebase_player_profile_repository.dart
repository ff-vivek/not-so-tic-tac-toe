import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_profile.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/player_profile_repository.dart';

class FirebasePlayerProfileRepository implements PlayerProfileRepository {
  FirebasePlayerProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _playersCollection =>
      _firestore.collection('players');

  @override
  Stream<PlayerProfile> watchProfile({required String playerId}) {
    final docRef = _playersCollection.doc(playerId);
    return docRef.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        return PlayerProfile(
          id: playerId,
          currentWinStreak: 0,
          maxWinStreak: 0,
        );
      }
      return PlayerProfile.fromMap(id: snapshot.id, data: data);
    });
  }

  @override
  Future<void> ensureProfileInitialized({required String playerId}) async {
    final docRef = _playersCollection.doc(playerId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final hasCurrent = data.containsKey('currentWinStreak');
        final hasMax = data.containsKey('maxWinStreak');
        if (hasCurrent && hasMax) {
          return;
        }

        final updates = <String, dynamic>{};
        if (!hasCurrent) updates['currentWinStreak'] = 0;
        if (!hasMax) updates['maxWinStreak'] = 0;
        if (updates.isNotEmpty) {
          updates['updatedAt'] = FieldValue.serverTimestamp();
          transaction.update(docRef, updates);
        }
        return;
      }

      transaction.set(docRef, {
        'currentWinStreak': 0,
        'maxWinStreak': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}