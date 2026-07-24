import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../catalog.dart';
import '../models.dart';
import '../store.dart';
import '../widgets/buddy.dart';
import '../widgets/mini_buddy.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  SessionCategory _category = SessionCategory.admin;
  int _durationMin = 25;
  String? _taskId;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      final store = AppScope.of(context);
      if (store.activeSession != null) {
        store.checkSessionCompletion();
        setState(() {}); // repaint countdown
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final session = store.activeSession;

    final BuddyMood mood;
    if (store.justCompleted != null) {
      mood = BuddyMood.celebrating;
    } else if (session != null) {
      mood = session.isPaused ? BuddyMood.paused : BuddyMood.working;
    } else {
      mood = BuddyMood.idle;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        children: [
          BuddyMascot(mood: mood),
          const SizedBox(height: 6),
          Text(
            buddyLine(
                mood, DateTime.now().millisecondsSinceEpoch ~/ 30000),
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          if (store.lastCatch != null) _CatchBanner(catch_: store.lastCatch!),
          if (store.justCompleted != null)
            _CompletionCard(record: store.justCompleted!)
          else if (session != null)
            _RunningSession(session: session)
          else
            _SessionSetup(
              category: _category,
              durationMin: _durationMin,
              taskId: _taskId,
              onCategory: (c) => setState(() => _category = c),
              onDuration: (d) => setState(() => _durationMin = d),
              onTask: (id) {
                setState(() {
                  _taskId = id;
                  if (id != null) {
                    final task =
                        store.tasks.where((t) => t.id == id).firstOrNull;
                    if (task != null) _category = task.type.category;
                  }
                });
              },
              onStart: () {
                store.startSession(_category, _durationMin, taskId: _taskId);
                setState(() => _taskId = null);
              },
            ),
        ],
      ),
    );
  }
}

class _CatchBanner extends StatelessWidget {
  const _CatchBanner({required this.catch_});

  final GuardCatch catch_;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: catch_.buddy.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: catch_.buddy.color),
      ),
      child: Row(
        children: [
          MiniBuddyAvatar(buddy: catch_.buddy, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Text(catch_.message, style: const TextStyle(fontSize: 13)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: store.dismissCatch,
          ),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.record});

  final SessionRecord record;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Text('Job done!',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'You earned '),
            TextSpan(
              text: '+${record.earned} materials 🧱',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ]),
        ),
        if (store.completedWhileAway)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'The crew finished the shift while you were away.',
              style: TextStyle(
                  fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: store.acknowledgeCompletion,
          child: const Text('Back to the site'),
        ),
      ],
    );
  }
}

class _RunningSession extends StatelessWidget {
  const _RunningSession({required this.session});

  final ActiveSession session;

  String _format(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    final remaining = session.remainingSeconds(store.now());
    final progress =
        1 - remaining / math.max(1, session.durationMin * 60);

    return Column(
      children: [
        SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 11,
                strokeCap: StrokeCap.round,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
              Center(
                child: Text(
                  _format(remaining),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (store.blockedApps.isNotEmpty) ...[
          Text(
            '🚧 The crew is on guard duty',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (final app in store.blockedApps)
                GuardPost(buddy: store.guardFor(app), appName: app),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed:
                  session.isPaused ? store.resumeSession : store.pauseSession,
              child: Text(session.isPaused ? 'Resume' : 'Pause'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: store.cancelSession,
              child: const Text('Cancel'),
            ),
          ],
        ),
        if (session.distractions > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Caught sneaking off ${session.distractions} time${session.distractions > 1 ? 's' : ''} this shift',
              style: TextStyle(
                  fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

class _SessionSetup extends StatelessWidget {
  const _SessionSetup({
    required this.category,
    required this.durationMin,
    required this.taskId,
    required this.onCategory,
    required this.onDuration,
    required this.onTask,
    required this.onStart,
  });

  final SessionCategory category;
  final int durationMin;
  final String? taskId;
  final ValueChanged<SessionCategory> onCategory;
  final ValueChanged<int> onDuration;
  final ValueChanged<String?> onTask;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    final openTasks = store.tasks.where((t) => !t.done).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WHAT ARE YOU WORKING ON?', style: theme.textTheme.labelSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in SessionCategory.values)
              ChoiceChip(
                label: Text(categoryLabels[c]!),
                selected: category == c,
                onSelected: (_) => onCategory(c),
              ),
          ],
        ),
        if (openTasks.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('LINK A JOB (OPTIONAL)', style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          DropdownMenu<String?>(
            expandedInsets: EdgeInsets.zero,
            initialSelection: taskId,
            onSelected: onTask,
            dropdownMenuEntries: [
              const DropdownMenuEntry<String?>(
                  value: null, label: 'No specific job'),
              for (final t in openTasks)
                DropdownMenuEntry<String?>(value: t.id, label: t.title),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text('ON THE CLOCK FOR', style: theme.textTheme.labelSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final d in durationOptions) ...[
              Expanded(
                child: _DurationCard(
                  option: d,
                  selected: durationMin == d.minutes,
                  onTap: () => onDuration(d.minutes),
                ),
              ),
              if (d != durationOptions.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Clock In 🔨',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _DurationCard extends StatelessWidget {
  const _DurationCard(
      {required this.option, required this.selected, required this.onTap});

  final DurationOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant),
          ),
          child: Column(
            children: [
              Text(
                '${option.minutes} min',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
              Text(
                option.hint,
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? scheme.onPrimary.withValues(alpha: 0.85)
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
