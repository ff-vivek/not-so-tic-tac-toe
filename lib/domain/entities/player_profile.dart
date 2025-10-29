class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.currentWinStreak,
    required this.maxWinStreak,
    required this.rating,
  });

  final String id;
  final int currentWinStreak;
  final int maxWinStreak;
  final int rating;

  PlayerProfile copyWith({
    int? currentWinStreak,
    int? maxWinStreak,
    int? rating,
  }) {
    return PlayerProfile(
      id: id,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      maxWinStreak: maxWinStreak ?? this.maxWinStreak,
      rating: rating ?? this.rating,
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
      rating: (data['rating'] as num?)?.toInt() ?? 1000,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentWinStreak': currentWinStreak,
      'maxWinStreak': maxWinStreak,
      'rating': rating,
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

  String get rankTier {
    final r = rating;
    if (r >= 2400) return 'Mythic';
    if (r >= 2000) return 'Diamond';
    if (r >= 1700) return 'Platinum';
    if (r >= 1400) return 'Gold';
    if (r >= 1200) return 'Silver';
    return 'Bronze';
  }
}