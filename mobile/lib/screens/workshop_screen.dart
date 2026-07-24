import 'package:flutter/material.dart';

import '../catalog.dart';
import '../models.dart';
import '../store.dart';

class WorkshopScreen extends StatelessWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Build Your Site',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Chip(label: Text('🧱 ${store.materials}')),
          ],
        ),
        for (final zone in ItemZone.values) ...[
          const SizedBox(height: 12),
          _ZoneSection(zone: zone),
        ],
      ],
    );
  }
}

class _ZoneSection extends StatelessWidget {
  const _ZoneSection({required this.zone});

  final ItemZone zone;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    final items = workshopItems.where((i) => i.zone == zone).toList();
    final unlocked =
        items.where((i) => store.unlockedItemIds.contains(i.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${zoneIcons[zone]} ${zoneLabels[zone]}',
                style: theme.textTheme.titleSmall),
            Text('$unlocked/${items.length}',
                style: TextStyle(
                    fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.55,
          children: [for (final item in items) _ItemCard(item: item)],
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final WorkshopItem item;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final unlocked = store.unlockedItemIds.contains(item.id);
    final canAfford = store.materials >= item.cost;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: unlocked ? scheme.primaryContainer : scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: unlocked ? scheme.primary : scheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: unlocked ? 1 : 0.45,
            child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 2),
          Text(
            item.name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          if (unlocked)
            Text('Built ✓',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary))
          else
            SizedBox(
              height: 26,
              child: FilledButton.tonal(
                onPressed: canAfford ? () => store.unlockItem(item) : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 11),
                ),
                child: Text('🧱 ${item.cost}'),
              ),
            ),
        ],
      ),
    );
  }
}
