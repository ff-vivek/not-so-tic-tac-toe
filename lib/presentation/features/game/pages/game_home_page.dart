import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/match_state.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/repositories/match_repository.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_category.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/controllers/match_highlight_controller.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/auth/account_sheet.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/controllers/matchmaking_controller.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/controllers/offline_match_controller.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/controllers/remote_match_providers.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/game_status_banner.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/tic_tac_toe_board.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/ultimate_mode_board.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/game/widgets/modifier_category_reveal.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/player/controllers/player_profile_providers.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/player/widgets/player_streak_badge.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/highlights/highlight_share_target.dart';

class GameHomePage extends ConsumerWidget {
  const GameHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchmakingState = ref.watch(matchmakingControllerProvider);
    final activeMatch = ref.watch(activeMatchProvider);
    final playerId = ref.watch(playerIdProvider);
    final offlineMatch = ref.watch(offlineMatchControllerProvider);

    final ({Widget child, Object viewKey}) cardContent = _resolveCardContent(
      context,
      playerId: playerId,
      offlineMatch: offlineMatch,
      activeMatch: activeMatch,
      matchmakingState: matchmakingState,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0F1F), Color(0xFF1A1440)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              child: _AuroraGlow(
                diameter: MediaQuery.of(context).size.width * 0.9,
                colors: const [Color(0xFF1F8AFF), Color(0xFF7F5BFF)],
              ),
            ),
            Positioned(
              bottom: -160,
              right: -100,
              child: _AuroraGlow(
                diameter: MediaQuery.of(context).size.width * 0.8,
                colors: const [Color(0xFF2FFFD2), Color(0xFFA855F7)],
                opacity: 0.45,
              ),
            ),
            _NoiseOverlay(
              opacity: 0.08,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GameHeader(
                      matchmakingState: matchmakingState,
                      onSettingsTap: () => _showAccountSheet(context),
                      onHistoryTap: () => _showComingSoon(context, 'Match history'),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double panelWidth =
                              constraints.maxWidth.clamp(360.0, 980.0) as double;

                          return Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: panelWidth),
                              child: _GlassPanel(
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOutCubic,
                                  alignment: Alignment.topCenter,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 350),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    child: KeyedSubtree(
                                      key: ValueKey(cardContent.viewKey),
                                      child: cardContent.child,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _FooterFlare(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Widget child, Object viewKey}) _resolveCardContent(
    BuildContext context, {
    required String playerId,
    required OfflineMatchState? offlineMatch,
    required AsyncValue<MatchState?> activeMatch,
    required MatchmakingState matchmakingState,
  }) {
    if (offlineMatch != null) {
      return (
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
          child: _OfflineMatchView(state: offlineMatch),
        ),
        viewKey: 'offline',
      );
    }

    return activeMatch.when<({Widget child, Object viewKey})>(
      data: (match) {
        if (match != null) {
          return (
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
              child: _MatchView(
                match: match,
                playerId: playerId,
              ),
            ),
            viewKey: 'match-${match.id}',
          );
        }

        final phase = matchmakingState.phase;
        final Widget stateView;
        switch (phase) {
          case MatchmakingPhase.searching:
            stateView = const _SearchingView();
            break;
          case MatchmakingPhase.connecting:
            stateView = _ConnectingView(
              opponentMatchId: matchmakingState.assignedMatchId,
            );
            break;
          case MatchmakingPhase.error:
            stateView = _ErrorView(message: matchmakingState.errorMessage);
            break;
          case MatchmakingPhase.matchReady:
          case MatchmakingPhase.idle:
            stateView = const _IdleView();
            break;
        }

        return (
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
            child: stateView,
          ),
          viewKey: 'phase-${phase.name}',
        );
      },
      loading: () {
        final phase = matchmakingState.phase;
        Widget loadingView;
        switch (phase) {
          case MatchmakingPhase.connecting:
            loadingView = _ConnectingView(
              opponentMatchId: matchmakingState.assignedMatchId,
            );
            break;
          case MatchmakingPhase.searching:
            loadingView = const _SearchingView();
            break;
          case MatchmakingPhase.error:
          case MatchmakingPhase.matchReady:
          case MatchmakingPhase.idle:
            loadingView = const Center(child: CircularProgressIndicator());
            break;
        }

        return (
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
            child: loadingView,
          ),
          viewKey: 'loading-${phase.name}',
        );
      },
      error: (error, _) => (
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
          child: _ErrorView(message: error.toString()),
        ),
        viewKey: 'error-${error.hashCode}',
      ),
    );
  }

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName is coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showAccountSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: false,
      builder: (context) => const AccountSheet(),
    );
  }
}

