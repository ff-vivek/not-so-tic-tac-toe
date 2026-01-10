import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Types of purchasable cosmetics in the Gridlock Store.
enum StoreItemType { boardSkin, markSet, effect }

/// Rarity tiers to style items subtly.
enum StoreItemRarity { common, rare, epic }

/// Immutable catalog item definition.
class StoreItem {
  const StoreItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.rarity,
    required this.previewIcon,
    required this.previewColor,
  });

  final String id;
  final String name;
  final int price; // local soft currency
  final StoreItemType type;
  final StoreItemRarity rarity;
  final IconData previewIcon;
  final Color previewColor;
}

/// Readonly catalog provider. In a real app this could come from backend.
final storeCatalogProvider = Provider<List<StoreItem>>((ref) {
  // Use theme-provided semantic colors at runtime where possible; here we pick
  // a few Material icon colors to avoid hard-coding arbitrary hex values.
  return const [
    StoreItem(
      id: 'skin-aurora',
      name: 'Aurora Grid',
      price: 450,
      type: StoreItemType.boardSkin,
      rarity: StoreItemRarity.rare,
      previewIcon: Icons.grid_4x4_rounded,
      previewColor: Colors.teal,
    ),
    StoreItem(
      id: 'skin-neon',
      name: 'Neon Pulse',
      price: 600,
      type: StoreItemType.boardSkin,
      rarity: StoreItemRarity.epic,
      previewIcon: Icons.bolt_rounded,
      previewColor: Colors.pinkAccent,
    ),
    StoreItem(
      id: 'marks-minimal',
      name: 'Minimal Marks',
      price: 300,
      type: StoreItemType.markSet,
      rarity: StoreItemRarity.common,
      previewIcon: Icons.close_fullscreen_rounded,
      previewColor: Colors.indigo,
    ),
    StoreItem(
      id: 'marks-bubble',
      name: 'Bubble Marks',
      price: 380,
      type: StoreItemType.markSet,
      rarity: StoreItemRarity.rare,
      previewIcon: Icons.bubble_chart_rounded,
      previewColor: Colors.lightBlue,
    ),
    StoreItem(
      id: 'fx-trail',
      name: 'Trail Effect',
      price: 520,
      type: StoreItemType.effect,
      rarity: StoreItemRarity.rare,
      previewIcon: Icons.auto_fix_high_rounded,
      previewColor: Colors.deepPurple,
    ),
    StoreItem(
      id: 'fx-spark',
      name: 'Spark Burst',
      price: 700,
      type: StoreItemType.effect,
      rarity: StoreItemRarity.epic,
      previewIcon: Icons.local_fire_department_rounded,
      previewColor: Colors.orange,
    ),
  ];
});

/// Store user state for balance and ownership.
@immutable
class StoreState {
  const StoreState({
    required this.balance,
    required this.ownedIds,
    this.equippedSkinId,
    this.equippedMarksId,
  });

  final int balance;
  final Set<String> ownedIds;
  final String? equippedSkinId;
  final String? equippedMarksId;

  bool isOwned(String id) => ownedIds.contains(id);

  StoreState copyWith({
    int? balance,
    Set<String>? ownedIds,
    String? equippedSkinId,
    String? equippedMarksId,
  }) => StoreState(
        balance: balance ?? this.balance,
        ownedIds: ownedIds ?? this.ownedIds,
        equippedSkinId: equippedSkinId ?? this.equippedSkinId,
        equippedMarksId: equippedMarksId ?? this.equippedMarksId,
      );
}

/// Controller that manages local-only store logic. No backend required.
class StoreController extends StateNotifier<StoreState> {
  StoreController() : super(const StoreState(balance: 800, ownedIds: {}));

  void grantCoins(int amount) {
    final next = (state.balance + amount).clamp(0, 999999);
    state = state.copyWith(balance: next);
    debugPrint('Store: granted +$amount, balance=$next');
  }

  bool canPurchase(StoreItem item) => state.balance >= item.price && !state.ownedIds.contains(item.id);

  void purchase(StoreItem item) {
    if (!canPurchase(item)) return;
    final newBalance = state.balance - item.price;
    final newOwned = {...state.ownedIds, item.id};
    state = state.copyWith(balance: newBalance, ownedIds: newOwned);
    debugPrint('Store: purchased ${item.id}, balance=$newBalance');
  }

  void equip(StoreItem item) {
    if (!state.ownedIds.contains(item.id)) return;
    if (item.type == StoreItemType.boardSkin) {
      state = state.copyWith(equippedSkinId: item.id);
    } else if (item.type == StoreItemType.markSet) {
      state = state.copyWith(equippedMarksId: item.id);
    }
    debugPrint('Store: equipped ${item.id}');
  }
}

final storeControllerProvider = StateNotifierProvider<StoreController, StoreState>((ref) => StoreController());
