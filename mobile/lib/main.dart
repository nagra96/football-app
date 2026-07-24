import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/clock_screen.dart';
import 'screens/crew_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/workshop_screen.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = AppStore(prefs)..load();
  store.attach();
  runApp(SiteBuddyApp(store: store));
}

class SiteBuddyApp extends StatelessWidget {
  const SiteBuddyApp({super.key, required this.store});

  final AppStore store;

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFF6A821),
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFFDF6EA)
          : const Color(0xFF14110D),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: MaterialApp(
        title: 'Site Buddy',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Row(
          children: [
            Text('👷', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Site Buddy',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Buddy the Apprentice & crew',
                    style: TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text('🧱 ${store.materials}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (_tab) {
          0 => const ClockScreen(),
          1 => const JobsScreen(),
          2 => const WorkshopScreen(),
          _ => const CrewScreen(),
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Clock'),
          NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Jobs'),
          NavigationDestination(
              icon: Icon(Icons.construction_outlined),
              selectedIcon: Icon(Icons.construction),
              label: 'Workshop'),
          NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: 'Crew'),
        ],
      ),
    );
  }
}
