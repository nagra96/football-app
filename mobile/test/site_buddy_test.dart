import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_buddy/catalog.dart';
import 'package:site_buddy/main.dart';
import 'package:site_buddy/models.dart';
import 'package:site_buddy/store.dart';

Future<AppStore> makeStore({DateTime Function()? clock}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return AppStore(prefs, clock: clock)..load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppStore', () {
    test('completing a session awards materials and bumps streak', () async {
      var now = DateTime(2026, 7, 24, 9, 0);
      final store = await makeStore(clock: () => now);

      store.startSession(SessionCategory.invoicing, 25);
      expect(store.activeSession, isNotNull);
      expect(store.checkSessionCompletion(), isFalse);

      now = now.add(const Duration(minutes: 26));
      expect(store.checkSessionCompletion(), isTrue);
      expect(store.materials, 5);
      expect(store.totalSessionsCompleted, 1);
      expect(store.streak, 1);
      expect(store.justCompleted, isNotNull);
      expect(store.activeSession, isNull);
    });

    test('pause stops the wall clock from eating the session', () async {
      var now = DateTime(2026, 7, 24, 9, 0);
      final store = await makeStore(clock: () => now);

      store.startSession(SessionCategory.admin, 25);
      now = now.add(const Duration(minutes: 10));
      store.pauseSession();
      final atPause = store.activeSession!.remainingSeconds(now);

      now = now.add(const Duration(hours: 3)); // lunch break
      expect(store.activeSession!.remainingSeconds(now), atPause);

      store.resumeSession();
      expect(store.activeSession!.remainingSeconds(now), atPause);
      expect(store.checkSessionCompletion(), isFalse);
    });

    test('session that expires while app is closed pays out on load',
        () async {
      var now = DateTime(2026, 7, 24, 9, 0);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = AppStore(prefs, clock: () => now)..load();
      store.startSession(SessionCategory.quoting, 45);

      // Relaunch after the timer has run out.
      now = now.add(const Duration(hours: 1));
      final store2 = AppStore(prefs, clock: () => now)..load();
      expect(store2.activeSession, isNull);
      expect(store2.materials, 10);
      expect(store2.completedWhileAway, isTrue);
    });

    test('sessions linked to a job log against it', () async {
      var now = DateTime(2026, 7, 24, 9, 0);
      final store = await makeStore(clock: () => now);
      store.addTask('Send quote to Mrs. Patel', TaskType.quote);
      final task = store.tasks.first;

      store.startSession(SessionCategory.quoting, 25, taskId: task.id);
      now = now.add(const Duration(minutes: 26));
      store.checkSessionCompletion();
      expect(store.tasks.first.linkedSessionCount, 1);
    });

    test('every blocked app gets a guard; guards can be swapped', () async {
      final store = await makeStore();
      expect(store.blockedApps, ['Instagram', 'TikTok']);
      final instaGuard = store.guardFor('Instagram');
      final tiktokGuard = store.guardFor('TikTok');
      expect(instaGuard.id, isNot(tiktokGuard.id));

      store.cycleGuard('Instagram');
      expect(store.guardFor('Instagram').id, isNot(instaGuard.id));

      store.addBlockedApp('YouTube');
      expect(store.guardFor('YouTube'), isA<MiniBuddy>());
    });

    test('workshop items cost materials and unlock once', () async {
      var now = DateTime(2026, 7, 24, 9, 0);
      final store = await makeStore(clock: () => now);
      final workbench = workshopItems.first;
      expect(store.unlockItem(workbench), isFalse); // can't afford

      store.startSession(SessionCategory.admin, 60);
      now = now.add(const Duration(minutes: 61));
      store.checkSessionCompletion(); // +15
      expect(store.unlockItem(workbench), isTrue); // costs 10
      expect(store.materials, 5);
      expect(store.unlockItem(workbench), isFalse); // already built
    });
  });

  group('UI', () {
    testWidgets('golden path: clock in, guards on duty, job done',
        (tester) async {
      var now = DateTime(2026, 7, 24, 9, 0);
      final store = await makeStore(clock: () => now);
      await tester.pumpWidget(SiteBuddyApp(store: store));

      expect(find.text('Clock In 🔨'), findsOneWidget);
      await tester.ensureVisible(find.text('Clock In 🔨'));
      await tester.pump();
      await tester.tap(find.text('Clock In 🔨'));
      await tester.pump();

      // Countdown and the guard crew are visible.
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('🚧 The crew is on guard duty'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('TikTok'), findsOneWidget);

      // Fast-forward past the end; the ticker completes the session.
      now = now.add(const Duration(minutes: 26));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Job done!'), findsOneWidget);
      expect(find.textContaining('+5 materials'), findsOneWidget);

      await tester.ensureVisible(find.text('Back to the site'));
      await tester.pump();
      await tester.tap(find.text('Back to the site'));
      await tester.pump();
      expect(find.text('Clock In 🔨'), findsOneWidget);
    });

    testWidgets('jobs can be added from the Jobs tab', (tester) async {
      final store = await makeStore();
      await tester.pumpWidget(SiteBuddyApp(store: store));

      await tester.tap(find.text('Jobs'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextField).first, 'Chase invoice from BuildCo');
      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(find.text('Chase invoice from BuildCo'), findsOneWidget);
      expect(store.tasks, hasLength(1));
    });

    testWidgets('crew tab lists guards for blocked apps', (tester) async {
      final store = await makeStore();
      await tester.pumpWidget(SiteBuddyApp(store: store));

      await tester.tap(find.text('Crew'));
      await tester.pumpAndSettle();
      expect(find.textContaining('is guarding Instagram', findRichText: true),
          findsOneWidget);
      expect(find.textContaining('is guarding TikTok', findRichText: true),
          findsOneWidget);
      await tester.scrollUntilVisible(find.text('Meet the Crew'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Meet the Crew'), findsOneWidget);
    });
  });
}
