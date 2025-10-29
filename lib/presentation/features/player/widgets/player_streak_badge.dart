import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_profile.dart';

class PlayerStreakBadge extends StatelessWidget {
  const PlayerStreakBadge({
    super.key,
    required this.profile,
    this.showMaxLabel = false,
    this.dense = false,
  });

  final PlayerProfile profile;
  final bool showMaxLabel;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _paletteForIntensity(profile.intensity, theme.colorScheme);

    final iconSize = dense ? 20.0 : 26.0;
    final fontSize = dense ? theme.textTheme.labelLarge?.fontSize ?? 14 : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 12 : 16,
        vertical: dense ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(dense ? 12 : 16),
        border: Border.all(color: palette.foreground.withOpacity(0.4), width: 1.2),
        boxShadow: profile.currentWinStreak >= 10
            ? [
                BoxShadow(
                  color: palette.foreground.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: palette.foreground,
            size: iconSize,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile.currentWinStreak > 0 ? 'Win Streak' : 'Streak Ready',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: palette.foreground.withOpacity(0.9),
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                profile.currentWinStreak.toString(),
                style: (dense
                        ? theme.textTheme.titleMedium?.copyWith(fontSize: fontSize)
                        : theme.textTheme.titleLarge)
                    ?.copyWith(
                  color: palette.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showMaxLabel)
                Text(
                  'Best: ${profile.maxWinStreak}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.foreground.withOpacity(0.75),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ({Color background, Color foreground}) _paletteForIntensity(
    StreakIntensity intensity,
    ColorScheme scheme,
  ) {
    switch (intensity) {
      case StreakIntensity.blazing:
        return (
          background: const Color(0xFFFCE4EC),
          foreground: const Color(0xFFFF4081),
        );
      case StreakIntensity.burning:
        return (
          background: const Color(0xFFFFF3E0),
          foreground: const Color(0xFFF57C00),
        );
      case StreakIntensity.warm:
        return (
          background: const Color(0xFFFFF8E1),
          foreground: const Color(0xFFFFB300),
        );
      case StreakIntensity.dormant:
      default:
        return (
          background: scheme.surfaceVariant,
          foreground: scheme.onSurfaceVariant,
        );
    }
  }
}