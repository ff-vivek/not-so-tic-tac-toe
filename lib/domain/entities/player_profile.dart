class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.currentWinStreak,
    required this.maxWinStreak,
  });

  final String id;
  final int currentWinStreak;
  final int maxWinStreak;

  PlayerProfile copyWith({
    int? currentWinStreak,
    int? maxWinStreak,
  }) {
    return PlayerProfile(
      id: id,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      maxWinStreak: maxWinStreak ?? this.maxWinStreak,
    );
  }

  static PlayerProfile fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return PlayerProfile(
      id: id,
      currentWinStreak: (data['currentWinStreak'] as num?)?.toInt() ?? 0,
      maxWinStreak: (data['maxWinStreak'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentWinStreak': currentWinStreak,
      'maxWinStreak': maxWinStreak,
    };
  }
}

enum StreakIntensity {
  dormant,
  warm,
  burning,
  blazing,
}

extension PlayerProfileView on PlayerProfile {
  StreakIntensity get intensity {
    if (currentWinStreak >= 25) return StreakIntensity.blazing;
    if (currentWinStreak >= 10) return StreakIntensity.burning;
    if (currentWinStreak >= 1) return StreakIntensity.warm;
    return StreakIntensity.dormant;
  }
}