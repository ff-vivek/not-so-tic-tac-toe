/// Defines the high-level buckets of gameplay modifiers that a match can use.
enum ModifierCategory {
  handYoureDealt(
    storageValue: 'hand_youre_dealt',
    displayName: "The Hand You're Dealt",
    tagline: 'Board-bending twists keep you guessing before the first move.',
  ),
  forcedMoves(
    storageValue: 'forced_moves',
    displayName: 'Forced Moves',
    tagline: 'Precision play where the grid dictates your next step.',
  );

  const ModifierCategory({
    required this.storageValue,
    required this.displayName,
    required this.tagline,
  });

  /// Canonical value saved in persistence layers like Firestore.
  final String storageValue;

  /// Player-facing label used throughout the UI.
  final String displayName;

  /// Short description that conveys what the category feels like to play.
  final String tagline;

  static ModifierCategory? fromStorage(String? value) {
    if (value == null) return null;
    for (final category in ModifierCategory.values) {
      if (category.storageValue == value) {
        return category;
      }
    }

    switch (value) {
      case 'handYoureDealt':
      case "handYou'reDealt":
        return ModifierCategory.handYoureDealt;
      case 'forcedMoves':
        return ModifierCategory.forcedMoves;
      default:
        return null;
    }
  }
}

extension ModifierCategoryX on ModifierCategory {
  String get analyticsLabel => storageValue;
}