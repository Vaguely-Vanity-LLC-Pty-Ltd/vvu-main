// VVU Unified Roof — Gameplay surface (launcher & phase overview).
import 'dart:js' as js;
import 'dart:js_interop';

import 'package:flutter/material.dart';

import '../state/estate_state.dart';
import '../widgets/tokens.dart';

@JS('window.open')
external void _windowOpen(String? url, String? target, String? features);

void _launch(String url) {
  try {
    _windowOpen(url, '_blank', 'noopener,noreferrer');
  } catch (_) {
    // Fallback to the older dart:js interop if dart:js_interop fails.
    try {
      js.context.callMethod('open', [url, '_blank']);
    } catch (_) {
      // Best-effort — ignore.
    }
  }
}

/// PLAY surface: launch cards, phase overview, 3D model cards, stats.
class PlayView extends StatelessWidget {
  final EstateState state;
  const PlayView({super.key, required this.state});

  static const _accent = Color(0xFF00E5FF);

  static const _launchers = [
    (
      'Edge of Oblivion',
      'Single-player campaign across the VVU estate.',
      'http://localhost:8091/vvu_edge_of_oblivion.html',
      Icons.rocket_launch_rounded,
    ),
    (
      'Operator Deployment',
      'Multiplayer tactical deployment simulation.',
      'http://localhost:8091/vvu_operator_deployment.html',
      Icons.security_rounded,
    ),
  ];

  static const _phases = [
    ('ORBIT', 'Recon & orbital insertion', Icons.satellite_alt_rounded),
    ('BOARDING', 'Airlock breach & entry', Icons.sensor_door_rounded),
    ('LOADOUT', 'Weapons, kits & augmentations', Icons.inventory_2_rounded),
    ('CQC', 'Close-quarters combat', Icons.gps_fixed_rounded),
  ];

  static const _models = [
    ('COMBAT DRONE', 'Autonomous aerial unit', Icons.flight_rounded),
    ('KILLCODE', 'Cyber-warfare payload', Icons.code_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(VvuRadii.md),
                  border: Border.all(color: _accent.withOpacity(0.4)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.sports_esports_rounded,
                    size: 18, color: _accent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PLAY', style: VvuTypography.h1),
                    Text(
                      'Gameplay launcher · phases · 3D models.',
                      style: VvuTypography.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Launch cards
          LayoutBuilder(
            builder: (context, c) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final g in _launchers)
                    Container(
                      width: 340,
                      padding: const EdgeInsets.all(16),
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
                              Icon(g.$4, size: 18, color: _accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  g.$1,
                                  style: const TextStyle(
                                    fontFamily: VvuTypography.mono,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: VvuColors.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            g.$2,
                            style: const TextStyle(
                              fontFamily: VvuTypography.sans,
                              fontSize: 12,
                              height: 1.4,
                              color: VvuColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _launch(g.$3),
                              borderRadius: BorderRadius.circular(VvuRadii.sm),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.14),
                                  borderRadius:
                                      BorderRadius.circular(VvuRadii.sm),
                                  border: Border.all(
                                      color: _accent.withOpacity(0.5)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.open_in_new_rounded,
                                        size: 14, color: _accent),
                                    SizedBox(width: 6),
                                    Text(
                                      'LAUNCH',
                                      style: TextStyle(
                                        fontFamily: VvuTypography.mono,
                                        fontSize: 10,
                                        letterSpacing: 1.6,
                                        fontWeight: FontWeight.w600,
                                        color: _accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            g.$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: VvuTypography.micro,
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // Phases
          const Text('MISSION PHASES', style: VvuTypography.labelMuted),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, c) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (int i = 0; i < _phases.length; i++)
                    Container(
                      width: 220,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: VvuColors.panel,
                        borderRadius: BorderRadius.circular(VvuRadii.md),
                        border: Border.all(color: VvuColors.line),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(VvuRadii.sm),
                              border: Border.all(
                                  color: _accent.withOpacity(0.4)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontFamily: VvuTypography.mono,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _phases[i].$1,
                                  style: const TextStyle(
                                    fontFamily: VvuTypography.mono,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: VvuColors.text,
                                  ),
                                ),
                                Text(
                                  _phases[i].$2,
                                  style: TextStyle(
                                    fontFamily: VvuTypography.sans,
                                    fontSize: 11,
                                    color: VvuColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(_phases[i].$3, size: 16, color: _accent),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // 3D model cards
          const Text('3D MODELS', style: VvuTypography.labelMuted),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final m in _models)
                Container(
                  width: 240,
                  height: 140,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VvuColors.panel,
                    borderRadius: BorderRadius.circular(VvuRadii.md),
                    border: Border.all(color: VvuColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(m.$3, size: 28, color: _accent),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.$1,
                            style: const TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: VvuColors.text,
                            ),
                          ),
                          Text(
                            m.$2,
                            style: TextStyle(
                              fontFamily: VvuTypography.sans,
                              fontSize: 11,
                              color: VvuColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Game stats
          const Text('GAME STATS', style: VvuTypography.labelMuted),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: VvuColors.panel,
              borderRadius: BorderRadius.circular(VvuRadii.md),
              border: Border.all(color: VvuColors.line),
            ),
            child: LayoutBuilder(
              builder: (context, c) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _Stat('PLAYERS', '1284', _accent),
                    _Stat('SESSIONS', '9240', _accent),
                    _Stat('KILLCODE DEPLOYS', '472', _accent),
                    _Stat('WIN RATE', '64%', _accent),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _Stat(this.label, this.value, this.accent);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: VvuTypography.micro),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
