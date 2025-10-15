import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/match_state.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/ultimate_board_state.dart';
import 'package:not_so_tic_tac_toe_game/domain/exceptions/invalid_move_exception.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_category.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_algorithms.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/match_repository.dart';

class FirebaseMatchRepository implements MatchRepository {
  FirebaseMatchRepository(this._firestore) : _random = Random();

  final FirebaseFirestore _firestore;
  final Random _random;

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
    Map<String, dynamic>? analyticsEvent;

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
      final modifierId = data['modifierId'] as String?;
      final modifierState =
          (data['modifierState'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

      final activeMarkString = data['activeMark'] as String? ?? 'x';
      final startingMarkString = data['startingMark'] as String? ?? 'x';
      final winnerMarkString = data['winnerMark'] as String?;
      final lastMoveIndex = data['lastMoveIndex'] as int?;
      final existingOutcome = data['outcome'] as Map<String, dynamic>?;

      final boardRaw = (data['board'] as List<dynamic>? ?? List<dynamic>.filled(9, null))
          .cast<dynamic>()
          .toList(growable: false);

      final currentGame = TicTacToeGame.fromState(
        board: _decodeBoard(boardRaw),
        activePlayer: _markFromString(activeMarkString) ?? PlayerMark.x,
        status: currentStatus,
        winner: _markFromString(winnerMarkString),
        lastMove: lastMoveIndex == null ? null : BoardPosition.fromIndex(lastMoveIndex),
        startingPlayer: _markFromString(startingMarkString) ?? PlayerMark.x,
      );

      if (modifierId == 'ultimate') {
        final result = _processUltimateMove(
          matchId: matchId,
          data: data,
          modifierState: modifierState,
          position: position,
          playerXId: playerXId,
          playerOId: playerOId,
          metaGame: currentGame,
          existingOutcome: existingOutcome,
        );

        analyticsEvent = result.analyticsEvent;
        transaction.update(matchRef, result.updates);
        return;
      }

      final blockedSquaresSource = modifierState['blockedSquares'] ??
          (modifierState['handYoureDealt'] as Map<String, dynamic>?)?['blockedSquares'];
      final spinnerSource = modifierState['spinnerChoices'] ??
          (modifierState['forcedMoves'] as Map<String, dynamic>?)?['spinnerChoices'];

      final blockedSquareIndices = _readIntList(blockedSquaresSource);
      final spinnerChoiceIndices = _readIntList(spinnerSource);

      if (blockedSquareIndices.contains(position.index)) {
        throw InvalidMoveException('That square is locked by the modifier.');
      }

      if (!currentGame.canPlayAt(position)) {
        throw InvalidMoveException('Selected cell is not available');
      }

      if (modifierId == 'spinner' &&
          spinnerChoiceIndices.isNotEmpty &&
          !spinnerChoiceIndices.contains(position.index)) {
        throw InvalidMoveException('Select one of the spinner-highlighted squares.');
      }

      final isGravityWell = modifierId == 'gravity_well';

      final gravityResult = isGravityWell
          ? _applyGravityWellMove(
              currentGame: currentGame,
              selectedPosition: position,
            )
          : null;

      final TicTacToeGame updatedGame = gravityResult?.updatedGame ?? currentGame.playMove(position);
      final BoardPosition effectivePosition =
          gravityResult?.finalPosition ?? position;

      final nextActivePlayerId = updatedGame.status == GameStatus.inProgress
          ? (updatedGame.activePlayer == PlayerMark.x ? playerXId : playerOId)
          : null;
      final winnerPlayerId = updatedGame.winner == null
          ? null
          : (updatedGame.winner == PlayerMark.x ? playerXId : playerOId);

      final updates = <String, dynamic>{
        'board': _encodeBoard(updatedGame.board),
        'activeMark': updatedGame.activePlayer.name,
        'activePlayerId': nextActivePlayerId,
        'status': _statusToString(updatedGame.status),
        'winnerMark': updatedGame.winner?.name,
        'winnerPlayerId': winnerPlayerId,
        'lastMoveIndex': effectivePosition.index,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isGravityWell) {
        updates['modifierState.gravityWell.lastDropPath'] =
            gravityResult?.dropPath ?? const <int>[];
      }

      if (updatedGame.status != GameStatus.inProgress && existingOutcome == null) {
        final outcomePayload = <String, dynamic>{
          'status': _statusToString(updatedGame.status),
          'winnerPlayerId': winnerPlayerId,
          'winnerMark': updatedGame.winner?.name,
          'completedBy': 'board',
        };

        updates.addAll({
          'completedAt': FieldValue.serverTimestamp(),
          'outcome': outcomePayload,
          'ratingDelta': _ratingDeltaStub(
            playerXId: playerXId,
            playerOId: playerOId,
            winnerPlayerId: winnerPlayerId,
            status: updatedGame.status,
            endedByForfeit: false,
          ),
        });

        analyticsEvent = {
          'type': 'match_completed',
          'matchId': matchId,
          'trigger': 'board',
          'status': outcomePayload['status'],
          'winnerPlayerId': winnerPlayerId,
          'participantIds': [playerXId, playerOId],
          'ratingDelta': updates['ratingDelta'],
        };
      }

      if (modifierId == 'spinner') {
        final nextChoices = updatedGame.status == GameStatus.inProgress
            ? generateSpinnerChoices(random: _random, board: updatedGame.board)
            : const <int>[];
        updates['modifierState.spinnerChoices'] = nextChoices;
      }

      transaction.update(matchRef, updates);
    });