class _IdleView extends ConsumerWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(matchmakingControllerProvider.notifier);
    final offlineController = ref.read(offlineMatchControllerProvider.notifier);
    final profileAsync = ref.watch(playerProfileProvider);

    Widget? streakBadge;
    profileAsync.when(
      data: (profile) {
        streakBadge = PlayerStreakBadge(
          profile: profile,
          showMaxLabel: true,
        );
      },
      loading: () {
        streakBadge = const SizedBox(
          height: 64,
          child: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, _) {
        streakBadge = Tooltip(
          message: 'Unable to load streak data: $error',
          child: const Icon(Icons.local_fire_department_outlined),
        );
      },
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (streakBadge != null) ...[
            streakBadge!,
            const SizedBox(height: 24),
          ],
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
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => offlineController.startNewMatch(),
            icon: const Icon(Icons.sports_esports_rounded),
            label: const Text('Local Versus'),
          ),
          const SizedBox(height: 8),
          Text(
            'Two players, one device. Take turns placing marks offline.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
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

class _OfflineMatchView extends ConsumerWidget {
  const _OfflineMatchView({required this.state});

  final OfflineMatchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(offlineMatchControllerProvider.notifier);
    final onExit = controller.exitToMenu;
    final onRematch = controller.rematch;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OfflineStatusBanner(
          state: state,
          onExit: onExit,
          onRematch: onRematch,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: TicTacToeBoard(
            game: state.game,
            onCellSelected: (position) => controller.playMove(position),
            canSelectCell: (position) => state.game.canPlayAt(position),
            localPlayerMark: null,
          ),
        ),
      ],
    );
  }
}

class _OfflineStatusBanner extends StatelessWidget {
  const _OfflineStatusBanner({
    required this.state,
    required this.onExit,
    required this.onRematch,
  });

  final OfflineMatchState state;
  final VoidCallback onExit;
  final VoidCallback onRematch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = state.game;

    final _BannerDetails details = _resolveDetails(theme);

    final actions = <Widget>[
      OutlinedButton.icon(
        onPressed: onExit,
        icon: const Icon(Icons.home_rounded),
        label: const Text('Return to Menu'),
      ),
    ];

