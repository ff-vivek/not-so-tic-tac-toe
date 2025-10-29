import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/clan.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/clan_message.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/clan_repository.dart';

class FirebaseClanRepository implements ClanRepository {
  FirebaseClanRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _clans => _firestore.collection('clans');

  @override
  Stream<Clan?> watchMyClan(String playerId) {
    return _clans.where('members', arrayContains: playerId).limit(1).snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return Clan.fromMap(d.id, d.data());
    });
  }

  @override
  Future<String> createClan({required String name, required String ownerId}) async {
    final ref = _clans.doc();
    await ref.set({
      'name': name,
      'ownerId': ownerId,
      'members': [ownerId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  @override
  Future<void> joinClan({required String clanId, required String playerId}) async {
    final ref = _clans.doc(clanId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw StateError('Clan not found');
      final data = snap.data()!;
      final members = List<String>.from((data['members'] as List?) ?? <String>[]);
      if (!members.contains(playerId)) {
        members.add(playerId);
        tx.update(ref, {'members': members, 'updatedAt': FieldValue.serverTimestamp()});
      }
    });
  }

  @override
  Future<void> leaveClan({required String clanId, required String playerId}) async {
    final ref = _clans.doc(clanId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data()!;
      final members = List<String>.from((data['members'] as List?) ?? <String>[]);
      members.remove(playerId);
      tx.update(ref, {'members': members, 'updatedAt': FieldValue.serverTimestamp()});
    });
  }

  @override
  Future<void> sendMessage({
    required String clanId,
    required String senderId,
    required String text,
  }) async {
    final msgRef = _clans.doc(clanId).collection('messages').doc();
    await msgRef.set({
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<ClanMessage>> watchMessages(String clanId) {
    return _clans
        .doc(clanId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ClanMessage.fromMap(d.id, d.data())).toList());
  }
}
