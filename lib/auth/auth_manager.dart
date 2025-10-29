import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// google_sign_in and sign_in_with_apple are not required when using
// FirebaseAuth.signInWithProvider on mobile, but remain as dependencies
// for future UI-specific needs.

/// Manages Firebase authentication lifecycle and exposes the current user id.
abstract class AuthManager {
  /// Returns the id of the currently signed-in user, or null when unauthenticated.
  String? get currentUserId;

  /// Returns the current Firebase [User], or null when unauthenticated.
  User? get currentUser;

  /// Emits updates whenever the authentication state changes.
  Stream<String?> userIdChanges();

  /// Ensures the user is authenticated before continuing (defaults to anonymous sign-in).
  Future<void> ensureAuthenticated();

  /// Signs the current user out.
  Future<void> signOut();

  /// Sign in with Google. If the current user is anonymous, link the credential.
  Future<UserCredential> signInWithGoogle({bool linkIfAnonymous = true});

  /// Sign in with Apple (iOS/macOS only). If the current user is anonymous, link the credential.
  Future<UserCredential> signInWithApple({bool linkIfAnonymous = true});

  /// Sign in with Email/Password. If [linkIfAnonymous] and user is anonymous, link instead of sign-in.
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password, {
    bool linkIfAnonymous = true,
  });

  /// Creates a new email/password account or links to the current user if anonymous.
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password, {
    bool linkIfAnonymous = true,
  });

  /// Link the given provider to the current user.
  Future<UserCredential> linkWithGoogle();
  Future<UserCredential> linkWithApple();
  Future<UserCredential> linkWithEmailPassword(String email, String password);

  /// Unlink a provider id from the current user (e.g., 'google.com').
  Future<User> unlinkProvider(String providerId);

  /// Returns the list of linked provider ids for the current user.
  List<String> linkedProviderIds();

  /// Update auth profile and refresh user.
  Future<void> updateDisplayName(String displayName);
  Future<void> updatePhotoUrl(String? photoUrl);
  Future<void> reloadUser();

  /// Reauthenticate for sensitive operations.
  Future<UserCredential> reauthenticateWithEmail(String email, String password);
  Future<UserCredential> reauthenticateWithProvider(String providerId);

  /// Send a password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Delete account (caller should ensure reauth as needed).
  Future<void> deleteAccount();
}

class FirebaseAuthManager implements AuthManager {
  FirebaseAuthManager(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

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

  @override
  Future<UserCredential> signInWithGoogle({bool linkIfAnonymous = true}) async {
    final current = _firebaseAuth.currentUser;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      if (current != null && current.isAnonymous && linkIfAnonymous) {
        return current.linkWithPopup(provider);
      }
      return _firebaseAuth.signInWithPopup(provider);
    }

    // Mobile platforms: use native provider flow
    final provider = GoogleAuthProvider();
    if (current != null && current.isAnonymous && linkIfAnonymous) {
      return current.linkWithProvider(provider);
    }
    return _firebaseAuth.signInWithProvider(provider);
  }

  @override
  Future<UserCredential> signInWithApple({bool linkIfAnonymous = true}) async {
    // Apple Sign In using Firebase provider flow (iOS/macOS only)
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      throw FirebaseAuthException(
        code: 'platform-unsupported',
        message: 'Sign in with Apple is only available on iOS and macOS.',
      );
    }

    final provider = OAuthProvider('apple.com');
    final current = _firebaseAuth.currentUser;
    if (current != null && current.isAnonymous && linkIfAnonymous) {
      return current.linkWithProvider(provider);
    }
    return _firebaseAuth.signInWithProvider(provider);
  }

  @override
  Future<UserCredential> signInWithEmailPassword(String email, String password,
      {bool linkIfAnonymous = true}) async {
    final current = _firebaseAuth.currentUser;
    final credential = EmailAuthProvider.credential(email: email, password: password);

    if (current != null && current.isAnonymous && linkIfAnonymous) {
      return current.linkWithCredential(credential);
    }
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signUpWithEmailPassword(String email, String password,
      {bool linkIfAnonymous = true}) async {
    final current = _firebaseAuth.currentUser;
    final credential = EmailAuthProvider.credential(email: email, password: password);
    if (current != null && current.isAnonymous && linkIfAnonymous) {
      return current.linkWithCredential(credential);
    }
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> linkWithGoogle() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('No user to link with Google');
    }
    if (kIsWeb) {
      return user.linkWithPopup(GoogleAuthProvider());
    }
    return user.linkWithProvider(GoogleAuthProvider());
  }

  @override
  Future<UserCredential> linkWithApple() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('No user to link with Apple');
    }
    final provider = OAuthProvider('apple.com');
    return user.linkWithProvider(provider);
  }

  @override
  Future<UserCredential> linkWithEmailPassword(String email, String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('No user to link with email/password');
    final credential = EmailAuthProvider.credential(email: email, password: password);
    return user.linkWithCredential(credential);
  }

  @override
  Future<User> unlinkProvider(String providerId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('No user to unlink');
    return user.unlink(providerId);
  }

  @override
  List<String> linkedProviderIds() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return const [];
    return user.providerData.map((p) => p.providerId).toList(growable: false);
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('No user to update');
    await user.updateDisplayName(displayName);
    await user.reload();
  }

  @override
  Future<void> updatePhotoUrl(String? photoUrl) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('No user to update');
    await user.updatePhotoURL(photoUrl);
    await user.reload();
  }

  @override
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  @override
  Future<UserCredential> reauthenticateWithEmail(String email, String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('No user to reauthenticate');
    final credential = EmailAuthProvider.credential(email: email, password: password);
    return user.reauthenticateWithCredential(credential);
  }

  @override
  Future<UserCredential> reauthenticateWithProvider(String providerId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('No user to reauthenticate');
    switch (providerId) {
      case 'google.com':
        if (kIsWeb) return user.reauthenticateWithPopup(GoogleAuthProvider());
        return user.reauthenticateWithProvider(GoogleAuthProvider());
      case 'apple.com':
        return user.reauthenticateWithProvider(OAuthProvider('apple.com'));
      default:
        throw ArgumentError('Unsupported provider for reauth: $providerId');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await user.delete();
  }
}