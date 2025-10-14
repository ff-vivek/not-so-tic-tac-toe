import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/matchmaking_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/value_objects/match_join_result.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/controllers/remote_match_providers.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/match_state.dart';

enum MatchmakingPhase { idle, searching, connecting, matchReady, error }

class MatchmakingState {
  const MatchmakingState({
    required this.phase,
    this.assignedMatchId,
    this.errorMessage,
  });

  const MatchmakingState.idle() : this(phase: MatchmakingPhase.idle);

  const MatchmakingState.searching()
      : this(phase: MatchmakingPhase.searching);

  const MatchmakingState.connecting(String matchId)
      : this(
          phase: MatchmakingPhase.connecting,
          assignedMatchId: matchId,
        );

  final MatchmakingPhase phase;
  final String? assignedMatchId;
  final String? errorMessage;

  MatchmakingState copyWith({
    MatchmakingPhase? phase,
    Object? assignedMatchId = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return MatchmakingState(
      phase: phase ?? this.phase,
      assignedMatchId: identical(assignedMatchId, _sentinel)
          ? this.assignedMatchId
          : assignedMatchId as String?,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();
}

class MatchmakingController extends Notifier<MatchmakingState> {
  MatchmakingRepository get _repository =>
      ref.read(matchmakingRepositoryProvider);

  String get _playerId => ref.read(playerIdProvider);

  int _operationToken = 0;

  @override
  MatchmakingState build() {
    ref.listen<AsyncValue<MatchState?>>(
      activeMatchProvider,
      (_, next) {
        next.whenData((match) {
          if (match != null) {
            state = state.copyWith(
              phase: MatchmakingPhase.matchReady,
              assignedMatchId: match.id,
              errorMessage: null,
            );
          } else if (state.phase == MatchmakingPhase.matchReady) {
            state = const MatchmakingState.idle();
          }
        });
      },
    );

    ref.onDispose(() {
      if (state.phase == MatchmakingPhase.searching) {
        unawaited(_repository.leaveQueue(_playerId));
      }
    });

    return const MatchmakingState.idle();
  }

  Future<void> startSearch() async {
    if (state.phase == MatchmakingPhase.searching ||
        state.phase == MatchmakingPhase.connecting) {
      return;
    }

    final currentToken = ++_operationToken;
    state = const MatchmakingState.searching();

    try {
      final result = await _repository.joinQueue(_playerId);
      if (currentToken != _operationToken) return;

      switch (result.status) {
        case MatchJoinStatus.waiting:
          state = const MatchmakingState.searching();
          break;
        case MatchJoinStatus.matchReady:
        case MatchJoinStatus.alreadyInMatch:
          final matchId = result.matchId;
          if (matchId != null) {
            state = MatchmakingState.connecting(matchId);
          }
          break;
      }
    } catch (error) {
      if (currentToken != _operationToken) return;
      state = MatchmakingState(
        phase: MatchmakingPhase.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> cancelSearch() async {
    if (state.phase != MatchmakingPhase.searching) return;

    final currentToken = ++_operationToken;
    state = const MatchmakingState.idle();

    try {
      await _repository.leaveQueue(_playerId);
    } finally {
      if (currentToken == _operationToken) {
        state = const MatchmakingState.idle();
      }
    }
  }

  Future<void> leaveMatch(String matchId) async {
    final matchRepository = ref.read(matchRepositoryProvider);

    final currentToken = ++_operationToken;
    await matchRepository.leaveMatch(
      matchId: matchId,
      playerId: _playerId,
    );

    ref.invalidate(activeMatchProvider);
    if (currentToken == _operationToken) {
      state = const MatchmakingState.idle();
    }
  }

  Future<void> playAgain(String matchId) async {
    await leaveMatch(matchId);
    await startSearch();
  }
}

final matchmakingControllerProvider =
    NotifierProvider<MatchmakingController, MatchmakingState>(
  MatchmakingController.new,
);