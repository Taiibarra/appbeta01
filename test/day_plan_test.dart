import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superacion_personal/models/business.dart';
import 'package:superacion_personal/models/day_block.dart';
import 'package:superacion_personal/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('seeds the default routine and businesses on first load', () async {
    final state = AppState();
    await state.load();
    expect(state.businesses.map((b) => b.name), ['Carros', 'Viajes']);
    final monday = DateTime(2026, 9, 21);
    expect(state.blockAt(DateTime(2026, 9, 21, 10))?.kind, BlockKind.trabajo);
    expect(state.blockAt(DateTime(2026, 9, 21, 12, 45))?.kind, BlockKind.negocio);
    expect(state.blockAt(DateTime(2026, 9, 21, 18))?.kind, BlockKind.gym);
    expect(state.blocksFor(monday).first.startMinute, 6 * 60);
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
