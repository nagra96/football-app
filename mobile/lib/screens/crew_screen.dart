import 'package:flutter/material.dart';

import '../catalog.dart';
import '../services/app_block.dart';
import '../store.dart';
import '../widgets/mini_buddy.dart';

/// The Crew: stats, and the mini buddies that guard distracting apps.
class CrewScreen extends StatefulWidget {
  const CrewScreen({super.key});

  @override
  State<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> {
  final _appController = TextEditingController();
  bool _blockingAvailable = false;
  bool _authorized = false;
  bool _hasSelection = false;

  @override
  void initState() {
    super.initState();
    _refreshBlockingState();
  }

  Future<void> _refreshBlockingState() async {
    final available = await AppBlockService.isBlockingAvailable();
    final authorized = available && await AppBlockService.isAuthorized();
    final hasSelection = authorized && await AppBlockService.hasSelection();
    if (!mounted) return;
    setState(() {
      _blockingAvailable = available;
      _authorized = authorized;
      _hasSelection = hasSelection;
    });
  }

  @override
  void dispose() {
    _appController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    final hours = store.totalFocusMinutes ~/ 60;
    final minutes = store.totalFocusMinutes % 60;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text('Your Stats',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            _StatCard(label: 'Streak', value: '${store.streak}🔥'),
            const SizedBox(width: 8),
            _StatCard(
                label: 'Sessions', value: '${store.totalSessionsCompleted}'),
            const SizedBox(width: 8),
            _StatCard(label: 'On the clock', value: '${hours}h ${minutes}m'),
          ],
        ),
        const SizedBox(height: 24),
        Text('Guard Duty',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Every distracting app gets a mini buddy standing guard during your '
          'focus sessions. Tap a buddy to swap in someone else from the crew.',
          style: TextStyle(
              fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        if (_blockingAvailable)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _authorized
                      ? (_hasSelection
                          ? '🛡️ Shield mode is on: the apps you picked are '
                              'blocked for real while you\'re on the clock.'
                          : '🛡️ Shield mode is ready — pick which apps to '
                              'block during focus sessions.')
                      : '🛡️ This device supports real app blocking via '
                          'Screen Time. Grant access to let the crew '
                          'physically block your apps mid-session.',
                  style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () async {
                    if (!_authorized) {
                      await AppBlockService.requestAuthorization();
                    } else {
                      await AppBlockService.pickApps();
                    }
                    await _refreshBlockingState();
                  },
                  child: Text(_authorized
                      ? 'Choose apps to shield'
                      : 'Enable Screen Time access'),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'ℹ️ Reminder mode: on this build the crew watches the shift '
              'and calls out when you sneak off. On iOS, Screen Time '
              'blocking makes it physical.',
              style: TextStyle(
                  fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        for (final app in store.blockedApps) _GuardRow(app: app),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final app in suggestedBlockedApps)
              if (!store.blockedApps.contains(app))
                ActionChip(
                  label: Text('+ $app'),
                  onPressed: () => store.addBlockedApp(app),
                ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _appController,
                onSubmitted: (_) => _addCustom(),
                decoration: const InputDecoration(
                  hintText: 'Add another app or site',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
                onPressed: _addCustom, child: const Text('Add')),
          ],
        ),
        const SizedBox(height: 24),
        Text('Meet the Crew',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        for (final buddy in miniBuddyRoster)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: ListTile(
              dense: true,
              leading: MiniBuddyAvatar(buddy: buddy, size: 38),
              title: Text('${buddy.name} ${buddy.tool}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                buddy.catchLine.replaceFirst('%s', 'your feed'),
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Site Buddy — your progress is saved on this device.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  void _addCustom() {
    AppScope.of(context).addBlockedApp(_appController.text);
    _appController.clear();
    FocusScope.of(context).unfocus();
  }
}

class _GuardRow extends StatelessWidget {
  const _GuardRow({required this.app});

  final String app;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final buddy = store.guardFor(app);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        dense: true,
        leading: Tooltip(
          message: 'Tap to swap guard',
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => store.cycleGuard(app),
            child: MiniBuddyAvatar(buddy: buddy, size: 40),
          ),
        ),
        title: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: buddy.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: buddy.color)),
            TextSpan(text: ' is guarding $app'),
          ]),
          style: const TextStyle(fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () => store.removeBlockedApp(app),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
