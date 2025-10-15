import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';

typedef CellSelected = void Function(BoardPosition position);
typedef CanSelectCell = bool Function(BoardPosition position);

class TicTacToeBoard extends StatelessWidget {
  const TicTacToeBoard({
    super.key,
    required this.game,
    required this.onCellSelected,
    this.canSelectCell,
    this.localPlayerMark,
    this.blockedPositions = const {},
    this.spinnerOptions = const [],
    this.isSpinnerActive = false,
    this.isSpinnerTurnForLocalPlayer = false,
    this.gravityDropPath = const [],
  });

  final TicTacToeGame game;
  final CellSelected onCellSelected;
  final CanSelectCell? canSelectCell;
  final PlayerMark? localPlayerMark;
  final Set<BoardPosition> blockedPositions;
  final List<BoardPosition> spinnerOptions;
  final bool isSpinnerActive;
  final bool isSpinnerTurnForLocalPlayer;
  final List<BoardPosition> gravityDropPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellSize = MediaQuery.of(context).size.width - 64;

    final board = game.board;
    final overlayDetails = _overlayDetails(theme);
    final spinnerSet = spinnerOptions.toSet();
    final gravityDropDetails = _gravityDropDetails();

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: SizedBox(
          width: cellSize,
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: overlayDetails == null ? 1 : 0.25,
                duration: const Duration(milliseconds: 250),
                child: AbsorbPointer(
                  absorbing: overlayDetails != null,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final row = index ~/ 3;
                      final col = index % 3;
                      final mark = board[index];
                      final position = BoardPosition(row: row, col: col);
                      final predicate = canSelectCell ?? game.canPlayAt;
                      final gravityDistance = gravityDropDetails[position.index];

                      return _BoardCell(
                        mark: mark,
                        isHighlighted: game.lastMove == position,
                        onTap: () => onCellSelected(position),
                        isInteractive: predicate(position),
                        theme: theme,
                        isBlocked: blockedPositions.contains(position),
                        isSpinnerOption: spinnerSet.contains(position),
                        spinnerActive: isSpinnerActive,
                        emphasizeSpinner: isSpinnerTurnForLocalPlayer,
                        gravityDropDistance: gravityDistance??0,
                      );
                    },
                  ),
                ),
              ),
              if (overlayDetails != null)
                Positioned.fill(
                  child: _CompletionOverlay(details: overlayDetails),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<int, double> _gravityDropDetails() {
    if (gravityDropPath.length < 2) {
      return const {};
    }

    final start = gravityDropPath.first;
    final end = gravityDropPath.last;
    if (start.dimension != 3 || end.dimension != 3) {
      return const {};
    }
    final distance = (end.row - start.row).abs().toDouble();
    if (distance == 0) {
      return const {};
    }

    return {
      end.index: distance,
    };
  }

  _OverlayDetails? _overlayDetails(ThemeData theme) {
    switch (game.status) {
      case GameStatus.inProgress:
        return null;
      case GameStatus.won:
        final winner = game.winner;
        final isLocalWinner = winner != null && winner == localPlayerMark;
        final hasPerspective = localPlayerMark != null;
        final accentColor = isLocalWinner
            ? theme.colorScheme.primary
            : hasPerspective
                ? theme.colorScheme.error
                : theme.colorScheme.secondary;
        final title = isLocalWinner
            ? 'Victory!'
            : hasPerspective
                ? 'Defeat'
                : '${winner != null ? _playerLabel(winner) : 'Winner'} Wins';
        final subtitle = isLocalWinner
            ? 'Queue up another match to defend the crown.'
            : hasPerspective
                ? 'Shake it off and challenge the grid again.'
                : 'Match complete. Queue another round when ready.';
        final icon = isLocalWinner
            ? Icons.emoji_events_rounded
            : hasPerspective
                ? Icons.sentiment_dissatisfied_rounded
                : Icons.emoji_events_outlined;
        final statusKey = 'won-${winner?.name ?? 'none'}-${localPlayerMark?.name ?? 'neutral'}';

        return _OverlayDetails(
          key: statusKey,
          title: title,
          subtitle: subtitle,
          icon: icon,
          accentColor: accentColor,
        );
      case GameStatus.draw:
        return _OverlayDetails(
          key: 'draw',
          title: 'Stalemate',
          subtitle: 'No one cracked the grid this round. Try a rematch!',
          icon: Icons.handshake_rounded,
          accentColor: theme.colorScheme.tertiary,
        );
    }
  }

  String _playerLabel(PlayerMark mark) {
    return mark == PlayerMark.x ? 'Player X' : 'Player O';
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.mark,
    required this.isHighlighted,
    required this.onTap,
    required this.isInteractive,
    required this.theme,
    required this.isBlocked,
    required this.isSpinnerOption,
    required this.spinnerActive,
    required this.emphasizeSpinner,
    this.gravityDropDistance=0,
  });

  final PlayerMark? mark;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool isInteractive;
  final ThemeData theme;
  final bool isBlocked;
  final bool isSpinnerOption;
  final bool spinnerActive;
  final bool emphasizeSpinner;
  final double gravityDropDistance;

  @override
  Widget build(BuildContext context) {
    final borderColor = theme.colorScheme.primary.withOpacity(0.3);
    final highlightColor = theme.colorScheme.secondary.withOpacity(0.15);
    final blockedColor = theme.colorScheme.surfaceVariant.withOpacity(0.85);
    final baseColor = isBlocked
        ? blockedColor
        : isHighlighted
            ? highlightColor
            : Colors.white;

    final semanticsHint = isBlocked
        ? 'Blocked square'
        : mark == null
            ? spinnerActive && !isSpinnerOption
                ? 'Unavailable this turn'
                : 'Tap to place your mark'
            : 'Occupied by ${mark!.name}';

    return Semantics(
      label: 'Board cell',
      hint: semanticsHint,
      button: isInteractive,
      child: Material(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (spinnerActive && isSpinnerOption)
                IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _SpinnerPulse(
                      color: emphasizeSpinner
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.tertiary,
                      emphasize: emphasizeSpinner,
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: spinnerActive && isSpinnerOption
                        ? theme.colorScheme.secondary.withOpacity(0.65)
                        : borderColor,
                    width: spinnerActive && isSpinnerOption ? 2.6 : 2,
                  ),
                ),
                alignment: Alignment.center,
                child: AnimatedScale(
                  scale: mark == null ? 0 : 1,
                  duration: const Duration(milliseconds: 160),
                  child: _GravityAnimatedMark(
                    mark: mark,
                    textStyle: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: mark == PlayerMark.x
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                    ),
                    gravityDropDistance: gravityDropDistance,
                  ),
                ),
              ),
              if (isBlocked)
                const _BlockedOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockedOverlay extends StatelessWidget {
  const _BlockedOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.9),
        border: Border.all(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.block,
        size: 30,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
      ),
    );
  }
}

