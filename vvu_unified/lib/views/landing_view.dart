// VVU Unified Roof — Landing page (SimpliSafe-style marketing surface).
import 'dart:math';

import 'package:flutter/material.dart';

import '../state/estate_state.dart';
import '../widgets/tokens.dart';

/// Public marketing & pilot entry surface.
class LandingView extends StatelessWidget {
  final EstateState state;
  final void Function(String surfaceId)? onNavigate;
  const LandingView({super.key, required this.state, this.onNavigate});

  static const _accent = VvuColors.twin;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Hero
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 56),
              constraints: const BoxConstraints(maxWidth: 1200),
              child: LayoutBuilder(
                builder: (context, c) {
                  final narrow = c.maxWidth < 800;
                  return Flex(
                    direction: narrow ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.12),
                                borderRadius:
                                    BorderRadius.circular(VvuRadii.sm),
                                border: Border.all(
                                    color: _accent.withOpacity(0.4)),
                              ),
                              child: const Text(
                                'VVU UNIFIED ROOF · OPERATIONAL CONTROL ROOM',
                                style: TextStyle(
                                  fontFamily: VvuTypography.mono,
                                  fontSize: 10,
                                  letterSpacing: 1.6,
                                  color: _accent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Stop pipeline failures\nbefore they start.',
                              style: TextStyle(
                                fontFamily: VvuTypography.mono,
                                fontSize: 40,
                                height: 1.1,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                color: VvuColors.text,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'A 25-surface operational control room for the Venture Vision Ubuntu estate. Five inference gates seal evidence to a WORM chain in milliseconds — long before a degraded sensor becomes a failed pipeline.',
                              style: TextStyle(
                                fontFamily: VvuTypography.sans,
                                fontSize: 15,
                                height: 1.6,
                                color: VvuColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _CtaButton(
                                  label: 'START YOUR PILOT',
                                  accent: _accent,
                                  filled: true,
                                  onTap: () => onNavigate?.call('store'),
                                ),
                                _CtaButton(
                                  label: 'SEE IT LIVE',
                                  accent: VvuColors.text,
                                  filled: false,
                                  onTap: () => onNavigate?.call('twin'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32, height: 32),
                      Expanded(
                        child: SizedBox(
                          height: 360,
                          child: _ScadaMock(state: state),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Stats bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: VvuColors.panel,
              child: const Center(
                child: Text(
                  '5 Inference Gates · 25 Surfaces · 7-Stage Evidence Lifecycle · 0 Mock Data',
                  style: TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 12,
                    letterSpacing: 1.6,
                    color: VvuColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Value props
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 48),
              constraints: const BoxConstraints(maxWidth: 1200),
              child: LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth > 800 ? 4 : 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _ValueProp(
                        icon: Icons.link_rounded,
                        title: 'WORM Evidence Chain',
                        body:
                            'Every verdict is sealed to a write-once, read-many chain with FNV1a hashes.',
                        accent: VvuColors.armed,
                      ),
                      _ValueProp(
                        icon: Icons.health_and_safety_rounded,
                        title: '4-State Health Model',
                        body:
                            'Healthy, degraded, blocked, unknown — explicit states, never silent.',
                        accent: VvuColors.twin,
                      ),
                      _ValueProp(
                        icon: Icons.verified_user_rounded,
                        title: 'POPIA Compliant',
                        body:
                            'Built for South African data residency and POPIA discipline.',
                        accent: VvuColors.studio,
                      ),
                      _ValueProp(
                        icon: Icons.diversity_3_rounded,
                        title: 'B-BBEE Level 1',
                        body:
                            'Vaguely Vanity LLC (Pty) Ltd — verified B-BBEE Level 1 contributor.',
                        accent: const Color(0xFFA3E635),
                      ),
                    ].take(cols * 2).toList(),
                  );
                },
              ),
            ),
            // Pricing teaser
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 32),
              color: VvuColors.panel,
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'PRICING',
                      style: TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 12,
                        letterSpacing: 2,
                        color: VvuColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'From R99/month',
                      style: TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilot, scale, or enterprise — the WORM chain runs identically.',
                      style: TextStyle(
                        fontFamily: VvuTypography.sans,
                        fontSize: 13,
                        color: VvuColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CtaButton(
                      label: 'VIEW PLANS',
                      accent: _accent,
                      filled: true,
                      onTap: () => onNavigate?.call('store'),
                    ),
                  ],
                ),
              ),
            ),
            // Trust footer
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 24),
              color: VvuColors.ink,
              child: const Center(
                child: Text(
                  'Vaguely Vanity LLC (Pty) Ltd · CIPC 2026/259053/07 · WORM Anchor E965B01D · Gqeberha, ZA',
                  style: TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 10,
                    letterSpacing: 1.4,
                    color: VvuColors.textFaint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final Color accent;
  final bool filled;
  final VoidCallback onTap;
  const _CtaButton({
    required this.label,
    required this.accent,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VvuRadii.md),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: filled ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(VvuRadii.md),
            border: Border.all(
              color: filled ? accent : VvuColors.lineStrong,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 12,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w600,
              color: filled ? VvuColors.background : accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueProp extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color accent;
  const _ValueProp({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VvuColors.panel,
        borderRadius: BorderRadius.circular(VvuRadii.md),
        border: Border.all(color: VvuColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(VvuRadii.md),
              border: Border.all(color: accent.withOpacity(0.4)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: VvuColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontFamily: VvuTypography.sans,
              fontSize: 12,
              height: 1.5,
              color: VvuColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live SCADA dashboard mock.
class _ScadaMock extends StatelessWidget {
  final EstateState state;
  const _ScadaMock({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VvuColors.panel,
        borderRadius: BorderRadius.circular(VvuRadii.lg),
        border: Border.all(color: VvuColors.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(VvuRadii.lg),
        child: CustomPaint(
          painter: _ScadaMockPainter(state: state),
          child: Container(),
        ),
      ),
    );
  }
}

class _ScadaMockPainter extends CustomPainter {
  final EstateState state;
  _ScadaMockPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(11);
    // Background grid.
    final gp = Paint()
      ..color = VvuColors.line
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gp);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);
    }

    // Top header.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 24),
      Paint()..color = VvuColors.panelRaised,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'VVU · LIVE',
        style: TextStyle(
          fontFamily: VvuTypography.mono,
          fontSize: 10,
          color: VvuColors.twin,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(8, 7));

    // Beat rail.
    for (int i = 0; i < 8; i++) {
      final active = (state.beat + i) % 8 < 3;
      canvas.drawRect(
        Rect.fromLTWH(size.width - 80 + i * 8, 8, 6, 8),
        Paint()
          ..color = active
              ? VvuColors.beat.withOpacity(0.85)
              : VvuColors.line,
      );
    }

    // Pressure line.
    final path = Path();
    final n = 60;
    for (int i = 0; i <= n; i++) {
      final x = (i / n) * (size.width - 16) + 8;
      final y = 60 +
          sin((i / n) * 6 + state.beat * 0.2) * 18 +
          (rng.nextDouble() - 0.5) * 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = VvuColors.twin
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Flow line.
    final path2 = Path();
    for (int i = 0; i <= n; i++) {
      final x = (i / n) * (size.width - 16) + 8;
      final y = 130 +
          cos((i / n) * 5 + state.beat * 0.15) * 22 +
          (rng.nextDouble() - 0.5) * 4;
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path2,
      Paint()
        ..color = VvuColors.armed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // KPI chips.
    final chips = [
      ('PRESSURE', '${state.pipelinePressure.toStringAsFixed(2)} bar', VvuColors.twin),
      ('FLOW', '${state.flow.toStringAsFixed(1)} l/s', VvuColors.armed),
      ('NODES', '${state.nodes}', VvuColors.studio),
      ('GATES', '${state.armedCount}/${state.totalCount}', VvuColors.armed),
    ];
    for (int i = 0; i < chips.length; i++) {
      final c = chips[i];
      final rect = Rect.fromLTWH(
        8 + (i % 2) * (size.width / 2 - 12),
        180 + (i ~/ 2) * 60,
        size.width / 2 - 16,
        52,
      );
      canvas.drawRect(
        rect,
        Paint()..color = VvuColors.panelRaised,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = VvuColors.line
          ..style = PaintingStyle.stroke,
      );
      final l1 = TextPainter(
        text: TextSpan(
          text: c.$1,
          style: const TextStyle(
            fontFamily: VvuTypography.mono,
            fontSize: 9,
            color: VvuColors.textMuted,
            letterSpacing: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      l1.paint(canvas, Offset(rect.left + 8, rect.top + 6));
      final l2 = TextPainter(
        text: TextSpan(
          text: c.$2,
          style: TextStyle(
            fontFamily: VvuTypography.mono,
            fontSize: 16,
            color: c.$3,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      l2.paint(canvas, Offset(rect.left + 8, rect.top + 22));
    }
  }

  @override
  bool shouldRepaint(covariant _ScadaMockPainter old) =>
      old.state.beat != state.beat;
}


