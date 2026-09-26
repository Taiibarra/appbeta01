import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/day_block.dart';
import 'screens/day_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';
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
  Timer? _reminderTimer;
  String? _lastWindowNotified;

  @override
  void initState() {
    super.initState();
    _reminderTimer = Timer.periodic(const Duration(seconds: 60), (_) => _checkReminder());
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkReminder());
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  void _checkReminder() {
    final appState = context.read<AppState>();
    if (!appState.loaded) return;
    _checkBusinessWindow(appState);
    if (!appState.shouldShowReminderNow) return;
    appState.markReminderShownToday();
    final pending = appState.habits.length - appState.todayCompletedCount;
    final body = appState.habits.isEmpty
        ? 'Abre la app y registra cómo va tu día.'
        : pending > 0
            ? 'Te faltan $pending hábito${pending == 1 ? '' : 's'} por marcar hoy.'
            : '¡Ya completaste tus hábitos de hoy! Sigue así.';
    NotificationService.show('OrgApp', body);
  }

  /// Pings once when a business window opens with captures waiting.
  void _checkBusinessWindow(AppState appState) {
    final block = appState.currentBlock;
    if (block == null || block.kind != BlockKind.negocio) return;
    final key = '${dateKey(DateTime.now())}-${block.id}';
    if (_lastWindowNotified == key) return;
    _lastWindowNotified = key;
    final queued = appState.totalQueued;
    if (queued == 0) return;
    NotificationService.show(
      'Ventana de negocio abierta',
      '${block.label}: tienes $queued pendiente${queued == 1 ? '' : 's'} en cola.',
    );
  }

  final _screens = const [
    HomeScreen(),
    DayScreen(),
    HabitsScreen(),
    JournalScreen(),
    FinanceScreen(),
    GoalsScreen(),
  ];

  static const _navItems = [
    NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Inicio'),
    NavItem(icon: Icons.schedule_outlined, activeIcon: Icons.schedule_rounded, label: 'Mi día'),
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
