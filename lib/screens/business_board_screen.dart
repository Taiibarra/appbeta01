import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/business.dart';
import '../services/app_state.dart';
import '../services/date_format_es.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/quick_capture_sheet.dart';

/// One business's pipeline. On a phone a side-scrolling kanban is
/// cramped, so stages are chips with counts and the list below shows
/// the selected stage; each card can jump one step forward in a tap.
class BusinessBoardScreen extends StatefulWidget {
  final String businessId;
  const BusinessBoardScreen({super.key, required this.businessId});

  @override
  State<BusinessBoardScreen> createState() => _BusinessBoardScreenState();
}

class _BusinessBoardScreenState extends State<BusinessBoardScreen> {
  LeadStage _stage = LeadStage.nuevo;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final business = appState.businessById(widget.businessId);
    final leads = appState.leadsFor(business.id, _stage);
    if (_stage == LeadStage.cerrado || _stage == LeadStage.perdido) {
      leads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    return Scaffold(
      appBar: AppBar(title: Text('${business.emoji}  ${business.name}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showQuickCaptureSheet(context),
        child: const Icon(Icons.bolt_rounded),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: LeadStage.values.map((s) {
                final selected = s == _stage;
                final count = appState.leadsFor(business.id, s).length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _stage = s),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.rust.withValues(alpha: 0.22) : null,
                        border:
                            Border.all(color: selected ? AppColors.rust : AppColors.border),
                      ),
                      child: Text('${s.labelFor(business)}  $count',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.textPrimary : AppColors.textSecondary)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: leads.isEmpty
                ? Center(
                    child: Text(
                      _stage == LeadStage.nuevo
                          ? 'Cola vacía. Lo que captures aparece aquí.'
                          : 'Nada en esta etapa.',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: leads.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _LeadTile(lead: leads[i], business: business),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LeadTile extends StatelessWidget {
  final Lead lead;
  final Business business;
  const _LeadTile({required this.lead, required this.business});

  @override
  Widget build(BuildContext context) {
    final next = lead.stage.next;
    return AppCard(
      borderColor: lead.isCooling ? AppColors.rustLight : null,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      onTap: () => showLeadSheet(context, lead, business),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lead.text, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  lead.isCooling
                      ? 'Enfriándose · sin movimiento ${formatAgoEs(lead.updatedAt)}'
                      : lead.stage == LeadStage.nuevo
                          ? 'Capturado ${formatAgoEs(lead.createdAt)}'
                          : 'Último movimiento ${formatAgoEs(lead.updatedAt)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: lead.isCooling ? AppColors.rustLight : AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (next != null)
            TextButton(
              onPressed: () => context.read<AppState>().moveLead(lead.id, next),
              child: Text('${next.labelFor(business)} →',
                  style: const TextStyle(color: AppColors.rustLight, fontSize: 12.5)),
            ),
        ],
      ),
    );
  }
}

void showLeadSheet(BuildContext context, Lead lead, Business business) {
  final appState = context.read<AppState>();
  final controller = TextEditingController(text: lead.text);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            const Text('Mover a',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LeadStage.values.map((s) {
                final current = s == lead.stage;
                return GestureDetector(
                  onTap: current
                      ? null
                      : () {
                          _saveText(appState, lead, controller.text);
                          appState.moveLead(lead.id, s);
                          Navigator.pop(ctx);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: current ? AppColors.rust.withValues(alpha: 0.22) : AppColors.surface,
                      border: Border.all(color: current ? AppColors.rust : AppColors.border),
                    ),
                    child: Text(s.labelFor(business), style: const TextStyle(fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    appState.deleteLead(lead.id);
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                  label: const Text('ELIMINAR', style: TextStyle(color: AppColors.danger)),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    _saveText(appState, lead, controller.text);
                    Navigator.pop(ctx);
                  },
                  child: const Text('LISTO'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _saveText(AppState appState, Lead lead, String text) {
  final trimmed = text.trim();
  if (trimmed.isNotEmpty && trimmed != lead.text) {
    appState.updateLeadText(lead.id, trimmed);
  }
}
