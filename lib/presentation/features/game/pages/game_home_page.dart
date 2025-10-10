import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/match_state.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/match_repository.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/controllers/matchmaking_controller.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/controllers/remote_match_providers.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/game_status_banner.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/tic_tac_toe_board.dart';

class GameHomePage extends ConsumerWidget {
  const GameHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchmakingState = ref.watch(matchmakingControllerProvider);
    final activeMatch = ref.watch(activeMatchProvider);
    final playerId = ref.watch(playerIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gridlock X & O Evolved'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: activeMatch.when(
          data: (match) {
            if (match != null) {
              return _MatchView(
                match: match,
                playerId: playerId,
              );
            }

            if (matchmakingState.phase == MatchmakingPhase.searching) {
              return const _SearchingView();
            }

            if (matchmakingState.phase == MatchmakingPhase.error) {
              return _ErrorView(message: matchmakingState.errorMessage);
            }

            return const _IdleView();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(message: error.toString()),
        ),
      ),
    );
  }
}

class _IdleView extends ConsumerWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(matchmakingControllerProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ready to Gridlock?',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tap play and we’ll find an opponent instantly.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: controller.startSearch,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Play'),
          ),
        ],
      ),
    );
  }
}

class _SearchingView extends ConsumerWidget {
  const _SearchingView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(matchmakingControllerProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Searching for an opponent...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: controller.cancelSearch,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(matchmakingControllerProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'Something went wrong.',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: controller.startSearch,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _MatchView extends ConsumerWidget {
  const _MatchView({required this.match, required this.playerId});

  final MatchState match;
  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchRepository = ref.read(matchRepositoryProvider);
    final playerMark = match.markForPlayer(playerId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GameStatusBanner(
          gameState: match.game,
          localPlayerMark: playerMark,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: TicTacToeBoard(
            game: match.game,
            onCellSelected: (position) => _playMove(
              context,
              matchRepository,
              match.id,
              playerId,
              position,
            ),
            canSelectCell: (position) {
              if (!match.isPlayerTurn(playerId)) return false;
              return match.game.canPlayAt(position);
            },
          ),
        ),
        const SizedBox(height: 24),
        if (match.game.status == GameStatus.inProgress)
          OutlinedButton(
            onPressed: () => _confirmLeaveMatch(
              context,
              matchRepository,
              match.id,
              playerId,
            ),
            child: const Text('Leave Match'),
          )
        else ...[
          FilledButton(
            onPressed: () => _finishMatch(context, matchRepository, match.id, playerId),
            child: const Text('Return to Menu'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              await _finishMatch(context, matchRepository, match.id, playerId);
              await ref.read(matchmakingControllerProvider.notifier).startSearch();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Play Again'),
          ),
        ],
      ],
    );
  }

  Future<void> _playMove(
    BuildContext context,
    MatchRepository repository,
    String matchId,
    String playerId,
    BoardPosition position,
  ) async {
    try {
      await repository.submitMove(
        matchId: matchId,
        playerId: playerId,
        position: position,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _confirmLeaveMatch(
    BuildContext context,
    MatchRepository repository,
    String matchId,
    String playerId,
  ) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave Match?'),
          content: const Text(
            'Leaving early counts as a forfeit. Are you sure you want to exit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    if (shouldLeave == true) {
      await _finishMatch(context, repository, matchId, playerId);
    }
  }

  Future<void> _finishMatch(
    BuildContext context,
    MatchRepository repository,
    String matchId,
    String playerId,
  ) async {
    try {
      await repository.leaveMatch(matchId: matchId, playerId: playerId);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}