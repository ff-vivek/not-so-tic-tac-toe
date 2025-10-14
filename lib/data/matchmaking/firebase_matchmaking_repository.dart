import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_algorithms.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_category.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/matchmaking_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/value_objects/match_join_result.dart';

class FirebaseMatchmakingRepository implements MatchmakingRepository {
  FirebaseMatchmakingRepository(this._firestore) : _random = Random();

  final FirebaseFirestore _firestore;
  final Random _random;

  CollectionReference<Map<String, dynamic>> get _matchesCollection =>
      _firestore.collection('matches');

  DocumentReference<Map<String, dynamic>> get _queueDocument =>
      _firestore.collection('matchmaking').doc('queue');

  @override
  Future<MatchJoinResult> joinQueue(String playerId) async {
    final activeMatch = await _matchesCollection
        .where('playerStates.$playerId', isEqualTo: 'active')
        .limit(1)
        .get();

    if (activeMatch.docs.isNotEmpty) {
      return MatchJoinResult.alreadyInMatch(activeMatch.docs.first.id);
    }

    return _firestore.runTransaction((transaction) async {
      final queueSnapshot = await transaction.get(_queueDocument);
      final data = queueSnapshot.data();
      final waitingPlayerId = data?['waitingPlayerId'] as String?;

      if (waitingPlayerId == null || waitingPlayerId == playerId) {
        transaction.set(
          _queueDocument,
          {
            'waitingPlayerId': playerId,
            'waitingSince': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return const MatchJoinResult.waiting();
      }

      final matchRef = _matchesCollection.doc();
      final assignCurrentAsX = _random.nextBool();
      final playerXId = assignCurrentAsX ? playerId : waitingPlayerId;
      final playerOId = assignCurrentAsX ? waitingPlayerId : playerId;
      final timestamp = FieldValue.serverTimestamp();
      final selectedCategory =
          ModifierCategory.values[_random.nextInt(ModifierCategory.values.length)];
      final modifierInfo = _selectModifierForCategory(selectedCategory);

      transaction.set(matchRef, {
        'playerXId': playerXId,
        'playerOId': playerOId,
        'participants': [playerXId, playerOId],
        'activeMark': 'x',
        'activePlayerId': playerXId,
        'startingMark': 'x',
        'status': 'in_progress',
        'board': List<dynamic>.filled(9, null),
        'winnerMark': null,
        'winnerPlayerId': null,
        'lastMoveIndex': null,
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'modifierId': modifierInfo.id,
        'modifierCategory': selectedCategory.storageValue,
        'modifierState': modifierInfo.state,
        'playerStates': {
          playerXId: 'active',
          playerOId: 'active',
        },
      });

      transaction.set(
        _queueDocument,
        {
          'waitingPlayerId': null,
          'waitingSince': null,
        },
        SetOptions(merge: true),
      );

      return MatchJoinResult.matchReady(matchRef.id);
    });
  }

  @override
  Future<void> leaveQueue(String playerId) async {
    await _firestore.runTransaction((transaction) async {
      final queueSnapshot = await transaction.get(_queueDocument);
      if (!queueSnapshot.exists) return;
      final data = queueSnapshot.data();
      final waitingPlayerId = data?['waitingPlayerId'] as String?;
      if (waitingPlayerId == playerId) {
        transaction.set(
          _queueDocument,
          {
            'waitingPlayerId': null,
            'waitingSince': null,
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  _ModifierInfo _selectModifierForCategory(ModifierCategory category) {
    switch (category) {
      case ModifierCategory.handYoureDealt:
        final blockedSquares = generateBlockedSquares(_random);
        return _ModifierInfo(
          id: 'blocked_squares',
          state: {
            'blockedSquares': blockedSquares,
          },
        );
      case ModifierCategory.forcedMoves:
        final spinnerChoices = generateSpinnerChoices(
          random: _random,
          board: List<PlayerMark?>.filled(9, null),
        );
        return _ModifierInfo(
          id: 'spinner',
          state: {
            'spinnerChoices': spinnerChoices,
          },
        );
    }
  }
}

class _ModifierInfo {
  _ModifierInfo({required this.id, required this.state});

  final String id;
  final Map<String, dynamic> state;
}