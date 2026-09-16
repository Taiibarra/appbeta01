import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:superacion_personal/main.dart';
import 'package:superacion_personal/services/app_state.dart';

void main() {
  testWidgets('Onboarding asks for a name before showing the app',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState()..load(),
        child: const SuperacionApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CONTINUAR'), findsOneWidget);
    expect(find.text('Hábitos'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Cris');
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();

    // Only the active tab shows its label; the rest are icon-only.
    expect(find.text('INICIO'), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsWidgets);
  });
}
