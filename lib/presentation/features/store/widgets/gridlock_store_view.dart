import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/store/controllers/store_controller.dart';

class GridlockStoreView extends ConsumerWidget {
  const GridlockStoreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(storeCatalogProvider);
    final state = ref.watch(storeControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BalanceBar(balance: state.balance),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemCount: catalog.length,
            itemBuilder: (context, index) {
              final item = catalog[index];
              final owned = state.isOwned(item.id);
              final equipped = (item.type == StoreItemType.boardSkin && state.equippedSkinId == item.id) ||
                  (item.type == StoreItemType.markSet && state.equippedMarksId == item.id);
              return _StoreCard(
                item: item,
                owned: owned,
                equipped: equipped,
                onPurchase: () => ref.read(storeControllerProvider.notifier).purchase(item),
                onEquip: () => ref.read(storeControllerProvider.notifier).equip(item),
                canPurchase: ref.read(storeControllerProvider.notifier).canPurchase(item),
                background: colorScheme.surface,
                border: colorScheme.outlineVariant.withValues(alpha: 0.3),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            onPressed: () => ref.read(storeControllerProvider.notifier).grantCoins(200),
            icon: const Icon(Icons.redeem_rounded),
            label: const Text('Claim 200 bonus coins'),
          ),
        )
      ],
    );
  }
}

class _BalanceBar extends StatelessWidget {
  const _BalanceBar({required this.balance});
  final int balance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(Icons.savings_rounded, color: cs.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Balance', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$balance', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSecondaryContainer, fontWeight: FontWeight.bold)),
        )
      ]),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.onPurchase,
    required this.onEquip,
    required this.canPurchase,
    required this.background,
    required this.border,
  });

  final StoreItem item;
  final bool owned;
  final bool equipped;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;
  final bool canPurchase;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Stack(children: [
            _ItemPreview(icon: item.previewIcon, color: item.previewColor),
            if (!owned)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.errorContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${item.price} ', style: text.labelSmall?.copyWith(color: cs.onErrorContainer, fontWeight: FontWeight.bold)),
                ),
              )
            else if (equipped)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Equipped', style: text.labelSmall?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
                ),
              )
          ]),
        ),
        const SizedBox(height: 8),
        Text(item.name, style: text.titleSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Row(children: [
          _RarityPill(rarity: item.rarity),
          const Spacer(),
          if (!owned)
            FilledButton.icon(
              onPressed: canPurchase ? onPurchase : null,
              icon: Icon(Icons.lock_open_rounded, color: cs.onPrimary),
              label: Text('Unlock', style: text.labelLarge?.copyWith(color: cs.onPrimary)),
            )
          else
            OutlinedButton.icon(
              onPressed: equipped ? null : onEquip,
              icon: Icon(Icons.check_circle_rounded, color: cs.primary),
              label: Text('Equip', style: text.labelLarge?.copyWith(color: cs.primary)),
            )
        ])
      ]),
    );
  }
}

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest,
            cs.surfaceContainerHigh,
          ],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 48, color: color),
      ),
    );
  }
}

class _RarityPill extends StatelessWidget {
  const _RarityPill({required this.rarity});
  final StoreItemRarity rarity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    switch (rarity) {
      case StoreItemRarity.common:
        bg = cs.surfaceContainerHighest;
        fg = cs.onSurfaceVariant;
        break;
      case StoreItemRarity.rare:
        bg = cs.secondaryContainer;
        fg = cs.onSecondaryContainer;
        break;
      case StoreItemRarity.epic:
        bg = cs.tertiaryContainer;
        fg = cs.onTertiaryContainer;
        break;
    }
    final label = switch (rarity) { StoreItemRarity.common => 'Common', StoreItemRarity.rare => 'Rare', StoreItemRarity.epic => 'Epic' };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
