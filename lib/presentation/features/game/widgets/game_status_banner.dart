import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';

class GameStatusBanner extends StatelessWidget {
  const GameStatusBanner({super.key, required this.gameState, this.localPlayerMark});

  final TicTacToeGame gameState;
  final PlayerMark? localPlayerMark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (gameState.status) {
      case GameStatus.inProgress:
        final isLocalTurn =
            localPlayerMark != null && gameState.activePlayer == localPlayerMark;
        final title = isLocalTurn
            ? 'Your Move'
            : '${_playerLabel(gameState.activePlayer)} to play';
        final subtitle = isLocalTurn
            ? 'Select an open square to play.'
            : 'Waiting for your opponent to move.';
        return _StatusCard(
          title: title,
          subtitle: subtitle,
          color: theme.colorScheme.primary,
        );
      case GameStatus.won:
        final isLocalWinner =
            localPlayerMark != null && gameState.winner == localPlayerMark;
        return _StatusCard(
          title: isLocalWinner
              ? 'You Win!'
              : '${_playerLabel(gameState.winner)} Wins!',
          subtitle: isLocalWinner
              ? 'Great job! Tap below to jump into another round.'
              : 'Tough loss. Queue up again for a rematch.',
          color: theme.colorScheme.secondary,
        );
      case GameStatus.draw:
        return _StatusCard(
          title: 'Draw Game',
          subtitle: 'No more moves remaining. Let’s try again!',
          color: theme.colorScheme.tertiary,
        );
    }
  }

  String _playerLabel(PlayerMark? mark) {
    if (mark == null) return 'No one';
    return mark == PlayerMark.x ? 'Player X' : 'Player O';
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

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
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: color.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}