import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/business.dart';
import '../models/day_block.dart';
import '../services/app_state.dart';
import '../services/date_format_es.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/quick_capture_sheet.dart';
import '../widgets/section_header.dart';
import 'business_board_screen.dart';
import 'schedule_screen.dart';

class DayScreen extends StatefulWidget {
  const DayScreen({super.key});

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    // Keeps "qué bloque toca ahora" in step with the clock.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final now = DateTime.now();
    final blocks = appState.blocksFor(now);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Mi día'),
        actions: [
          IconButton(
            tooltip: 'Editar horario',
            icon: const Icon(Icons.edit_calendar_outlined, size: 21),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showQuickCaptureSheet(context),
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('CAPTURAR', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        children: [
          _NowCard(appState: appState),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Cola por negocio'),
          const SizedBox(height: 12),
          ...appState.businesses.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QueueCard(business: b),
              )),
          const SizedBox(height: 14),
          const SectionHeader(title: 'Hoy'),
          const SizedBox(height: 12),
          if (blocks.isEmpty)
            const Text('No tienes bloques para hoy. Toca el calendario arriba para armarlos.',
                style: TextStyle(color: AppColors.textMuted))
          else
            _Timeline(blocks: blocks, current: appState.currentBlock),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Cierre del día'),
          const SizedBox(height: 12),
          _DayCloseCard(close: appState.todayClose),
        ],
      ),
    );
  }
}

class _NowCard extends StatelessWidget {
  final AppState appState;
  const _NowCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minute = now.hour * 60 + now.minute;
    final current = appState.currentBlock;
    final next = appState.nextBlock;
    final inWindow = current?.kind == BlockKind.negocio;
    final queued = appState.totalQueued;
    final color = current?.kind.color ?? AppColors.textMuted;

    final String status;
    if (inWindow) {
      status = queued > 0
          ? 'Ventana abierta · $queued pendiente${queued == 1 ? '' : 's'} en cola'
          : 'Ventana abierta · cola vacía';
    } else if (queued > 0) {
      status = 'Fuera de ventana · $queued esperando'
          '${_nextWindowText(appState, minute)}';
    } else {
      status = 'Fuera de ventana · nada pendiente';
    }

    return AppCard(
      borderColor: inWindow ? AppColors.rust : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(current?.kind.icon ?? Icons.free_breakfast_outlined, color: color, size: 22),
              const SizedBox(width: 10),
              Text('AHORA',
                  style: GoogleFonts.barlowCondensed(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.textMuted)),
              const Spacer(),
              if (current != null)
                Text('Quedan ${_duration(current.endMinute - minute)}',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            current == null ? 'Tiempo libre' : '${current.kind.label} · ${current.label}',
            style: GoogleFonts.barlowCondensed(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(status,
              style: TextStyle(
                  color: inWindow ? AppColors.rustLight : AppColors.textSecondary,
                  fontSize: 13.5)),
          if (next != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              'Sigue: ${next.kind.label} · ${next.label} a las ${formatMinuteOfDay(next.startMinute)}',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  String _nextWindowText(AppState appState, int minute) {
    final window = appState
        .blocksFor(DateTime.now())
        .where((b) => b.kind == BlockKind.negocio && b.startMinute > minute)
        .firstOrNull;
    return window == null ? '' : ' hasta las ${formatMinuteOfDay(window.startMinute)}';
  }
}

String _duration(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h h' : '$h h $m min';
}

class _QueueCard extends StatelessWidget {
  final Business business;
  const _QueueCard({required this.business});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final queue = appState.queueFor(business.id);
    final cooling = appState.coolingFor(business.id);
    final inPlay = LeadStage.values
        .where((s) => s.isOpen && s != LeadStage.nuevo)
        .fold(0, (sum, s) => sum + appState.leadsFor(business.id, s).length);

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BusinessBoardScreen(businessId: business.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(business.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(business.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              _CountBadge(count: queue.length),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$inPlay en movimiento'
            '${cooling.isEmpty ? '' : ' · ${cooling.length} enfriándose'}',
            style: TextStyle(
                fontSize: 12.5,
                color: cooling.isEmpty ? AppColors.textMuted : AppColors.rustLight),
          ),
          if (queue.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...queue.take(3).map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppColors.rust),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(l.text, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(formatAgoEs(l.createdAt),
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ),
                )),
            if (queue.length > 3)
              Text('+${queue.length - 3} más',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.rust : Colors.transparent,
        border: Border.all(color: active ? AppColors.rust : AppColors.border),
      ),
      child: Text('$count',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: active ? AppColors.textPrimary : AppColors.textMuted)),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<DayBlock> blocks;
  final DayBlock? current;
  const _Timeline({required this.blocks, required this.current});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minute = now.hour * 60 + now.minute;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: blocks.map((b) {
          final isNow = b.id == current?.id;
          final isPast = b.endMinute <= minute;
          return Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: isNow ? b.kind.color : Colors.transparent, width: 3),
              ),
              color: isNow ? AppColors.surfaceRaised : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Opacity(
              opacity: isPast ? 0.45 : 1,
              child: Row(
                children: [
                  SizedBox(
                    width: 92,
                    child: Text(
                      '${formatMinuteOfDay(b.startMinute)}–${formatMinuteOfDay(b.endMinute)}',
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                          fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                  ),
                  Icon(b.kind.icon, size: 16, color: b.kind.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(b.label,
                        style: TextStyle(
                            fontWeight: isNow ? FontWeight.w700 : FontWeight.w500)),
                  ),
                  if (isNow)
                    const Text('AHORA',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.rustLight)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DayCloseCard extends StatelessWidget {
  final DayClose close;
  const _DayCloseCard({required this.close});

  @override
  Widget build(BuildContext context) {
    final String verdict;
    if (close.windowsSoFar == 0) {
      verdict = 'Todavía no abre tu primera ventana de negocio.';
    } else if (close.actionsOutside == 0 && close.windowsAttended == close.windowsSoFar) {
      verdict = 'Día enfocado: atendiste tus negocios solo en sus ventanas.';
    } else if (close.actionsOutside > close.actionsInWindow) {
      verdict = 'Hoy atendiste más fuera de ventana que dentro. Captura y espera tu bloque.';
    } else {
      verdict = 'Vas bien. Intenta no saltarte ninguna ventana.';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Stat(
                  value: '${close.windowsAttended}/${close.windowsSoFar}',
                  label: 'Ventanas atendidas'),
              _Stat(value: '${close.resolved}', label: 'Resueltos hoy'),
              _Stat(
                value: '${close.carriedOver}',
                label: 'Pasan a mañana',
                color: close.carriedOver > 0 ? AppColors.rustLight : null,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Capturaste ${close.captured} · '
            '${close.actionsInWindow} acciones en ventana · '
            '${close.actionsOutside} fuera',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(verdict, style: const TextStyle(fontSize: 13.5)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  const _Stat({required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: GoogleFonts.barlowCondensed(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: color ?? AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
