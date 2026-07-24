import 'package:flutter/material.dart';

enum SessionCategory { invoicing, quoting, social, admin, other }

enum TaskType { quote, invoice, social, admin, other }

extension TaskTypeCategory on TaskType {
  SessionCategory get category => switch (this) {
        TaskType.quote => SessionCategory.quoting,
        TaskType.invoice => SessionCategory.invoicing,
        TaskType.social => SessionCategory.social,
        TaskType.admin => SessionCategory.admin,
        TaskType.other => SessionCategory.other,
      };
}

class JobTask {
  JobTask({
    required this.id,
    required this.title,
    required this.type,
    this.done = false,
    required this.createdAtMs,
    this.linkedSessionCount = 0,
  });

  final String id;
  final String title;
  final TaskType type;
  bool done;
  final int createdAtMs;
  int linkedSessionCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'done': done,
        'createdAtMs': createdAtMs,
        'linkedSessionCount': linkedSessionCount,
      };

  factory JobTask.fromJson(Map<String, dynamic> j) => JobTask(
        id: j['id'] as String,
        title: j['title'] as String,
        type: TaskType.values.byName(j['type'] as String),
        done: j['done'] as bool? ?? false,
        createdAtMs: j['createdAtMs'] as int? ?? 0,
        linkedSessionCount: j['linkedSessionCount'] as int? ?? 0,
      );
}

class SessionRecord {
  SessionRecord({
    required this.id,
    required this.category,
    required this.durationMin,
    required this.completedAtMs,
    required this.earned,
    this.taskId,
  });

  final String id;
  final SessionCategory category;
  final int durationMin;
  final int completedAtMs;
  final int earned;
  final String? taskId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'durationMin': durationMin,
        'completedAtMs': completedAtMs,
        'earned': earned,
        'taskId': taskId,
      };

  factory SessionRecord.fromJson(Map<String, dynamic> j) => SessionRecord(
        id: j['id'] as String,
        category: SessionCategory.values.byName(j['category'] as String),
        durationMin: j['durationMin'] as int,
        completedAtMs: j['completedAtMs'] as int,
        earned: j['earned'] as int,
        taskId: j['taskId'] as String?,
      );
}

/// A focus session that is currently running or paused.
///
/// Remaining time is derived from a wall-clock [endsAt] rather than counted
/// ticks, so the countdown stays correct on iOS when the app is suspended in
/// the background and timers stop firing.
class ActiveSession {
  ActiveSession({
    required this.category,
    required this.durationMin,
    this.taskId,
    this.endsAtMs,
    this.pausedRemainingSeconds = 0,
    this.distractions = 0,
  });

  final SessionCategory category;
  final int durationMin;
  final String? taskId;

  /// Epoch ms when the session completes; null while paused.
  int? endsAtMs;

  /// Seconds left, only meaningful while paused.
  int pausedRemainingSeconds;

  int distractions;

  bool get isPaused => endsAtMs == null;

  int remainingSeconds(DateTime now) {
    if (isPaused) return pausedRemainingSeconds;
    final ms = endsAtMs! - now.millisecondsSinceEpoch;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'durationMin': durationMin,
        'taskId': taskId,
        'endsAtMs': endsAtMs,
        'pausedRemainingSeconds': pausedRemainingSeconds,
        'distractions': distractions,
      };

  factory ActiveSession.fromJson(Map<String, dynamic> j) => ActiveSession(
        category: SessionCategory.values.byName(j['category'] as String),
        durationMin: j['durationMin'] as int,
        taskId: j['taskId'] as String?,
        endsAtMs: j['endsAtMs'] as int?,
        pausedRemainingSeconds: j['pausedRemainingSeconds'] as int? ?? 0,
        distractions: j['distractions'] as int? ?? 0,
      );
}

/// One of the small guard characters that watch over blocked apps.
class MiniBuddy {
  const MiniBuddy({
    required this.id,
    required this.name,
    required this.color,
    required this.tool,
    required this.catchLine,
  });

  final String id;
  final String name;
  final Color color;
  final String tool;

  /// What this buddy says when they catch you sneaking off mid-session.
  final String catchLine;
}

enum ItemZone { workshop, garage, van }

class WorkshopItem {
  const WorkshopItem({
    required this.id,
    required this.name,
    required this.zone,
    required this.cost,
    required this.emoji,
  });

  final String id;
  final String name;
  final ItemZone zone;
  final int cost;
  final String emoji;
}
