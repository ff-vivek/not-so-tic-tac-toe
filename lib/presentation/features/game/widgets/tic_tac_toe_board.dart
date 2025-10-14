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
  });

  final TicTacToeGame game;
  final CellSelected onCellSelected;
  final CanSelectCell? canSelectCell;
  final PlayerMark? localPlayerMark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellSize = MediaQuery.of(context).size.width - 64;

    final board = game.board;
    final overlayDetails = _overlayDetails(theme);

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

                      return _BoardCell(
                        mark: mark,
                        isHighlighted: game.lastMove == position,
                        onTap: () => onCellSelected(position),
                        isInteractive: predicate(position),
                        theme: theme,
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
  });

  final PlayerMark? mark;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool isInteractive;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final borderColor = theme.colorScheme.primary.withOpacity(0.3);
    final highlightColor = theme.colorScheme.secondary.withOpacity(0.15);

    return Semantics(
      label: 'Board cell',
      hint: mark == null ? 'Tap to place your mark' : 'Occupied by ${mark!.name}',
      button: isInteractive,
      child: Material(
        color: isHighlighted ? highlightColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: mark == null ? 0 : 1,
              duration: const Duration(milliseconds: 160),
              child: Text(
                mark?.label ?? '',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: mark == PlayerMark.x
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
              ),
            ),
          ),
        ),
      ),
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