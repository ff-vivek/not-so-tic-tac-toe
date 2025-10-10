import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/match_state.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/exceptions/invalid_move_exception.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/match_repository.dart';

class FirebaseMatchRepository implements MatchRepository {
  FirebaseMatchRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _matchesCollection =>
      _firestore.collection('matches');

  @override
  Stream<MatchState?> watchActiveMatch({required String playerId}) {
    final query = _matchesCollection
        .where('playerStates.$playerId', isEqualTo: 'active')
        .limit(1);

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return _mapSnapshot(snapshot.docs.first);
    });
  }

  @override
  Future<void> submitMove({
    required String matchId,
    required String playerId,
    required BoardPosition position,
  }) async {
    final matchRef = _matchesCollection.doc(matchId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(matchRef);
      if (!snapshot.exists) {
        throw InvalidMoveException('Match not found');
      }

      final data = snapshot.data()!;
      final playerStates = Map<String, dynamic>.from(
        (data['playerStates'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      );

      if (playerStates[playerId] != 'active') {
        throw InvalidMoveException('Player not active in this match');
      }

      final statusString = (data['status'] as String?) ?? 'in_progress';
      final currentStatus = _statusFromString(statusString);

      if (currentStatus != GameStatus.inProgress) {
        throw InvalidMoveException('Match has already concluded');
      }

      final activePlayerId = data['activePlayerId'] as String?;
      if (activePlayerId != playerId) {
        throw InvalidMoveException('Not your turn');
      }

      final playerXId = data['playerXId'] as String;
      final playerOId = data['playerOId'] as String;

      final activeMarkString = data['activeMark'] as String? ?? 'x';
      final startingMarkString = data['startingMark'] as String? ?? 'x';
      final winnerMarkString = data['winnerMark'] as String?;
      final lastMoveIndex = data['lastMoveIndex'] as int?;

      final boardRaw = (data['board'] as List<dynamic>? ?? List<dynamic>.filled(9, null))
          .cast<dynamic>()
          .toList(growable: false);

      final currentGame = TicTacToeGame.fromState(
        board: _decodeBoard(boardRaw),
        activePlayer: _markFromString(activeMarkString) ?? PlayerMark.x,
        status: currentStatus,
        winner: _markFromString(winnerMarkString),
        lastMove: lastMoveIndex == null
            ? null
            : BoardPosition(row: lastMoveIndex ~/ 3, col: lastMoveIndex % 3),
        startingPlayer: _markFromString(startingMarkString) ?? PlayerMark.x,
      );

      if (!currentGame.canPlayAt(position)) {
        throw InvalidMoveException('Selected cell is not available');
      }

      final updatedGame = currentGame.playMove(position);

      final nextActivePlayerId = updatedGame.status == GameStatus.inProgress
          ? (updatedGame.activePlayer == PlayerMark.x ? playerXId : playerOId)
          : null;

      transaction.update(matchRef, {
        'board': _encodeBoard(updatedGame.board),
        'activeMark': updatedGame.activePlayer.name,
        'activePlayerId': nextActivePlayerId,
        'status': _statusToString(updatedGame.status),
        'winnerMark': updatedGame.winner?.name,
        'winnerPlayerId': updatedGame.winner == null
            ? null
            : (updatedGame.winner == PlayerMark.x ? playerXId : playerOId),
        'lastMoveIndex': position.index,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> leaveMatch({
    required String matchId,
    required String playerId,
  }) async {
    final matchRef = _matchesCollection.doc(matchId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(matchRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final playerStates = Map<String, dynamic>.from(
        (data['playerStates'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      );

      if (playerStates[playerId] == 'done') {
        return;
      }

      playerStates[playerId] = 'done';
      transaction.update(matchRef, {
        'playerStates.$playerId': 'done',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final remainingActive = playerStates.values
          .whereType<String>()
          .where((value) => value != 'done')
          .isNotEmpty;

      if (!remainingActive) {
        transaction.delete(matchRef);
      }
    });
  }

  MatchState _mapSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final boardRaw = (data['board'] as List<dynamic>? ?? List<dynamic>.filled(9, null))
        .cast<dynamic>()
        .toList(growable: false);
    final activeMarkString = data['activeMark'] as String? ?? 'x';
    final statusString = data['status'] as String? ?? 'in_progress';
    final winnerMarkString = data['winnerMark'] as String?;
    final startingMarkString = data['startingMark'] as String? ?? 'x';
    final lastMoveIndex = data['lastMoveIndex'] as int?;

    final createdAt = _readTimestamp(data['createdAt']);
    final updatedAt = _readTimestamp(data['updatedAt']);

    final game = TicTacToeGame.fromState(
      board: _decodeBoard(boardRaw),
      activePlayer: _markFromString(activeMarkString) ?? PlayerMark.x,
      status: _statusFromString(statusString),
      winner: _markFromString(winnerMarkString),
      lastMove: lastMoveIndex == null
          ? null
          : BoardPosition(row: lastMoveIndex ~/ 3, col: lastMoveIndex % 3),
      startingPlayer: _markFromString(startingMarkString) ?? PlayerMark.x,
    );

    final playerStates = Map<String, MatchParticipantState>.fromEntries(
      ((data['playerStates'] as Map<String, dynamic>?) ?? {})
          .entries
          .map(
            (entry) => MapEntry(
              entry.key,
              entry.value == 'active'
                  ? MatchParticipantState.active
                  : MatchParticipantState.done,
            ),
          ),
    );

    return MatchState(
      id: doc.id,
      playerXId: data['playerXId'] as String,
      playerOId: data['playerOId'] as String,
      game: game,
      status: _statusFromString(statusString),
      playerStates: playerStates,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  List<PlayerMark?> _decodeBoard(List<dynamic> board) {
    return board.map((cell) {
      if (cell == 'x') return PlayerMark.x;
      if (cell == 'o') return PlayerMark.o;
      return null;
    }).toList(growable: false);
  }

  List<dynamic> _encodeBoard(List<PlayerMark?> board) {
    return board.map((mark) => mark?.name).toList(growable: false);
  }

  PlayerMark? _markFromString(String? value) {
    switch (value) {
      case 'x':
        return PlayerMark.x;
      case 'o':
        return PlayerMark.o;
      default:
        return null;
    }
  }

  GameStatus _statusFromString(String value) {
    switch (value) {
      case 'won':
        return GameStatus.won;
      case 'draw':
        return GameStatus.draw;
      case 'in_progress':
      default:
        return GameStatus.inProgress;
    }
  }

  String _statusToString(GameStatus status) {
    switch (status) {
      case GameStatus.won:
        return 'won';
      case GameStatus.draw:
        return 'draw';
      case GameStatus.inProgress:
      default:
        return 'in_progress';
    }
  }

  DateTime _readTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
  }
}