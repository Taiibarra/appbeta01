import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:superacion_personal/main.dart';
import 'package:superacion_personal/services/app_state.dart';

void main() {
  testWidgets('App loads and shows the home tab', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState()..load(),
        child: const SuperacionApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hábitos'), findsWidgets);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });
}
