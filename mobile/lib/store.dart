import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';
import 'models.dart';
import 'services/app_block.dart';

const _storageKey = 'site_buddy_state_v1';

/// A guard buddy catching the user sneaking off to their phone mid-session.
class GuardCatch {
  const GuardCatch({required this.buddy, required this.appName});
  final MiniBuddy buddy;
  final String appName;

  String get message => buddy.catchLine.replaceFirst('%s', appName);
}

class AppStore extends ChangeNotifier with WidgetsBindingObserver {
  AppStore(this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  /// The store's notion of "now" — injectable for tests, so UI countdowns
  /// must read this rather than DateTime.now().
  DateTime now() => _clock();

  int materials = 0;
  int totalSessionsCompleted = 0;
  int totalFocusMinutes = 0;
  List<String> unlockedItemIds = [];
  List<JobTask> tasks = [];
  List<SessionRecord> sessionHistory = [];
  List<String> blockedApps = ['Instagram', 'TikTok'];
  Map<String, String> guardAssignments = {};
  int streak = 0;
  String? lastSessionDay;

  ActiveSession? activeSession;

  /// Set when a session just finished; cleared by [acknowledgeCompletion].
  SessionRecord? justCompleted;

  /// Whether the just-completed session finished while the app was closed.
  bool completedWhileAway = false;

  /// Set when a guard catches the user leaving mid-session.
  GuardCatch? lastCatch;

  bool _wentToBackground = false;

  // ---------------------------------------------------------------- lifecycle

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = activeSession;
    if (session == null || session.isPaused) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _wentToBackground = true;
    } else if (state == AppLifecycleState.resumed && _wentToBackground) {
      _wentToBackground = false;
      // Complete first if the timer ran out while we were away.
      if (checkSessionCompletion()) return;
      session.distractions += 1;
      lastCatch = _pickCatch();
      _save();
      notifyListeners();
    }
  }

  GuardCatch _pickCatch() {
    if (blockedApps.isEmpty) {
      return GuardCatch(buddy: miniBuddyRoster.first, appName: 'your phone');
    }
    final i = (activeSession?.distractions ?? 1) % blockedApps.length;
    final app = blockedApps[i];
    return GuardCatch(buddy: guardFor(app), appName: app);
  }

  void dismissCatch() {
    lastCatch = null;
    notifyListeners();
  }

  // ------------------------------------------------------------------- guards

  MiniBuddy guardFor(String app) {
    final id = guardAssignments[app];
    if (id != null) return miniBuddyById(id);
    // Stable auto-assignment: hand out roster members round-robin by the
    // app's position in the blocked list.
    final index = blockedApps.indexOf(app).clamp(0, blockedApps.length);
    return miniBuddyRoster[index % miniBuddyRoster.length];
  }

  void cycleGuard(String app) {
    final current = guardFor(app);
    final i = miniBuddyRoster.indexWhere((b) => b.id == current.id);
    guardAssignments[app] = miniBuddyRoster[(i + 1) % miniBuddyRoster.length].id;
    _save();
    notifyListeners();
  }

  void addBlockedApp(String app) {
    final trimmed = app.trim();
    if (trimmed.isEmpty || blockedApps.contains(trimmed)) return;
    blockedApps.add(trimmed);
    _save();
    notifyListeners();
  }

  void removeBlockedApp(String app) {
    blockedApps.remove(app);
    guardAssignments.remove(app);
    _save();
    notifyListeners();
  }

  // -------------------------------------------------------------------- tasks

  void addTask(String title, TaskType type) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    tasks.insert(
      0,
      JobTask(
        id: UniqueKey().toString(),
        title: trimmed,
        type: type,
        createdAtMs: _clock().millisecondsSinceEpoch,
      ),
    );
    _save();
    notifyListeners();
  }

  void toggleTask(String id) {
    for (final t in tasks) {
      if (t.id == id) t.done = !t.done;
    }
    _save();
    notifyListeners();
  }

  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  // ----------------------------------------------------------------- sessions

  void startSession(SessionCategory category, int durationMin, {String? taskId}) {
    activeSession = ActiveSession(
      category: category,
      durationMin: durationMin,
      taskId: taskId,
      endsAtMs:
          _clock().add(Duration(minutes: durationMin)).millisecondsSinceEpoch,
    );
    justCompleted = null;
    completedWhileAway = false;
    lastCatch = null;
    AppBlockService.startShield(blockedApps);
    _save();
    notifyListeners();
  }

  void pauseSession() {
    final session = activeSession;
    if (session == null || session.isPaused) return;
    session.pausedRemainingSeconds = session.remainingSeconds(_clock());
    session.endsAtMs = null;
    _save();
    notifyListeners();
  }

  void resumeSession() {
    final session = activeSession;
    if (session == null || !session.isPaused) return;
    session.endsAtMs = _clock()
        .add(Duration(seconds: session.pausedRemainingSeconds))
        .millisecondsSinceEpoch;
    _save();
    notifyListeners();
  }

  void cancelSession() {
    activeSession = null;
    lastCatch = null;
    AppBlockService.stopShield();
    _save();
    notifyListeners();
  }

  /// Completes the active session if its time is up. Returns true if it
  /// completed. Safe to call from a UI ticker every frame/second.
  bool checkSessionCompletion() {
    final session = activeSession;
    if (session == null || session.isPaused) return false;
    if (session.remainingSeconds(_clock()) > 0) return false;
    _completeSession(session);
    return true;
  }

  void _completeSession(ActiveSession session) {
    final earned = rewardForDuration(session.durationMin);
    final record = SessionRecord(
      id: UniqueKey().toString(),
      category: session.category,
      durationMin: session.durationMin,
      completedAtMs: _clock().millisecondsSinceEpoch,
      earned: earned,
      taskId: session.taskId,
    );
    materials += earned;
    totalSessionsCompleted += 1;
    totalFocusMinutes += session.durationMin;
    sessionHistory.insert(0, record);
    if (sessionHistory.length > 50) {
      sessionHistory = sessionHistory.sublist(0, 50);
    }
    _bumpStreak();
    if (session.taskId != null) {
      for (final t in tasks) {
        if (t.id == session.taskId) t.linkedSessionCount += 1;
      }
    }
    justCompleted = record;
    activeSession = null;
    lastCatch = null;
    AppBlockService.stopShield();
    _save();
    notifyListeners();
  }

  void acknowledgeCompletion() {
    justCompleted = null;
    completedWhileAway = false;
    notifyListeners();
  }

  String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _bumpStreak() {
    final today = _dayKey(_clock());
    if (lastSessionDay == today) return;
    final yesterday = _dayKey(_clock().subtract(const Duration(days: 1)));
    streak = (lastSessionDay == yesterday) ? streak + 1 : 1;
    lastSessionDay = today;
  }

  // ----------------------------------------------------------------- workshop

  bool unlockItem(WorkshopItem item) {
    if (unlockedItemIds.contains(item.id) || materials < item.cost) {
      return false;
    }
    materials -= item.cost;
    unlockedItemIds.add(item.id);
    _save();
    notifyListeners();
    return true;
  }

  // -------------------------------------------------------------- persistence

  void load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      materials = j['materials'] as int? ?? 0;
      totalSessionsCompleted = j['totalSessions'] as int? ?? 0;
      totalFocusMinutes = j['totalFocusMinutes'] as int? ?? 0;
      unlockedItemIds = List<String>.from(j['unlocked'] as List? ?? []);
      tasks = (j['tasks'] as List? ?? [])
          .map((t) => JobTask.fromJson(t as Map<String, dynamic>))
          .toList();
      sessionHistory = (j['history'] as List? ?? [])
          .map((t) => SessionRecord.fromJson(t as Map<String, dynamic>))
          .toList();
      blockedApps =
          List<String>.from(j['blockedApps'] as List? ?? ['Instagram', 'TikTok']);
      guardAssignments =
          Map<String, String>.from(j['guards'] as Map? ?? <String, String>{});
      streak = j['streak'] as int? ?? 0;
      lastSessionDay = j['lastSessionDay'] as String?;
      final active = j['active'];
      if (active != null) {
        activeSession = ActiveSession.fromJson(active as Map<String, dynamic>);
        // If the timer ran out while the app was closed, pay out now.
        final session = activeSession!;
        if (!session.isPaused && session.remainingSeconds(_clock()) <= 0) {
          _completeSession(session);
          completedWhileAway = true;
        }
      }
    } catch (_) {
      // Corrupt stored state: start fresh rather than crash on launch.
    }
  }

  void _save() {
    _prefs.setString(
      _storageKey,
      jsonEncode({
        'materials': materials,
        'totalSessions': totalSessionsCompleted,
        'totalFocusMinutes': totalFocusMinutes,
        'unlocked': unlockedItemIds,
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'history': sessionHistory.map((s) => s.toJson()).toList(),
        'blockedApps': blockedApps,
        'guards': guardAssignments,
        'streak': streak,
        'lastSessionDay': lastSessionDay,
        'active': activeSession?.toJson(),
      }),
    );
  }
}

/// Inherited access to the single [AppStore].
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
      : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing from widget tree');
    return scope!.notifier!;
  }
}