class _GravityAnimatedMark extends StatelessWidget {
  const _GravityAnimatedMark({
    required this.mark,
    required this.textStyle,
    required this.gravityDropDistance,
  });

  final PlayerMark? mark;
  final TextStyle? textStyle;
  final double? gravityDropDistance;

  @override
  Widget build(BuildContext context) {
    final content = Text(
      mark?.label ?? '',
      style: textStyle,
    );

    if (mark == null || gravityDropDistance == null) {
      return content;
    }

    if (gravityDropDistance == 0) {
      return content;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('gravity-${mark!.name}-${gravityDropDistance!.toStringAsFixed(2)}'),
      tween: Tween<double>(
        begin: -gravityDropDistance!,
        end: 0,
      ),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return FractionalTranslation(
          translation: Offset(0, value),
          child: child,
        );
      },
      child: content,
    );
  }
}

class _SpinnerPulse extends StatefulWidget {
  const _SpinnerPulse({required this.color, required this.emphasize});

  final Color color;
  final bool emphasize;

  @override
  State<_SpinnerPulse> createState() => _SpinnerPulseState();
}

class _SpinnerPulseState extends State<_SpinnerPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.emphasize
        ? const Duration(milliseconds: 900)
        : const Duration(milliseconds: 1400),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void didUpdateWidget(covariant _SpinnerPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emphasize != widget.emphasize) {
      _controller.duration = widget.emphasize
          ? const Duration(milliseconds: 900)
          : const Duration(milliseconds: 1400);
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final eased = Curves.easeInOut.transform(_controller.value);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.color.withOpacity(0.18 + 0.12 * eased),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.35 + 0.35 * eased),
                blurRadius: 18 + 12 * eased,
                spreadRadius: 1.5 + 1.8 * eased,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompletionOverlay extends StatelessWidget {
  const _CompletionOverlay({required this.details});

  final _OverlayDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Container(
        key: ValueKey(details.key),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: details.accentColor.withOpacity(0.45),
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(details.icon, size: 48, color: details.accentColor),
            const SizedBox(height: 16),
            Text(
              details.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: details.accentColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              details.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayDetails {
  const _OverlayDetails({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
}