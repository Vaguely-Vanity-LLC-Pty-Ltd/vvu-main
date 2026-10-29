// VVU Unified Roof — SCADA views (overview, tactical, replay).
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/estate.dart';
import '../state/estate_state.dart';
import '../widgets/tokens.dart';

/// Estate KPI overview surface.
class OverviewView extends StatelessWidget {
  final EstateState state;
  const OverviewView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final experimental = state.flag('experimental_scada_grid');
        final accent = experimental ? const Color(0xFFFF2D9C) : VvuColors.twin;
        return Container(
          color: VvuColors.background,
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Row(
                children: [
                  const Text('ESTATE OVERVIEW', style: VvuTypography.h1),
                  const SizedBox(width: 12),
                  if (experimental)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(VvuRadii.sm),
                        border: Border.all(color: accent.withOpacity(0.4)),
                      ),
                      child: Text(
                        'EXPERIMENTAL GRID',
                        style: TextStyle(
                          fontFamily: VvuTypography.mono,
                          fontSize: 9,
                          letterSpacing: 1.4,
                          color: accent,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Live estate telemetry · ${state.nodes} nodes online',
                style: VvuTypography.body,
              ),
              const SizedBox(height: 16),
              // KPI grid
              LayoutBuilder(
                builder: (context, c) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _Kpi(
                        label: 'PRESSURE',
                        value: state.pipelinePressure.toStringAsFixed(2),
                        unit: 'bar',
                        accent: accent,
                        icon: Icons.compress_rounded,
                      ),
                      _Kpi(
                        label: 'FLOW',
                        value: state.flow.toStringAsFixed(1),
                        unit: 'l/s',
                        accent: accent,
                        icon: Icons.waves_rounded,
                      ),
                      _Kpi(
                        label: 'NODES',
                        value: '${state.nodes}',
                        unit: 'live',
                        accent: accent,
                        icon: Icons.hub_rounded,
                      ),
                      _Kpi(
                        label: 'GATES ARMED',
                        value: '${state.armedCount}',
                        unit: '/${state.totalCount}',
                        accent: accent,
                        icon: Icons.bolt_rounded,
                      ),
                      _Kpi(
                        label: 'BACKENDS',
                        value: '${state.backendsOnline}',
                        unit: '/4',
                        accent: accent,
                        icon: Icons.dns_rounded,
                      ),
                      _Kpi(
                        label: 'EVIDENCE',
                        value: '${state.evidenceCount}',
                        unit: 'sealed',
                        accent: accent,
                        icon: Icons.verified_rounded,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('SURFACES (25)', style: VvuTypography.labelMuted),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in kSurfaces)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: s.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(VvuRadii.sm),
                        border: Border.all(color: s.accent.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s.icon, size: 12, color: s.accent),
                          const SizedBox(width: 4),
                          Text(
                            s.name,
                            style: TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 10,
                              color: VvuColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('RECENT LOG', style: VvuTypography.labelMuted),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: VvuColors.panel,
                  borderRadius: BorderRadius.circular(VvuRadii.md),
                  border: Border.all(color: VvuColors.line),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    for (final e in state.wormLog.take(8))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              '#${e.seq.toString().padLeft(4, '0')}',
                              style: VvuTypography.micro,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${e.ts.hour.toString().padLeft(2, '0')}'
                              ':${e.ts.minute.toString().padLeft(2, '0')}'
                              ':${e.ts.second.toString().padLeft(2, '0')}',
                              style: VvuTypography.micro,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: VvuTypography.mono,
                                  fontSize: 10,
                                  color: VvuColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color accent;
  final IconData icon;
  const _Kpi({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VvuColors.panel,
        borderRadius: BorderRadius.circular(VvuRadii.md),
        border: Border.all(color: VvuColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(label, style: VvuTypography.labelMuted),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
              const SizedBox(width: 4),
              Text(unit, style: VvuTypography.micro),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tactical pipeline trace surface.
class TacticalMapView extends StatelessWidget {
  final EstateState state;
  const TacticalMapView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TACTICAL PIPELINE', style: VvuTypography.h1),
          const SizedBox(height: 4),
          Text(
            'Live trace across ${state.nodes} nodes · pressure ${state.pipelinePressure.toStringAsFixed(2)} bar',
            style: VvuTypography.body,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: VvuColors.panel,
                borderRadius: BorderRadius.circular(VvuRadii.md),
                border: Border.all(color: VvuColors.line),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(VvuRadii.md),
                child: CustomPaint(
                  painter: _TacticalPainter(state: state),
                  child: Container(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TacticalPainter extends CustomPainter {
  final EstateState state;
  _TacticalPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    // Grid.
    final gp = Paint()
      ..color = VvuColors.line
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gp);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);
    }

    // Nodes laid out on a sinusoidal pipeline.
    final nodes = <Offset>[];
    final count = 16;
    for (int i = 0; i < count; i++) {
      final t = i / (count - 1);
      final x = 40 + t * (size.width - 80);
      final y = size.height / 2 +
          sin(t * 6 + state.beat * 0.2) * (size.height * 0.25);
      nodes.add(Offset(x, y));
    }

    // Branch nodes.
    final branches = <Offset>[];
    for (final n in nodes) {
      for (int b = 0; b < 2; b++) {
        branches.add(Offset(
          n.dx + (rng.nextDouble() - 0.5) * 40,
          n.dy + (rng.nextDouble() - 0.5) * 80,
        ));
      }
    }

    // Branch links.
    final lineP = Paint()
      ..color = VvuColors.lineStrong
      ..strokeWidth = 1;
    for (int i = 0; i < nodes.length; i++) {
      for (int b = 0; b < 2; b++) {
        canvas.drawLine(nodes[i], branches[i * 2 + b], lineP);
      }
    }

    // Main pipeline.
    final pipePath = ui.Path()..moveTo(nodes.first.dx, nodes.first.dy);
    for (int i = 1; i < nodes.length; i++) {
      pipePath.lineTo(nodes[i].dx, nodes[i].dy);
    }
    canvas.drawPath(
      pipePath,
      Paint()
        ..color = VvuColors.twin
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Flow particles.
    for (int i = 0; i < nodes.length - 1; i++) {
      final phase = ((state.beat + i * 8) % 40) / 40;
      final p = Offset.lerp(nodes[i], nodes[i + 1], phase)!;
      canvas.drawCircle(p, 3, Paint()..color = VvuColors.armed);
    }

    // Nodes.
    for (final n in nodes) {
      canvas.drawCircle(n, 6, Paint()..color = VvuColors.twin);
      canvas.drawCircle(n, 3, Paint()..color = VvuColors.background);
    }
    for (final n in branches) {
      canvas.drawCircle(n, 2, Paint()..color = VvuColors.textFaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TacticalPainter old) =>
      old.state.beat != state.beat;
}

/// 31-day replay surface.
class ReplayView extends StatelessWidget {
  final EstateState state;
  const ReplayView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('REPLAY · 31 DAYS', style: VvuTypography.h1),
          const SizedBox(height: 4),
          const Text(
            'Scrub the estate timeline to replay evidence and verdicts.',
            style: VvuTypography.body,
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: VvuColors.panel,
              borderRadius: BorderRadius.circular(VvuRadii.md),
              border: Border.all(color: VvuColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(VvuRadii.md),
              child: CustomPaint(
                painter: _ReplayPainter(state: state),
                child: Container(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 800 ? 4 : 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    label: 'RUNS',
                    value: '${state.evidenceCount * 12 + 9240}',
                    accent: VvuColors.twin,
                  ),
                  _StatCard(
                    label: 'VERDICTS PROVEN',
                    value: '${state.evidenceCount * 8 + 7304}',
                    accent: VvuColors.armed,
                  ),
                  _StatCard(
                    label: 'INCONCLUSIVE',
                    value: '${state.evidenceCount * 2 + 1186}',
                    accent: VvuColors.warn,
                  ),
                  _StatCard(
                    label: 'BLOCKED',
                    value: '${state.evidenceCount + 47}',
                    accent: VvuColors.danger,
                  ),
                ].take(cols * 2).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VvuColors.panel,
        borderRadius: BorderRadius.circular(VvuRadii.md),
        border: Border.all(color: VvuColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: VvuTypography.labelMuted),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplayPainter extends CustomPainter {
  final EstateState state;
  _ReplayPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(7);
    final days = 31;
    final colW = size.width / days;
    // Axis.
    canvas.drawLine(
      Offset(0, size.height - 16),
      Offset(size.width, size.height - 16),
      Paint()..color = VvuColors.line,
    );

    for (int d = 0; d < days; d++) {
      final v = rng.nextDouble();
      final h = (v * (size.height - 30));
      final rect = Rect.fromLTWH(
        d * colW + 2,
        size.height - 16 - h,
        colW - 4,
        h,
      );
      final color = v > 0.7
          ? VvuColors.armed
          : v > 0.4
              ? VvuColors.twin
              : VvuColors.warn;
      canvas.drawRect(
        rect,
        Paint()..color = color.withOpacity(0.65),
      );
      if (d == (state.beat) % days) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = VvuColors.text
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReplayPainter old) =>
      old.state.beat != state.beat;
}