    if (game.status != GameStatus.inProgress) {
      actions.insert(
        0,
        FilledButton.icon(
          onPressed: onRematch,
          icon: const Icon(Icons.refresh_rounded),
          label: Text('Rematch (${_playerLabel(state.nextStartingPlayer)} starts)'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: details.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: details.accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(details.icon, color: details.accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: details.accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: details.accentColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Chip(
                backgroundColor: details.accentColor.withOpacity(0.12),
                label: Text(
                  'Round ${state.round}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: details.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: actions,
          ),
        ],
      ),
    );
  }

  _BannerDetails _resolveDetails(ThemeData theme) {
    final game = state.game;

    switch (game.status) {
      case GameStatus.inProgress:
        final activeLabel = _playerLabel(game.activePlayer);
        return _BannerDetails(
          title: "$activeLabel's turn",
          subtitle: 'Hand off the device and tap an open square to continue the duel.',
          icon: Icons.sports_esports_rounded,
          accentColor: theme.colorScheme.primary,
        );
      case GameStatus.won:
        final winner = game.winner;
        final winnerLabel = _playerLabel(winner!);
        final nextLabel = _playerLabel(state.nextStartingPlayer);
        return _BannerDetails(
          title: '$winnerLabel wins!',
          subtitle: 'Rematch ready - $nextLabel kicks off the next round.',
          icon: Icons.emoji_events_rounded,
          accentColor: theme.colorScheme.secondary,
        );
      case GameStatus.draw:
        final nextLabel = _playerLabel(state.nextStartingPlayer);
        return _BannerDetails(
          title: 'Round ends in a draw',
          subtitle: 'Rematch ready - $nextLabel opens the next round.',
          icon: Icons.handshake_rounded,
          accentColor: theme.colorScheme.tertiary,
        );
    }
  }

  static String _playerLabel(PlayerMark mark) {
    return mark == PlayerMark.x ? 'Player X' : 'Player O';
  }
}

class _BannerDetails {
  const _BannerDetails({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
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
  late GlobalKey _boardCaptureKey;
  ProviderSubscription<MatchHighlightState>? _highlightSubscription;

  @override
  void initState() {
    super.initState();
    _boardCaptureKey = GlobalKey(debugLabel: 'match-board-${widget.match.id}');
    _resetRevealState();
    _setupHighlightBindings();
  }

  @override
  void didUpdateWidget(covariant _MatchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetRevealState(forceSetState: true);

    if (oldWidget.match.id != widget.match.id) {
      final oldController =
          ref.read(matchHighlightControllerProvider(oldWidget.match.id).notifier);
      oldController.detachBoundary(_boardCaptureKey);

      setState(() {
        _boardCaptureKey = GlobalKey(debugLabel: 'match-board-${widget.match.id}');
      });

      _setupHighlightBindings();
    }
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
  void dispose() {
    ref.read(matchHighlightControllerProvider(widget.match.id).notifier)
        .detachBoundary(_boardCaptureKey);
    final subscription = _highlightSubscription;
    if (subscription != null) {
      // ignore: discarded_futures
      subscription.close();
      _highlightSubscription = null;
    }
    super.dispose();
  }

  void _setupHighlightBindings() {
    final subscription = _highlightSubscription;
    if (subscription != null) {
      // ignore: discarded_futures
      subscription.close();
      _highlightSubscription = null;
    }
    _highlightSubscription = ref.listenManual<MatchHighlightState>(
      matchHighlightControllerProvider(widget.match.id),
      (previous, next) {
        if (previous?.shareEventId == next.shareEventId) {
          return;
        }

        if (!mounted) return;

        if (next.shareState.isLoading) {
          return;
        }

        if (next.shareState.hasError) {
          final Object error = next.shareState.error ?? 'Unknown error';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Highlight share failed: $error')),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Highlight exported. Check the share sheet!')),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(matchHighlightControllerProvider(widget.match.id).notifier)
          .attachBoundary(_boardCaptureKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchRepository = ref.read(matchRepositoryProvider);
    final playerMark = widget.match.markForPlayer(widget.playerId);
    final matchmakingController = ref.read(matchmakingControllerProvider.notifier);
    final isGameComplete = widget.match.game.status != GameStatus.inProgress;
    final highlightState = ref.watch(matchHighlightControllerProvider(widget.match.id));
    final highlightController =
        ref.read(matchHighlightControllerProvider(widget.match.id).notifier);
    final ModifierCategory? modifierCategory = widget.match.modifierCategory;
    final ultimateState = widget.match.ultimateState;
    final playerProfileAsync = ref.watch(playerProfileProvider);

    Widget? streakBadge;
    playerProfileAsync.when(
      data: (profile) {
        streakBadge = Align(
          alignment: Alignment.centerRight,
          child: PlayerStreakBadge(
            profile: profile,
            dense: true,
          ),
        );
      },
      loading: () {
        streakBadge = const Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );
      },
      error: (error, _) {
        streakBadge = Align(
          alignment: Alignment.centerRight,
          child: Tooltip(
            message: 'Streak unavailable: $error',
            child: const Icon(Icons.local_fire_department_outlined),
          ),
        );
      },
    );

    Widget boardWidget;
    if (widget.match.isUltimateModeMatch && ultimateState != null) {
      boardWidget = UltimateModeBoard(
        state: ultimateState,
        matchStatus: widget.match.status,
        localPlayerMark: playerMark,
        lastMove: ultimateState.lastMove,
        onCellSelected: (position) => _playMove(
          context,
          matchRepository,
          widget.match.id,
          widget.playerId,
          position,
        ),
        canSelectCell: (position) {
          if (!_categoryRevealComplete) return false;
          return widget.match.canPlayerSelectUltimateCell(
            widget.playerId,
            position,
          );
        },
      );
    } else if (widget.match.isUltimateModeMatch && ultimateState == null) {
      boardWidget = const Center(child: CircularProgressIndicator());
    } else {
      boardWidget = TicTacToeBoard(
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
        gravityDropPath: widget.match.gravityDropPath,
      );
    }

    final List<Widget> postGameActions = <Widget>[];
    if (isGameComplete) {
      final String tooltipMessage = highlightState.shareState.isLoading
          ? 'Rendering your highlight...'
          : highlightState.hasFrames
              ? 'Share the last 10 seconds of gameplay.'
              : 'The recorder needs a few moves before a highlight is ready.';
      postGameActions.add(
        Tooltip(
          message: tooltipMessage,
          child: _HighlightShareButton(
            onPressed: highlightState.hasFrames && !highlightState.shareState.isLoading
                ? () => _showShareOptions(highlightController)
                : null,
            isBusy: highlightState.shareState.isLoading,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (streakBadge != null) ...[
          streakBadge!,
          const SizedBox(height: 12),
        ],
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
          postGameActions: postGameActions,
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
          child: RepaintBoundary(
            key: _boardCaptureKey,
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: _categoryRevealComplete ? 1 : 0.15,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_categoryRevealComplete,
                    child: boardWidget,
                  ),
                ),
                if (!_categoryRevealComplete)
                  const Positioned.fill(child: _MatchIntroShield()),
              ],
            ),
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

  Future<void> _showShareOptions(MatchHighlightController controller) async {
    if (!mounted) return;
    final HighlightShareTarget? target = await showModalBottomSheet<HighlightShareTarget>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const _HighlightShareSheet();
      },
    );

    if (target != null) {
      await controller.shareHighlight(target);
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

class _HighlightShareButton extends StatelessWidget {
  const _HighlightShareButton({required this.onPressed, required this.isBusy});

  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: isBusy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          : const Icon(Icons.share_rounded),
      label: Text(isBusy ? 'Preparing...' : 'Share Highlight'),
    );
  }
}

class _HighlightShareSheet extends StatelessWidget {
  const _HighlightShareSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Share highlight',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ...HighlightShareTarget.values.map((target) {
              return ListTile(
                leading: Icon(target.icon),
                title: Text(target.label),
                subtitle: Text(target.description),
                onTap: () => Navigator.of(context).pop(target),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.matchmakingState,
    required this.onSettingsTap,
    required this.onHistoryTap,
  });

  final MatchmakingState matchmakingState;
  final VoidCallback onSettingsTap;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _HeaderStatusStyle.fromState(theme, matchmakingState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gridlock Arena',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ultimate Tic-Tac-Toe, remixed with modifiers.',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Tooltip(
              message: 'Match history',
              child: _HeaderIconButton(
                icon: Icons.history_rounded,
                onPressed: onHistoryTap,
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: 'Settings',
              child: _HeaderIconButton(
                icon: Icons.settings_rounded,
                onPressed: onSettingsTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                status.color.withOpacity(0.18),
                status.color.withOpacity(0.08),
              ],
            ),
            border: Border.all(color: status.color.withOpacity(0.5), width: 0.7),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status.color,
                ),
                child: const SizedBox(width: 9, height: 9),
              ),
              const SizedBox(width: 10),
              Text(
                status.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  status.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.08),
        foregroundColor: Colors.white,
        hoverColor: Colors.white.withOpacity(0.18),
        highlightColor: Colors.white.withOpacity(0.12),
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _HeaderStatusStyle {
  const _HeaderStatusStyle({
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final String label;
  final String subtitle;
  final Color color;

  static _HeaderStatusStyle fromState(
    ThemeData theme,
    MatchmakingState state,
  ) {
    final phase = state.phase;
    switch (phase) {
      case MatchmakingPhase.searching:
        return _HeaderStatusStyle(
          label: 'Searching opponents',
          subtitle: 'Finding your next rival in the grid.',
          color: const Color(0xFF4FD5FF),
        );
      case MatchmakingPhase.connecting:
        return _HeaderStatusStyle(
          label: 'Connecting players',
          subtitle: "Opponent found. Preparing the board.",
          color: const Color(0xFF7D7BFF),
        );
      case MatchmakingPhase.matchReady:
        return _HeaderStatusStyle(
          label: 'Match ready',
          subtitle: 'The arena is primed—hop back into the round.',
          color: theme.colorScheme.secondary,
        );
      case MatchmakingPhase.error:
        return _HeaderStatusStyle(
          label: 'Connection issue',
          subtitle: state.errorMessage ?? 'Tap try again to requeue.',
          color: theme.colorScheme.error,
        );
      case MatchmakingPhase.idle:
        return _HeaderStatusStyle(
          label: 'Ready when you are',
          subtitle: 'Queue up or start a local match anytime.',
          color: const Color(0xFF2CE5C2),
        );
    }
  }
}

class _AuroraGlow extends StatelessWidget {
  const _AuroraGlow({
    required this.diameter,
    required this.colors,
    this.opacity = 0.6,
  });

  final double diameter;
  final List<Color> colors;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final Color midColor = Color.lerp(colors.first, colors.last, 0.5) ?? colors.first;

    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              colors.first.withOpacity(opacity),
              midColor.withOpacity(opacity * 0.35),
              colors.last.withOpacity(0.0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}

class _NoiseOverlay extends StatelessWidget {
  const _NoiseOverlay({this.opacity = 0.1});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(opacity * 0.4),
              Colors.white.withOpacity(opacity * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.28),
                Colors.white.withOpacity(0.12),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FooterFlare extends StatelessWidget {
  const _FooterFlare();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 180,
        height: 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [Color(0xFF53F5FF), Color(0xFF9E63FF)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D53F5FF),
              blurRadius: 24,
              spreadRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}