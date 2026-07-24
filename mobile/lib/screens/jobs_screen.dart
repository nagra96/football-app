import 'package:flutter/material.dart';

import '../catalog.dart';
import '../models.dart';
import '../store.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _titleController = TextEditingController();
  TaskType _type = TaskType.quote;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _add() {
    final store = AppScope.of(context);
    if (_titleController.text.trim().isEmpty) return;
    store.addTask(_titleController.text, _type);
    _titleController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    final open = store.tasks.where((t) => !t.done).toList();
    final done = store.tasks.where((t) => t.done).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text('The Job List',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _titleController,
          onSubmitted: (_) => _add(),
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'e.g. Send quote to Mrs. Patel',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownMenu<TaskType>(
                expandedInsets: EdgeInsets.zero,
                initialSelection: _type,
                onSelected: (t) => setState(() => _type = t ?? _type),
                dropdownMenuEntries: [
                  for (final t in TaskType.values)
                    DropdownMenuEntry(
                      value: t,
                      label: '${taskTypeIcons[t]} ${taskTypeLabels[t]}',
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _add, child: const Text('Add')),
          ],
        ),
        const SizedBox(height: 16),
        if (open.isEmpty && done.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'No jobs on the board yet.\nAdd a quote or invoice to chase.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        for (final t in open) _JobRow(task: t),
        if (done.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('WRAPPED UP', style: theme.textTheme.labelSmall),
          const SizedBox(height: 6),
          for (final t in done) _JobRow(task: t),
        ],
      ],
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.task});

  final JobTask task;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Opacity(
        opacity: task.done ? 0.55 : 1,
        child: ListTile(
          dense: true,
          leading: Checkbox(
            value: task.done,
            onChanged: (_) => store.toggleTask(task.id),
          ),
          title: Row(
            children: [
              Text(taskTypeIcons[task.type]!,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    decoration: task.done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          subtitle: task.linkedSessionCount > 0
              ? Text(
                  '${task.linkedSessionCount} focus session${task.linkedSessionCount > 1 ? 's' : ''} logged',
                  style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant),
                )
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => store.deleteTask(task.id),
          ),
        ),
      ),
    );
  }
}
