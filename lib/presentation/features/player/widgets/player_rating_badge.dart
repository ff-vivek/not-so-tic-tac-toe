import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_profile.dart';

class PlayerRatingBadge extends StatelessWidget {
  const PlayerRatingBadge({super.key, required this.profile, this.dense = false});

  final PlayerProfile profile;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg = theme.colorScheme.surfaceVariant;
    final Color fg = theme.colorScheme.onSurfaceVariant;

    final iconSize = dense ? 18.0 : 22.0;
    final valueStyle = dense
        ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 14, vertical: dense ? 6 : 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(dense ? 12 : 16),
        border: Border.all(color: fg.withOpacity(0.35), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: fg, size: iconSize),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile.rankTier,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fg.withOpacity(0.9),
                  letterSpacing: 0.3,
                ),
              ),
              Text('${profile.rating}', style: valueStyle?.copyWith(color: fg)),
            ],
          )
        ],
      ),
    );
  }
}
