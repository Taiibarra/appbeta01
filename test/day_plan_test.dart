import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superacion_personal/models/business.dart';
import 'package:superacion_personal/models/day_block.dart';
import 'package:superacion_personal/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts with an empty schedule the user builds', () async {
    final state = AppState();
    await state.load();
    expect(state.dayBlocks, isEmpty);
    expect(state.currentBlock, isNull);

    await state.addDayBlock(DayBlock(
      id: 'w',
      label: 'Trabajo',
      kind: BlockKind.trabajo,
      startMinute: 8 * 60,
      endMinute: 17 * 60,
      weekdays: [1, 2, 3, 4, 5],
    ));
    await state.addDayBlock(DayBlock(
      id: 'n',
      label: 'Ventana principal',
      kind: BlockKind.negocio,
      startMinute: 19 * 60 + 30,
      endMinute: 21 * 60,
      weekdays: [1, 2, 3, 4, 5],
    ));
    expect(state.businesses.map((b) => b.name), ['Carros', 'Viajes']);
    expect(state.blockAt(DateTime(2026, 9, 21, 10))?.kind, BlockKind.trabajo);
    expect(state.isBusinessWindow(DateTime(2026, 9, 21, 20)), isTrue);
    expect(state.blockAt(DateTime(2026, 9, 26, 10)), isNull); // sábado

    final reloaded = AppState();
    await reloaded.load();
    expect(reloaded.dayBlocks.length, 2);
  });

  test('captures queue up and closing one counts as resolved today', () async {
    final state = AppState();
    await state.load();
    await state.addLead('carros', 'Corolla 2018, pregunta precio');
    await state.addLead('viajes', 'Cancún 4 personas diciembre');
    expect(state.totalQueued, 2);
    expect(state.queueFor('carros').single.text, 'Corolla 2018, pregunta precio');

    final lead = state.queueFor('carros').single;
    await state.moveLead(lead.id, LeadStage.conversacion);
    expect(state.queueFor('carros'), isEmpty);
    await state.moveLead(lead.id, LeadStage.cerrado);

    final close = state.todayClose;
    expect(close.captured, 2);
    expect(close.resolved, 1);
    expect(close.carriedOver, 1);
    expect(close.actionsInWindow + close.actionsOutside, 2);
  });

  test('lead goes cold after a few days without movement', () {
    final old = DateTime.now().subtract(const Duration(days: 4));
    final lead = Lead(
      id: '1',
      businessId: 'carros',
      text: 'x',
      stage: LeadStage.conversacion,
      createdAt: old,
      updatedAt: old,
    );
    expect(lead.isCooling, isTrue);
    lead.stage = LeadStage.cerrado;
    expect(lead.isCooling, isFalse);
  });
}
