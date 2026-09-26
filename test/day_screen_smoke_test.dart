import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superacion_personal/screens/business_board_screen.dart';
import 'package:superacion_personal/screens/day_screen.dart';
import 'package:superacion_personal/screens/schedule_screen.dart';
import 'package:superacion_personal/services/app_state.dart';

void main() {
  for (final entry in {
    'Mi día': const DayScreen(),
    'Tablero': const BusinessBoardScreen(businessId: 'carros'),
    'Horario': const ScheduleScreen(),
  }.entries) {
    testWidgets('${entry.key} renders at phone width without overflow', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await tester.runAsync(() async {
        await state.load();
        await state.addLead('carros', 'Corolla 2018, pregunta precio y si acepta cambio por otro carro');
        await state.addLead('viajes', 'Cancún 4 personas');
      });
      tester.view.physicalSize = const Size(360 * 3, 740 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(home: Scaffold(body: entry.value)),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
