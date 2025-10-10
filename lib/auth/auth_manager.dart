import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Manages Firebase authentication lifecycle and exposes the current user id.
abstract class AuthManager {
  /// Returns the id of the currently signed-in user, or null when unauthenticated.
  String? get currentUserId;

  /// Emits updates whenever the authentication state changes.
  Stream<String?> userIdChanges();

  /// Ensures the user is authenticated before continuing (defaults to anonymous sign-in).
  Future<void> ensureAuthenticated();

  /// Signs the current user out.
  Future<void> signOut();
}

class FirebaseAuthManager implements AuthManager {
  FirebaseAuthManager(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Stream<String?> userIdChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<void> ensureAuthenticated() async {
    if (_firebaseAuth.currentUser == null) {
      await _firebaseAuth.signInAnonymously();
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}