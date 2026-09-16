import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/goals_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'services/app_state.dart';
import 'theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: const SuperacionApp(),
    ),
  );
}

class SuperacionApp extends StatelessWidget {
  const SuperacionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Superación Personal',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    HabitsScreen(),
    JournalScreen(),
    GoalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.check_circle_outline_rounded), label: 'Hábitos'),
          NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Diario'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Metas'),
        ],
      ),
    );
  }
}
