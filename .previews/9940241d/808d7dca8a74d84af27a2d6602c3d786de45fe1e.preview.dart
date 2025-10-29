import 'package:flutter/widgets.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/player/widgets/player_rating_badge.dart';
import 'package:flutter/foundation.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_profile.dart';

@Preview(name: 'Default')
Widget previewPlayerRatingBadge_808d7dca8a74d84af27a2d6602c3d786de45fe1e() {
  return PlayerRatingBadge(
    key: /* TODO: provide optional Key value for key: */ Key(
      /* TODO: provide String value for value: */ '',
    ),
    profile: /* TODO: provide PlayerProfile value for profile: */ PlayerProfile(
      id: /* TODO: provide String value for id: */ '',
      currentWinStreak: /* TODO: provide int value for currentWinStreak: */ 0,
      maxWinStreak: /* TODO: provide int value for maxWinStreak: */ 0,
      rating: /* TODO: provide int value for rating: */ 0,
    ),
    dense: /* TODO: provide bool value for dense: */ false,
  );
}
