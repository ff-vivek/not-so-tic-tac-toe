import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_category.dart';

class GameStatusBanner extends StatelessWidget {
  const GameStatusBanner({
    super.key,
    required this.gameState,
    this.localPlayerMark,
    this.onPlayAgain,
    this.onReturnToMenu,
    this.onLeave,
    this.activeModifierCategory,
    this.activeModifierId,
  });

  final TicTacToeGame gameState;
  final PlayerMark? localPlayerMark;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onReturnToMenu;
  final VoidCallback? onLeave;
  final ModifierCategory? activeModifierCategory;
  final String? activeModifierId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final details = _statusDetails(theme);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      child: _StatusCard(
        key: ValueKey(details.statusKey),
        title: details.title,
        subtitle: details.subtitle,
        color: details.color,
        icon: details.icon,
        actions: _buildActions(context),
      ),
    );
  }

  String _playerLabel(PlayerMark? mark) {
    if (mark == null) return 'No one';
    return mark == PlayerMark.x ? 'Player X' : 'Player O';
  }

  _StatusDetails _statusDetails(ThemeData theme) {
    switch (gameState.status) {
      case GameStatus.inProgress:
        final isLocalTurn =
            localPlayerMark != null && gameState.activePlayer == localPlayerMark;
        final subtitleLines = _inProgressSubtitleLines(isLocalTurn);
        return _StatusDetails(
          statusKey: 'progress-${gameState.activePlayer.name}',
          title: isLocalTurn ? 'Your Move' : '${_playerLabel(gameState.activePlayer)} to play',
          subtitle: subtitleLines.join('\n'),
          color: theme.colorScheme.primary,
          icon: isLocalTurn ? Icons.touch_app_rounded : Icons.hourglass_bottom_rounded,
        );
      case GameStatus.won:
        final isLocalWinner =
            localPlayerMark != null && gameState.winner == localPlayerMark;
        return _StatusDetails(
          statusKey: 'won-${gameState.winner?.name ?? 'none'}',
          title: isLocalWinner
              ? 'You Win!'
              : '${_playerLabel(gameState.winner)} Wins!',
          subtitle: isLocalWinner
              ? 'Great job! Tap below to jump into another round.'
              : 'Tough loss. Queue up again for a rematch.',
          color: theme.colorScheme.secondary,
          icon: isLocalWinner ? Icons.emoji_events_rounded : Icons.mood_bad_rounded,
        );
      case GameStatus.draw:
        return _StatusDetails(
          statusKey: 'draw',
          title: 'Draw Game',
          subtitle: "No more moves remaining. Let's try again!",
          color: theme.colorScheme.tertiary,
          icon: Icons.handshake_rounded,
        );
    }
  }

  List<String> _inProgressSubtitleLines(bool isLocalTurn) {
    final lines = <String>[];
    final baseLine = isLocalTurn
        ? 'Select an open square to play.'
        : 'Waiting for your opponent to move.';

    if (activeModifierCategory == null) {
      return [baseLine];
    }

    lines.add('Mode: ${activeModifierCategory!.displayName}');

    switch (activeModifierId) {
      case 'blocked_squares':
        lines.add('Locked squares are off-limits this round.');
        break;
      case 'spinner':
        lines.add(
          isLocalTurn
              ? 'Choose one of the highlighted squares this turn.'
              : 'Opponent must choose a highlighted square.',
        );
        break;
      default:
        if (activeModifierCategory != null) {
          lines.add(activeModifierCategory!.tagline);
        }
        break;
    }

    lines.add(baseLine);
    return lines;
  }

  List<Widget> _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final actions = <Widget>[];

    switch (gameState.status) {
      case GameStatus.inProgress:
        if (onLeave != null) {
          actions.add(
            TextButton.icon(
              onPressed: onLeave,
              icon: const Icon(Icons.flag_circle_rounded),
              label: const Text('Leave Match'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          );
        }
        break;
      case GameStatus.won:
      case GameStatus.draw:
        if (onPlayAgain != null) {
          actions.add(
            FilledButton.icon(
              onPressed: onPlayAgain,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Play Again'),
            ),
          );
        }
        if (onReturnToMenu != null) {
          actions.add(
            OutlinedButton.icon(
              onPressed: onReturnToMenu,
              icon: const Icon(Icons.home_rounded),
              label: const Text('Return to Menu'),
            ),
          );
        }
        break;
    }

    return actions;
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: color.withOpacity(0.9)),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusDetails {
  const _StatusDetails({
    required this.statusKey,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String statusKey;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
}