    if (analyticsEvent != null) {
      await _logAnalyticsEvent(matchId, analyticsEvent!);
    }
  }

  @override
  Future<void> leaveMatch({
    required String matchId,
    required String playerId,
  }) async {
    final matchRef = _matchesCollection.doc(matchId);
    Map<String, dynamic>? analyticsEvent;

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
      final statusString = (data['status'] as String?) ?? 'in_progress';
      final currentStatus = _statusFromString(statusString);
      final existingOutcome = data['outcome'] as Map<String, dynamic>?;

      final playerXId = data['playerXId'] as String;
      final playerOId = data['playerOId'] as String;
      final opponentId = playerId == playerXId ? playerOId : playerXId;

      final updates = <String, dynamic>{
        'playerStates.$playerId': 'done',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (currentStatus == GameStatus.inProgress) {
        final winningMark = playerId == playerXId ? 'o' : 'x';
        final outcomePayload = <String, dynamic>{
          'status': 'won',
          'winnerPlayerId': opponentId,
          'winnerMark': winningMark,
          'completedBy': 'forfeit',
          'forfeitBy': playerId,
        };

        updates.addAll({
          'status': 'won',
          'winnerMark': winningMark,
          'winnerPlayerId': opponentId,
          'completedAt': FieldValue.serverTimestamp(),
          'outcome': outcomePayload,
          'ratingDelta': _ratingDeltaStub(
            playerXId: playerXId,
            playerOId: playerOId,
            winnerPlayerId: opponentId,
            status: GameStatus.won,
            endedByForfeit: true,
          ),
        });

        analyticsEvent = {
          'type': 'match_completed',
          'matchId': matchId,
          'trigger': 'forfeit',
          'status': 'won',
          'winnerPlayerId': opponentId,
          'forfeitBy': playerId,
          'participantIds': [playerXId, playerOId],
          'ratingDelta': updates['ratingDelta'],
        };
      } else if (existingOutcome == null) {
        final winnerPlayerId = data['winnerPlayerId'] as String?;
        final winnerMark = data['winnerMark'] as String?;
        final derivedStatus = _statusFromString(statusString);

        final outcomePayload = <String, dynamic>{
          'status': _statusToString(derivedStatus),
          'winnerPlayerId': winnerPlayerId,
          'winnerMark': winnerMark,
          'completedBy': 'manual_leave',
        };

        updates.addAll({
          if (data['completedAt'] == null) 'completedAt': FieldValue.serverTimestamp(),
          'outcome': outcomePayload,
          'ratingDelta': _ratingDeltaStub(
            playerXId: playerXId,
            playerOId: playerOId,
            winnerPlayerId: winnerPlayerId,
            status: derivedStatus,
            endedByForfeit: false,
          ),
        });

        analyticsEvent = {
          'type': 'match_completed',
          'matchId': matchId,
          'trigger': 'manual_leave',
          'status': outcomePayload['status'],
          'winnerPlayerId': winnerPlayerId,
          'participantIds': [playerXId, playerOId],
          'ratingDelta': updates['ratingDelta'],
        };
      }

      final remainingActive = playerStates.values
          .whereType<String>()
          .where((value) => value != 'done')
          .isNotEmpty;

      if (!remainingActive) {
        updates.addAll({
          'archived': true,
          'archivedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.update(matchRef, updates);
    });

    if (analyticsEvent != null) {
      await _logAnalyticsEvent(matchId, analyticsEvent!);
    }
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
    final modifierCategory = ModifierCategory.fromStorage(
      data['modifierCategory'] as String?,
    );
    final modifierId = data['modifierId'] as String?;
    final modifierState =
        (data['modifierState'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

    final blockedSquaresSource = modifierState['blockedSquares'] ??
        (modifierState['handYoureDealt'] as Map<String, dynamic>?)?
            ['blockedSquares'];
    final blockedSquares = _readIntList(blockedSquaresSource)
        .map(BoardPosition.fromIndex)
        .toSet();

    final spinnerSource = modifierState['spinnerChoices'] ??
        (modifierState['forcedMoves'] as Map<String, dynamic>?)?
            ['spinnerChoices'];
    final spinnerChoices = _readIntList(spinnerSource)
        .map(BoardPosition.fromIndex)
        .toList();
    spinnerChoices.sort((a, b) => a.index.compareTo(b.index));

    final gravityWellState = modifierState['gravityWell'] as Map<String, dynamic>?;
    final gravityPath = _readIntList(gravityWellState?['lastDropPath'])
        .map(BoardPosition.fromIndex)
        .toList(growable: false);

    final ultimateStateRaw = modifierState['ultimate'] as Map<String, dynamic>?;
    final ultimateState =
        ultimateStateRaw == null ? null : UltimateBoardState.fromMap(ultimateStateRaw);

    final game = TicTacToeGame.fromState(
      board: _decodeBoard(boardRaw),
      activePlayer: _markFromString(activeMarkString) ?? PlayerMark.x,
      status: _statusFromString(statusString),
      winner: _markFromString(winnerMarkString),
      lastMove: lastMoveIndex == null
          ? null
          : BoardPosition.fromIndex(lastMoveIndex),
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
      modifierCategory: modifierCategory,
      modifierId: modifierId,
      blockedPositions: blockedSquares,
      spinnerOptions: spinnerChoices,
      gravityDropPath: gravityPath,
      ultimateState: ultimateState,
    );
  }

  ({
    TicTacToeGame updatedGame,
    BoardPosition finalPosition,
    List<int> dropPath,
  }) _applyGravityWellMove({
    required TicTacToeGame currentGame,
    required BoardPosition selectedPosition,
  }) {
    const dimension = 3;
    final col = selectedPosition.col;
    final board = currentGame.board;

    var finalRow = selectedPosition.row;
    for (var row = dimension - 1; row >= 0; row--) {
      final idx = row * dimension + col;
      if (board[idx] == null) {
        finalRow = row;
        break;
      }
    }

    final finalPosition = BoardPosition(row: finalRow, col: col, dimension: dimension);

    if (!currentGame.canPlayAt(finalPosition)) {
      throw InvalidMoveException('That column is full. Choose another.');
    }

    final path = <int>[];
    if (finalRow >= selectedPosition.row) {
      for (var row = selectedPosition.row; row <= finalRow; row++) {
        path.add(BoardPosition(row: row, col: col, dimension: dimension).index);
      }
    } else {
      for (var row = selectedPosition.row; row >= finalRow; row--) {
        path.add(BoardPosition(row: row, col: col, dimension: dimension).index);
      }
    }

    final updatedGame = currentGame.playMove(finalPosition);

    return (
      updatedGame: updatedGame,
      finalPosition: finalPosition,
      dropPath: path,
    );
  }

  ({
    Map<String, dynamic> updates,
    Map<String, dynamic>? analyticsEvent,
  }) _processUltimateMove({
    required String matchId,
    required Map<String, dynamic> data,
    required Map<String, dynamic> modifierState,
    required BoardPosition position,
    required String playerXId,
    required String playerOId,
    required TicTacToeGame metaGame,
    required Map<String, dynamic>? existingOutcome,
  }) {
    if (position.dimension != 9) {
      throw InvalidMoveException('Ultimate mode moves must use the 9x9 grid.');
    }

    final rawUltimate = modifierState['ultimate'] as Map<String, dynamic>?;
    if (rawUltimate == null) {
      throw StateError('Ultimate mode state is unavailable for this match.');
    }

    final ultimateState = UltimateBoardState.fromMap(
      Map<String, dynamic>.from(rawUltimate),
    );

    final breakdown = ultimateState.resolveAbsolute(position);

    if (ultimateState.activeBoardIndex != null &&
        ultimateState.activeBoardIndex != breakdown.miniIndex) {
      throw InvalidMoveException('You must play in the highlighted mini-board.');
    }

    final miniBoard = ultimateState.boardAt(breakdown.miniIndex);
    if (!miniBoard.isPlayable) {
      throw InvalidMoveException('That mini-board has already been resolved.');
    }

    if (miniBoard.cells[breakdown.cellIndex] != null) {
      throw InvalidMoveException('That square is already occupied.');
    }

    final miniBoards = ultimateState.miniBoards.toList(growable: true);

    final miniGameBefore = TicTacToeGame.fromState(
      board: List<PlayerMark?>.from(miniBoard.cells),
      activePlayer: metaGame.activePlayer,
      status: GameStatus.inProgress,
      winner: miniBoard.winner,
      lastMove: null,
      startingPlayer: metaGame.startingPlayer,
    );

    final localPosition = BoardPosition(
      row: breakdown.cellRow,
      col: breakdown.cellCol,
    );

    final miniGameAfter = miniGameBefore.playMove(localPosition);

    final updatedMiniBoard = UltimateMiniBoard(
      index: miniBoard.index,
      cells: miniGameAfter.board,
      status: miniGameAfter.status,
      winner: miniGameAfter.winner,
    );

    miniBoards[miniBoard.index] = updatedMiniBoard;

    final metaBoard = List<PlayerMark?>.from(metaGame.board);
    if (miniGameAfter.status == GameStatus.won) {
      metaBoard[breakdown.miniIndex] = miniGameAfter.winner;
    } else if (miniGameAfter.status == GameStatus.draw) {
      metaBoard[breakdown.miniIndex] = null;
    }

    final metaWinner = _detectWinner(metaBoard);
    final hasPlayableBoards = miniBoards.any(
      (board) => board.isPlayable && board.openCellIndices.isNotEmpty,
    );

    final matchStatus = metaWinner != null
        ? GameStatus.won
        : hasPlayableBoards
            ? GameStatus.inProgress
            : GameStatus.draw;

    final winnerPlayerId = metaWinner == null
        ? null
        : (metaWinner == PlayerMark.x ? playerXId : playerOId);

    final nextActiveMark = matchStatus == GameStatus.inProgress
        ? metaGame.activePlayer.opponent
        : metaGame.activePlayer;
    final nextActivePlayerId = matchStatus == GameStatus.inProgress
        ? (nextActiveMark == PlayerMark.x ? playerXId : playerOId)
        : null;

    int? nextBoardIndex = breakdown.cellIndex;
    if (matchStatus != GameStatus.inProgress) {
      nextBoardIndex = null;
    } else {
      final candidateBoard = miniBoards[nextBoardIndex];
      if (!candidateBoard.isPlayable || candidateBoard.openCellIndices.isEmpty) {
        nextBoardIndex = null;
      }
    }

    final updatedUltimateState = UltimateBoardState(
      miniBoards: miniBoards,
      activeBoardIndex: nextBoardIndex,
      lastMove: BoardPosition(
        row: position.row,
        col: position.col,
        dimension: position.dimension,
      ),
    );

    final updates = <String, dynamic>{
      'board': _encodeBoard(metaBoard),
      'activeMark': nextActiveMark.name,
      'activePlayerId': nextActivePlayerId,
      'status': _statusToString(matchStatus),
      'winnerMark': metaWinner?.name,
      'winnerPlayerId': winnerPlayerId,
      'lastMoveIndex': null,
      'updatedAt': FieldValue.serverTimestamp(),
      'modifierState.ultimate': updatedUltimateState.toMap(),
    };

    Map<String, dynamic>? analytics;

    if (matchStatus != GameStatus.inProgress && existingOutcome == null) {
      final outcomePayload = <String, dynamic>{
        'status': _statusToString(matchStatus),
        'winnerPlayerId': winnerPlayerId,
        'winnerMark': metaWinner?.name,
        'completedBy': 'ultimate',
      };

      updates.addAll({
        'completedAt': FieldValue.serverTimestamp(),
        'outcome': outcomePayload,
        'ratingDelta': _ratingDeltaStub(
          playerXId: playerXId,
          playerOId: playerOId,
          winnerPlayerId: winnerPlayerId,
          status: matchStatus,
          endedByForfeit: false,
        ),
      });

      analytics = {
        'type': 'match_completed',
        'matchId': matchId,
        'trigger': 'ultimate',
        'status': outcomePayload['status'],
        'winnerPlayerId': winnerPlayerId,
        'participantIds': [playerXId, playerOId],
        'ratingDelta': updates['ratingDelta'],
      };
    }

    return (updates: updates, analyticsEvent: analytics);
  }

  PlayerMark? _detectWinner(List<PlayerMark?> board) {
    const winningLines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final line in winningLines) {
      final a = board[line[0]];
      final b = board[line[1]];
      final c = board[line[2]];
      if (a != null && a == b && a == c) {
        return a;
      }
    }

    return null;
  }

  List<int> _readIntList(dynamic value) {
    if (value is List) {
      return value
          .map((element) => element is int ? element : (element as num).toInt())
          .toList(growable: false);
    }
    return const [];
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

  Future<void> _logAnalyticsEvent(
    String matchId,
    Map<String, dynamic> payload,
  ) async {
    final eventRef = _matchesCollection.doc(matchId).collection('events').doc();
    await eventRef.set({
      ...payload,
      'recordedAt': FieldValue.serverTimestamp(),
    });
  }

  Map<String, int> _ratingDeltaStub({
    required String playerXId,
    required String playerOId,
    required String? winnerPlayerId,
    required GameStatus status,
    required bool endedByForfeit,
  }) {
    if (status == GameStatus.draw || winnerPlayerId == null) {
      return {
        playerXId: 0,
        playerOId: 0,
      };
    }

    final loserPlayerId = winnerPlayerId == playerXId ? playerOId : playerXId;
    final winnerDelta = endedByForfeit ? 12 : 8;
    final loserDelta = -winnerDelta;

    return {
      winnerPlayerId: winnerDelta,
      loserPlayerId: loserDelta,
    };
  }
}