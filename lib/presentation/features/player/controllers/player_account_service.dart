import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles player account profile initialization and updates in Firestore.
class PlayerAccountService {
  PlayerAccountService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _players =>
      _firestore.collection('players');

  /// Upserts the current user's player profile with auth details, currency, inventory, and timestamps.
  Future<void> upsertCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = _players.doc(user.uid);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(doc);

      final authData = <String, dynamic>{
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'isAnonymous': user.isAnonymous,
        'providerIds': user.providerData.map((p) => p.providerId).toList(),
        'lastSignInAt': FieldValue.serverTimestamp(),
      };

      if (snap.exists) {
        final updates = <String, dynamic>{
          'auth': authData,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        final data = snap.data()!;
        if (!data.containsKey('currentWinStreak')) updates['currentWinStreak'] = 0;
        if (!data.containsKey('maxWinStreak')) updates['maxWinStreak'] = 0;
        if (!data.containsKey('currencySoft')) updates['currencySoft'] = 0;
        if (!data.containsKey('inventory')) {
          updates['inventory'] = _defaultInventory();
        }

        if (updates.isNotEmpty) {
          tx.update(doc, updates);
        }
      } else {
        tx.set(doc, {
          'currentWinStreak': 0,
          'maxWinStreak': 0,
          'currencySoft': 0,
          'inventory': _defaultInventory(),
          'auth': authData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Map<String, dynamic> _defaultInventory() => {
        'ownedMarkSkins': <String>[],
        'ownedBoardSkins': <String>[],
        'equippedMarkSkin': null,
        'equippedBoardSkin': null,
      };

  /// Update displayName in FirebaseAuth and mirror into Firestore via upsert.
  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(displayName);
    await user.reload();
    await upsertCurrentUserProfile();
  }

  /// Update photoURL in FirebaseAuth and mirror into Firestore via upsert.
  Future<void> updatePhotoUrl(String? photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updatePhotoURL(photoUrl);
    await user.reload();
    await upsertCurrentUserProfile();
  }

  /// Soft-delete the player's Firestore profile for potential recovery.
  Future<void> softDeleteProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = _players.doc(user.uid);
    await doc.set({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
