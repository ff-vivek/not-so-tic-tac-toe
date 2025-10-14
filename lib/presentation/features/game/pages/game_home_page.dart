import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/match_state.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/match_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_category.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/controllers/matchmaking_controller.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/controllers/remote_match_providers.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/game_status_banner.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/tic_tac_toe_board.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/modifier_category_reveal.dart';

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

            switch (matchmakingState.phase) {
              case MatchmakingPhase.searching:
                return const _SearchingView();
              case MatchmakingPhase.connecting:
                return _ConnectingView(
                  opponentMatchId: matchmakingState.assignedMatchId,
                );
              case MatchmakingPhase.error:
                return _ErrorView(message: matchmakingState.errorMessage);
              case MatchmakingPhase.matchReady:
              case MatchmakingPhase.idle:
                return const _IdleView();
            }
          },
          loading: () {
            switch (matchmakingState.phase) {
              case MatchmakingPhase.connecting:
                return _ConnectingView(
                  opponentMatchId: matchmakingState.assignedMatchId,
                );
              case MatchmakingPhase.searching:
                return const _SearchingView();
              case MatchmakingPhase.error:
              case MatchmakingPhase.matchReady:
              case MatchmakingPhase.idle:
                return const Center(child: CircularProgressIndicator());
            }
          },
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

class _ConnectingView extends StatelessWidget {
  const _ConnectingView({this.opponentMatchId});

  final String? opponentMatchId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                CircularProgressIndicator(strokeWidth: 6),
                Icon(Icons.groups_rounded, size: 28),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Opponent locked in!',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Setting the board - you'll be dropped into the match shortly.",
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (opponentMatchId != null) ...[
            const SizedBox(height: 12),
            Text(
              'Match ID ${opponentMatchId!}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Tooltip(
            message: 'Matches are already syncing, so cancelling now could orphan the lobby.',
            triggerMode: TooltipTriggerMode.tap,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.hourglass_bottom_rounded),
              label: const Text('Preparing match...'),
            ),
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

class _MatchView extends ConsumerStatefulWidget {
  const _MatchView({required this.match, required this.playerId});

  final MatchState match;
  final String playerId;

  @override
  ConsumerState<_MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends ConsumerState<_MatchView> {
  bool _categoryRevealComplete = true;
  String? _revealSignature;

  @override
  void initState() {
    super.initState();
    _resetRevealState();
  }

  @override
  void didUpdateWidget(covariant _MatchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetRevealState(forceSetState: true);
  }

  void _resetRevealState({bool forceSetState = false}) {
    final category = widget.match.modifierCategory;
    final signature =
        category == null ? null : '${widget.match.id}-${category.storageValue}';

    if (_revealSignature == signature) {
      return;
    }

    void updater() {
      _revealSignature = signature;
      _categoryRevealComplete = category == null;
    }

    if (forceSetState) {
      setState(updater);
    } else {
      updater();
    }
  }

  void _handleRevealComplete() {
    if (!_categoryRevealComplete) {
      setState(() {
        _categoryRevealComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchRepository = ref.read(matchRepositoryProvider);
    final playerMark = widget.match.markForPlayer(widget.playerId);
    final matchmakingController = ref.read(matchmakingControllerProvider.notifier);
    final isGameComplete = widget.match.game.status != GameStatus.inProgress;
    final ModifierCategory? modifierCategory = widget.match.modifierCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GameStatusBanner(
          gameState: widget.match.game,
          localPlayerMark: playerMark,
          activeModifierCategory:
              _categoryRevealComplete ? modifierCategory : null,
          activeModifierId: widget.match.modifierId,
          onLeave: isGameComplete
              ? null
              : () => _confirmLeaveMatch(
                    context,
                    matchmakingController,
                    widget.match.id,
                  ),
          onReturnToMenu: isGameComplete
              ? () => _leaveMatch(
                    context,
                    matchmakingController,
                    widget.match.id,
                  )
              : null,
          onPlayAgain: isGameComplete
              ? () => _playAgain(
                    context,
                    matchmakingController,
                    widget.match.id,
                  )
              : null,
        ),
        if (modifierCategory != null) ...[
          const SizedBox(height: 16),
          ModifierCategoryReveal(
            key: ValueKey(_revealSignature),
            category: modifierCategory,
            onRevealComplete: _handleRevealComplete,
          ),
        ],
        const SizedBox(height: 24),
        Expanded(
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: _categoryRevealComplete ? 1 : 0.15,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !_categoryRevealComplete,
                  child: TicTacToeBoard(
                    game: widget.match.game,
                    onCellSelected: (position) => _playMove(
                      context,
                      matchRepository,
                      widget.match.id,
                      widget.playerId,
                      position,
                    ),
                    localPlayerMark: playerMark,
                    canSelectCell: (position) {
                      if (!_categoryRevealComplete) return false;
                      return widget.match.canPlayerSelectCell(
                        widget.playerId,
                        position,
                      );
                    },
                    blockedPositions: widget.match.blockedPositions,
                    spinnerOptions: widget.match.spinnerOptions,
                    isSpinnerActive: _categoryRevealComplete &&
                        widget.match.modifierId == 'spinner' &&
                        widget.match.spinnerOptions.isNotEmpty &&
                        widget.match.game.status == GameStatus.inProgress,
                    isSpinnerTurnForLocalPlayer: _categoryRevealComplete &&
                        widget.match.modifierId == 'spinner' &&
                        widget.match.spinnerOptions.isNotEmpty &&
                        widget.match.isPlayerTurn(widget.playerId),
                  ),
                ),
              ),
              if (!_categoryRevealComplete)
                const Positioned.fill(child: _MatchIntroShield()),
            ],
          ),
        ),
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
    MatchmakingController controller,
    String matchId,
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
      await _leaveMatch(context, controller, matchId);
    }
  }

  Future<void> _leaveMatch(
    BuildContext context,
    MatchmakingController controller,
    String matchId,
  ) async {
    try {
      await controller.leaveMatch(matchId);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _playAgain(
    BuildContext context,
    MatchmakingController controller,
    String matchId,
  ) async {
    try {
      await controller.playAgain(matchId);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

class _MatchIntroShield extends StatelessWidget {
  const _MatchIntroShield();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Selecting game mode...',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hang tight while we lock in a twist for this round.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}