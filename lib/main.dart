import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/finance_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_state.dart';
import 'theme.dart';
import 'widgets/custom_nav_bar.dart';

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
      title: 'OrgApp',
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
    FinanceScreen(),
    GoalsScreen(),
  ];

  static const _navItems = [
    NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Inicio'),
    NavItem(
        icon: Icons.check_circle_outline_rounded,
        activeIcon: Icons.check_circle_rounded,
        label: 'Hábitos'),
    NavItem(icon: Icons.book_outlined, activeIcon: Icons.book_rounded, label: 'Diario'),
    NavItem(
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        label: 'Finanzas'),
    NavItem(icon: Icons.flag_outlined, activeIcon: Icons.flag_rounded, label: 'Metas'),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (appState.userName == null || appState.userName!.isEmpty) {
      return const OnboardingScreen();
    }

    return Scaffold(
      body: SafeArea(bottom: false, child: _screens[_index]),
      bottomNavigationBar: CustomNavBar(
        items: _navItems,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
