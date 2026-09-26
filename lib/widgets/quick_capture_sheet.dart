import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';

String? _lastBusinessId;

/// Five-second capture: type what came in, pick the business, done.
/// Remembers the last business picked so repeat captures are one tap.
void showQuickCaptureSheet(BuildContext context) {
  final appState = context.read<AppState>();
  final controller = TextEditingController();
  var businessId = appState.businesses.any((b) => b.id == _lastBusinessId)
      ? _lastBusinessId!
      : appState.businesses.first.id;
  final outsideWindow = !appState.isBusinessWindow(DateTime.now());

  void save(BuildContext ctx) {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    _lastBusinessId = businessId;
    appState.addLead(businessId, text);
    Navigator.pop(ctx);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(outsideWindow
            ? 'Guardado en la cola. Lo atiendes en tu próxima ventana.'
            : 'Guardado en la cola.'),
      ),
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
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
              const Text('Captura rápida',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                outsideWindow
                    ? 'Anótalo y sigue con lo tuyo. Se queda en la cola.'
                    : 'Estás en ventana de negocio.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: appState.businesses.map((b) {
                  final selected = b.id == businessId;
                  return GestureDetector(
                    onTap: () => setState(() => businessId = b.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.rust.withValues(alpha: 0.22)
                            : AppColors.surface,
                        border: Border.all(
                            color: selected ? AppColors.rust : AppColors.border),
                      ),
                      child: Text('${b.emoji}  ${b.name}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => save(ctx),
                decoration:
                    const InputDecoration(hintText: 'Ej. Corolla 2018, pregunta precio'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => save(ctx),
                  child: const Text('GUARDAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
