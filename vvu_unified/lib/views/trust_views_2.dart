// VVU Unified Roof — Trust UI views part 2 (spatial, surv, twin-hologram).
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/api_client.dart';
import '../state/estate_state.dart';
import '../widgets/tokens.dart';

// ── Spatial (Lemon-tree asset register via SafeGridApi) ───────────────────

class SpatialView extends StatefulWidget {
  final EstateState state;
  const SpatialView({super.key, required this.state});

  @override
  State<SpatialView> createState() => _SpatialViewState();
}

class _SpatialViewState extends State<SpatialView> {
  static const _accent = Color(0xFFA3E635);
  List<Map<String, dynamic>> _assets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await SafeGridApi.getAssets();
    if (!r.ok || r.data == null) {
      setState(() {
        _loading = false;
        _error = r.error ?? 'Failed to load assets';
        _assets = _seedAssets();
      });
      return;
    }
    setState(() {
      _loading = false;
      _assets = r.data!.cast<Map<String, dynamic>>();
      if (_assets.isEmpty) _assets = _seedAssets();
    });
  }

  List<Map<String, dynamic>> _seedAssets() => [
        {
          'id': 'a1',
          'name': 'Lemon Tree 01',
          'kind': 'tree',
          'lat': -33.9608,
          'lng': 25.6022,
          'health': 0.92,
        },
        {
          'id': 'a2',
          'name': 'Lemon Tree 02',
          'kind': 'tree',
          'lat': -33.9585,
          'lng': 25.6055,
          'health': 0.74,
        },
        {
          'id': 'a3',
          'name': 'Lemon Tree 03',
          'kind': 'tree',
          'lat': -33.9620,
          'lng': 25.5998,
          'health': 0.41,
        },
        {
          'id': 'a4',
          'name': 'Irrigation Valve',
          'kind': 'valve',
          'lat': -33.9595,
          'lng': 25.6010,
          'health': 0.95,
        },
      ];

  Color _healthColor(dynamic h) {
    final v = (h is num ? h.toDouble() : 0.5).clamp(0.0, 1.0);
    if (v > 0.75) return VvuColors.armed;
    if (v > 0.5) return VvuColors.warn;
    return VvuColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                  child: const Icon(Icons.park_rounded,
                      size: 18, color: _accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SPATIAL', style: VvuTypography.h1),
                      Text(
                        'Lemon-tree asset register · ${_assets.length} assets',
                        style: VvuTypography.body,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  color: _accent,
                  tooltip: 'Reload assets',
                ),
              ],
            ),
          ),
          if (_error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: VvuColors.danger.withOpacity(0.10),
                borderRadius: BorderRadius.circular(VvuRadii.sm),
                border:
                    Border.all(color: VvuColors.danger.withOpacity(0.4)),
              ),
              child: Text(
                'Backend offline — showing local fallback. $_error',
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 10,
                  color: VvuColors.danger,
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _accent),
                  )
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(-33.9608, 25.6022),
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName: 'za.vvu.unified',
                      ),
                      MarkerLayer(
                        markers: [
                          for (final a in _assets)
                            Marker(
                              point: LatLng(
                                (a['lat'] as num?)?.toDouble() ?? -33.9608,
                                (a['lng'] as num?)?.toDouble() ?? 25.6022,
                              ),
                              width: 30,
                              height: 30,
                              child: Tooltip(
                                message:
                                    '${a['name']} · health ${a['health']}',
                                child: Icon(
                                  Icons.location_on,
                                  size: 22,
                                  color: _healthColor(a['health']),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Surv (feeds via SafeGridApi.getFeeds) ─────────────────────────────────

class SurvView extends StatefulWidget {
  final EstateState state;
  const SurvView({super.key, required this.state});

  @override
  State<SurvView> createState() => _SurvViewState();
}

class _SurvViewState extends State<SurvView> {
  static const _accent = Color(0xFFA3E635);
  List<Map<String, dynamic>> _feeds = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await SafeGridApi.getFeeds();
    if (!r.ok || r.data == null) {
      setState(() {
        _loading = false;
        _error = r.error ?? 'Failed to load feeds';
        _feeds = _seedFeeds();
      });
      return;
    }
    setState(() {
      _loading = false;
      _feeds = r.data!.cast<Map<String, dynamic>>();
      if (_feeds.isEmpty) _feeds = _seedFeeds();
    });
  }

  List<Map<String, dynamic>> _seedFeeds() => List.generate(
        8,
        (i) => {
          'id': 'f${i + 1}',
          'name': 'CAM-${(i + 1).toString().padLeft(2, '0')}',
          'status': i == 2 ? 'TAMPERED' : 'CLEAN',
          'fps': 30 - i,
        },
      );

  @override
  Widget build(BuildContext context) {
    final showBadges = widget.state.flag('surv_clean_badges');
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
                child: const Icon(Icons.videocam_rounded,
                    size: 18, color: _accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SURV', style: VvuTypography.h1),
                    Text(
                      'Surveillance feeds · ${_feeds.length} channels',
                      style: VvuTypography.body,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                color: _accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: VvuColors.danger.withOpacity(0.10),
                borderRadius: BorderRadius.circular(VvuRadii.sm),
                border:
                    Border.all(color: VvuColors.danger.withOpacity(0.4)),
              ),
              child: Text(
                'Backend offline — local fallback. $_error',
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 10,
                  color: VvuColors.danger,
                ),
              ),
            ),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: _accent),
              ),
            )
          else
            for (final f in _feeds)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VvuColors.panel,
                  borderRadius: BorderRadius.circular(VvuRadii.md),
                  border: Border.all(color: VvuColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.videocam_rounded,
                        size: 16, color: _accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (f['name'] ?? '—').toString(),
                            style: const TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 12,
                              color: VvuColors.text,
                            ),
                          ),
                          Text(
                            '${f['fps'] ?? '—'} fps',
                            style: VvuTypography.micro,
                          ),
                        ],
                      ),
                    ),
                    if (showBadges)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (f['status'] == 'CLEAN'
                                  ? VvuColors.armed
                                  : VvuColors.danger)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(VvuRadii.sm),
                          border: Border.all(
                            color: (f['status'] == 'CLEAN'
                                    ? VvuColors.armed
                                    : VvuColors.danger)
                                .withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          (f['status'] ?? '—').toString(),
                          style: TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: f['status'] == 'CLEAN'
                                ? VvuColors.armed
                                : VvuColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

// ── Twin Hologram (animated Fresnel sphere) ───────────────────────────────

class TwinHologramView extends StatefulWidget {
  final EstateState state;
  const TwinHologramView({super.key, required this.state});

  @override
  State<TwinHologramView> createState() => _TwinHologramViewState();
}

class _TwinHologramViewState extends State<TwinHologramView>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFFA3E635);
  late final AnimationController _ctrl;
  int _stage = 0;

  static const _stages = [
    'DORMANT',
    'ARMING',
    'PHOTOMETRIC SCAN',
    'MESH RECONSTRUCT',
    'EVIDENCE SEAL',
    'VERDICT',
    'STAND-DOWN',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.state.flag('twin_hologram_mode');
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
                child: const Icon(Icons.threed_rotation_rounded,
                    size: 18, color: _accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TWIN HOLOGRAM', style: VvuTypography.h1),
                    Text(
                      'Fresnel wireframe · 7-stage lifecycle',
                      style: VvuTypography.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!enabled)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: VvuColors.warn.withOpacity(0.10),
                borderRadius: BorderRadius.circular(VvuRadii.sm),
                border: Border.all(color: VvuColors.warn.withOpacity(0.4)),
              ),
              child: Text(
                'twin_hologram_mode flag is OFF · sphere renders as static wireframe',
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 10,
                  color: VvuColors.warn,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            height: 360,
            decoration: BoxDecoration(
              color: VvuColors.panel,
              borderRadius: BorderRadius.circular(VvuRadii.md),
              border: Border.all(color: VvuColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(VvuRadii.md),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _FresnelPainter(
                      t: enabled ? _ctrl.value : 0,
                      accent: _accent,
                      stage: _stage,
                    ),
                    child: Container(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (int i = 0; i < _stages.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _stage = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _stage == i
                          ? _accent.withOpacity(0.18)
                          : VvuColors.ink,
                      borderRadius: BorderRadius.circular(VvuRadii.sm),
                      border: Border.all(
                        color: _stage == i
                            ? _accent.withOpacity(0.5)
                            : VvuColors.line,
                      ),
                    ),
                    child: Text(
                      '${i + 1} · ${_stages[i]}',
                      style: TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 10,
                        color: _stage == i ? _accent : VvuColors.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FresnelPainter extends CustomPainter {
  final double t;
  final Color accent;
  final int stage;
  _FresnelPainter({
    required this.t,
    required this.accent,
    required this.stage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide * 0.32;

    // Ghost rings (rotating orbits).
    for (int i = 0; i < 3; i++) {
      final path = ui.Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r * (1.2 + i * 0.18)));
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(t * 2 * pi * (0.3 + i * 0.1) * (i % 2 == 0 ? 1 : -1));
      canvas.translate(-cx, -cy);
      canvas.drawPath(
        path,
        Paint()
          ..color = accent.withOpacity(0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.restore();
    }

    // Wireframe sphere via latitude/longitude lines.
    final segments = 18;
    final lonPaint = Paint()
      ..color = accent.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final latPaint = Paint()
      ..color = accent.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Longitude.
    for (int i = 0; i < segments; i++) {
      final angle = (i / segments) * pi + t * 2 * pi;
      final path = ui.Path();
      for (int j = 0; j <= 40; j++) {
        final v = (j / 40) * pi;
        final x = cx + r * sin(v) * cos(angle);
        final y = cy + r * cos(v);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, lonPaint);
    }
    // Latitude.
    for (int i = 1; i < 9; i++) {
      final v = (i / 9) * pi;
      final y = cy + r * cos(v);
      final rx = r * sin(v);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, y), width: rx * 2, height: rx * 0.5),
        latPaint,
      );
    }

    // Stage marker dot.
    final phase = stage / 7;
    canvas.drawCircle(
      Offset(
        cx + r * sin(phase * 2 * pi + t) * 0.6,
        cy + r * cos(phase * 2 * pi + t) * 0.6,
      ),
      4,
      Paint()..color = accent,
    );

    // Centre glow.
    canvas.drawCircle(
      Offset(cx, cy),
      6,
      Paint()..color = accent.withOpacity(0.4 + 0.4 * sin(t * 2 * pi)),
    );
  }

  @override
  bool shouldRepaint(covariant _FresnelPainter old) =>
      old.t != t || old.stage != stage;
}
