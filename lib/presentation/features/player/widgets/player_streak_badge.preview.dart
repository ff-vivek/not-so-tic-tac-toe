import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/player/widgets/player_streak_badge.dart'
    as i0;
import 'package:not_so_tic_tac_toe_game/domain/entities/player_profile.dart'
    as i1;

@Preview(name: 'PlayerStreakBadge_Dormant')
Widget previewPlayerStreakBadgeDormant() {
  return i0.PlayerStreakBadge(
    profile: i1.PlayerProfile(
      id: 'player123',
      currentWinStreak: 0,
      maxWinStreak: 5,
      rating: 1000,
    ),
    showMaxLabel: true,
    dense: false,
  );
}

@Preview(name: 'PlayerStreakBadge_Warm')
Widget previewPlayerStreakBadgeWarm() {
  return i0.PlayerStreakBadge(
    profile: i1.PlayerProfile(
      id: 'player123',
      currentWinStreak: 3,
      maxWinStreak: 5,
      rating: 1234,
    ),
    showMaxLabel: true,
    dense: false,
  );
}

@Preview(name: 'PlayerStreakBadge_Burning')
Widget previewPlayerStreakBadgeBurning() {
  return i0.PlayerStreakBadge(
    profile: i1.PlayerProfile(
      id: 'player123',
      currentWinStreak: 7,
      maxWinStreak: 10,
      rating: 1450,
    ),
    showMaxLabel: true,
    dense: false,
  );
}

@Preview(name: 'PlayerStreakBadge_Blazing')
Widget previewPlayerStreakBadgeBlazing() {
  return i0.PlayerStreakBadge(
    profile: i1.PlayerProfile(
      id: 'player123',
      currentWinStreak: 12,
      maxWinStreak: 15,
      rating: 1675,
    ),
    showMaxLabel: true,
    dense: false,
  );
}

@Preview(name: 'PlayerStreakBadge_Dense')
Widget previewPlayerStreakBadgeDense() {
  return i0.PlayerStreakBadge(
    profile: i1.PlayerProfile(
      id: 'player123',
      currentWinStreak: 8,
      maxWinStreak: 10,
      rating: 1320,
    ),
    showMaxLabel: false,
    dense: true,
  );
}

@Preview(name: 'PlayerStreakBadge_NoMaxLabel')
Widget previewPlayerStreakBadgeNoMaxLabel() {
  return i0.PlayerStreakBadge(
    profile: i1.PlayerProfile(
      id: 'player123',
      currentWinStreak: 4,
      maxWinStreak: 6,
      rating: 1200,
    ),
    showMaxLabel: false,
    dense: false,
  );
}
