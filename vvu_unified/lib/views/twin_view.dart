// VVU Unified Roof — Twin view (live digital-twin roof).
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/estate.dart';
import '../state/estate_state.dart';
import '../widgets/inference_switch.dart';
import '../widgets/map_view_dropdown.dart';
import '../widgets/tokens.dart';

/// The 3-column twin surface: operator rail · map · gates rail.
class TwinView extends StatelessWidget {
  final EstateState state;
  const TwinView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OperatorRail(state: state),
        const VerticalDivider(width: 1, color: VvuColors.line),
        Expanded(child: _MapColumn(state: state)),
        const VerticalDivider(width: 1, color: VvuColors.line),
        _GatesRail(state: state),
      ],
    );
  }
}

class _OperatorRail extends StatelessWidget {
  final EstateState state;
  const _OperatorRail({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: VvuColors.panel,
      padding: const EdgeInsets.all(12),
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          return ListView(
            children: [
              const Text('TAKEOFF POSTURE', style: VvuTypography.labelMuted),
              const SizedBox(height: 8),
              _PostureCard(state: state),
              const SizedBox(height: 16),
              const Text('TELEMETRY', style: VvuTypography.labelMuted),
              const SizedBox(height: 8),
              _TelemetryRow(
                  label: 'PRESSURE',
                  value: '${state.pipelinePressure.toStringAsFixed(2)} bar',
                  accent: VvuColors.twin),
              _TelemetryRow(
                  label: 'FLOW',
                  value: '${state.flow.toStringAsFixed(1)} l/s',
                  accent: VvuColors.armed),
              _TelemetryRow(
                  label: 'NODES',
                  value: '${state.nodes} live',
                  accent: VvuColors.studio),
              _TelemetryRow(
                  label: 'EVIDENCE',
                  value: '${state.evidenceCount} sealed',
                  accent: VvuColors.twin),
              const SizedBox(height: 16),
              const Text('REPLAY SCRUBBER', style: VvuTypography.labelMuted),
              const SizedBox(height: 8),
              _ReplayScrubber(),
              const SizedBox(height: 16),
              const Text('WORM CHAIN', style: VvuTypography.labelMuted),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VvuColors.panelRaised,
                  borderRadius: BorderRadius.circular(VvuRadii.sm),
                  border: Border.all(color: VvuColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Anchor ${state.wormAnchor}',
                        style: VvuTypography.micro),
                    const SizedBox(height: 4),
                    Text(
                      state.chainIntact ? 'INTACT' : 'BROKEN',
                      style: TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 11,
                        letterSpacing: 1.4,
                        color: state.chainIntact
                            ? VvuColors.armed
                            : VvuColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PostureCard extends StatelessWidget {
  final EstateState state;
  const _PostureCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final armed = state.takeoffArmed;
    final color = armed ? VvuColors.armed : VvuColors.textMuted;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: armed ? VvuColors.armed.withOpacity(0.10) : VvuColors.panelRaised,
        borderRadius: BorderRadius.circular(VvuRadii.md),
        border: Border.all(
          color: armed ? VvuColors.armed.withOpacity(0.5) : VvuColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                armed ? Icons.power_rounded : Icons.power_off_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                armed ? 'ARMED' : 'STAND-BY',
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 12,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            armed
                ? 'All 5 inference gates armed. Takeoff ready.'
                : 'Disarm & stand-down posture. No gates will fire.',
            style: const TextStyle(
              fontFamily: VvuTypography.sans,
              fontSize: 11,
              height: 1.4,
              color: VvuColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _TelemetryRow({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: VvuTypography.micro),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 11,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplayScrubber extends StatefulWidget {
  @override
  State<_ReplayScrubber> createState() => _ReplayScrubberState();
}

class _ReplayScrubberState extends State<_ReplayScrubber> {
  double _pos = 0.5;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: VvuColors.twin,
            inactiveTrackColor: VvuColors.line,
            thumbColor: VvuColors.twin,
            overlayColor: VvuColors.twin.withOpacity(0.2),
            trackHeight: 2,
          ),
          child: Slider(
            value: _pos,
            onChanged: (v) => setState(() => _pos = v),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('T-31d', style: VvuTypography.micro),
            Text(
              'T-${(31 - (_pos * 31)).round()}d',
              style: VvuTypography.micro,
            ),
            Text('T-0', style: VvuTypography.micro),
          ],
        ),
      ],
    );
  }
}

class _MapColumn extends StatelessWidget {
  final EstateState state;
  const _MapColumn({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MapToolbar(state: state),
        const Divider(height: 1, color: VvuColors.line),
        Expanded(child: _MapHost(state: state)),
      ],
    );
  }
}

class _MapToolbar extends StatelessWidget {
  final EstateState state;
  const _MapToolbar({required this.state});

  @override
  Widget build(BuildContext context) {
    final accent = VvuColors.twin;
    return Container(
      height: 40,
      color: VvuColors.panel,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          MapViewDropdown(
            value: state.activeMapView,
            onChange: state.setMapView,
            accent: accent,
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            label: 'RESET',
            icon: Icons.refresh_rounded,
            accent: accent,
            onTap: () {
              state.mapController.move(state.mapCenter, 13);
            },
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            label: 'GQEBERHA',
            icon: Icons.place_rounded,
            accent: accent,
            onTap: () {
              state.mapController.move(
                const LatLng(-33.9608, 25.6022),
                13,
              );
            },
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            label: 'NMU',
            icon: Icons.school_rounded,
            accent: accent,
            onTap: () {
              state.mapController.move(
                const LatLng(-33.9320, 25.5700),
                14,
              );
            },
          ),
          const Spacer(),
          ListenableBuilder(
            listenable: state,
            builder: (context, _) => Text(
              'GATES ${state.armedCount}/${state.totalCount}',
              style: VvuTypography.labelMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  const _ToolbarButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: VvuColors.panelRaised,
            borderRadius: BorderRadius.circular(VvuRadii.sm),
            border: Border.all(color: VvuColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: accent),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  color: VvuColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapHost extends StatelessWidget {
  final EstateState state;
  const _MapHost({required this.state});

  @override
  Widget build(BuildContext context) {
    final view = kMapViews.firstWhere(
      (v) => v.id == state.activeMapView,
      orElse: () => kMapViews.first,
    );

    if (view.synthetic) {
      return _SyntheticMapHost(view: view, state: state);
    }

    return FlutterMap(
      mapController: state.mapController,
      options: MapOptions(
        initialCenter: state.mapCenter,
        initialZoom: 13,
        minZoom: 3,
        maxZoom: 19,
      ),
      children: [
        TileLayer(
          urlTemplate: view.tileUrlPattern,
          userAgentPackageName: 'za.vvu.unified',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: const LatLng(-33.9608, 25.6022),
              width: 30,
              height: 30,
              child: const Icon(
                Icons.location_on,
                size: 22,
                color: VvuColors.twin,
              ),
            ),
            Marker(
              point: const LatLng(-33.9320, 25.5700),
              width: 30,
              height: 30,
              child: const Icon(
                Icons.location_on,
                size: 22,
                color: VvuColors.studio,
              ),
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: const [
                LatLng(-33.9608, 25.6022),
                LatLng(-33.9460, 25.5860),
                LatLng(-33.9320, 25.5700),
              ],
              color: VvuColors.armed.withOpacity(0.7),
              strokeWidth: 2,
            ),
          ],
        ),
      ],
    );
  }
}

/// Synthetic map host for twin-mesh / dinsar-overlay / fused-tactical.
class _SyntheticMapHost extends StatelessWidget {
  final MapViewEntry view;
  final EstateState state;
  const _SyntheticMapHost({required this.view, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SyntheticMapPainter(view: view, beat: state.beat),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: VvuColors.panel.withOpacity(0.85),
                borderRadius: BorderRadius.circular(VvuRadii.sm),
                border: Border.all(color: VvuColors.lineStrong),
              ),
              child: Text(
                '${view.name} · ${view.tile}',
                style: VvuTypography.labelMuted,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: VvuColors.panel.withOpacity(0.85),
                borderRadius: BorderRadius.circular(VvuRadii.sm),
                border: Border.all(color: VvuColors.lineStrong),
              ),
              child: Text(
                'SYNTHETIC · NO LIVE TILE',
                style: VvuTypography.micro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyntheticMapPainter extends CustomPainter {
  final MapViewEntry view;
  final int beat;
  _SyntheticMapPainter({required this.view, required this.beat});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(view.id.hashCode);
    // Dark base.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = VvuColors.background,
    );

    // Grid.
    final gridPaint = Paint()
      ..color = VvuColors.line
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (view.id == 'twin-mesh') {
      // Wireframe mesh triangles.
      final p = Paint()
        ..color = VvuColors.twin.withOpacity(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      final path = ui.Path();
      for (int i = 0; i < 60; i++) {
        final x1 = rng.nextDouble() * size.width;
        final y1 = rng.nextDouble() * size.height;
        final x2 = x1 + (rng.nextDouble() - 0.5) * 80;
        final y2 = y1 + (rng.nextDouble() - 0.5) * 80;
        final x3 = x1 + (rng.nextDouble() - 0.5) * 80;
        final y3 = y1 + (rng.nextDouble() - 0.5) * 80;
        path
          ..moveTo(x1, y1)
          ..lineTo(x2, y2)
          ..lineTo(x3, y3)
          ..close();
      }
      canvas.drawPath(path, p);
      // Pulsing centre.
      final cx = size.width / 2 + sin(beat * 0.4) * 12;
      final cy = size.height / 2 + cos(beat * 0.3) * 12;
      canvas.drawCircle(
        Offset(cx, cy),
        6,
        Paint()..color = VvuColors.twin,
      );
    } else if (view.id == 'dinsar-overlay') {
      // Interferogram-style concentric rings.
      final cx = size.width / 2;
      final cy = size.height / 2;
      final colors = [
        VvuColors.danger,
        VvuColors.warn,
        VvuColors.armed,
        VvuColors.twin,
        VvuColors.studio,
      ];
      for (int i = 12; i > 0; i--) {
        final r = i * 28.0;
        canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()..color = colors[i % colors.length].withOpacity(0.18),
        );
      }
      // Displacement vector.
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + 40, cy - 24),
        Paint()
          ..color = VvuColors.text
          ..strokeWidth = 1.5,
      );
    } else if (view.id == 'fused-tactical') {
      // Sensor-fusion nodes & links.
      final nodes = <Offset>[];
      for (int i = 0; i < 14; i++) {
        nodes.add(Offset(
          rng.nextDouble() * size.width,
          rng.nextDouble() * size.height,
        ));
      }
      final linePaint = Paint()
        ..color = VvuColors.armed.withOpacity(0.5)
        ..strokeWidth = 1;
      for (int i = 0; i < nodes.length; i++) {
        for (int j = i + 1; j < nodes.length; j++) {
          if ((nodes[i] - nodes[j]).distance < 160) {
            canvas.drawLine(nodes[i], nodes[j], linePaint);
          }
        }
      }
      for (final n in nodes) {
        canvas.drawCircle(
          n,
          4,
          Paint()..color = VvuColors.beat,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SyntheticMapPainter old) =>
      old.beat != beat || old.view.id != view.id;
}

class _GatesRail extends StatelessWidget {
  final EstateState state;
  const _GatesRail({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      color: VvuColors.panel,
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('INFERENCE GATES', style: VvuTypography.h2),
              ),
              Text(
                '${state.armedCount}/${state.totalCount}',
                style: VvuTypography.labelMuted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _RailAction(
                label: 'ARM ALL',
                color: VvuColors.armed,
                onTap: state.armAll,
              ),
              const SizedBox(width: 6),
              _RailAction(
                label: 'DISARM',
                color: VvuColors.danger,
                onTap: state.disarmAll,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final m in kFoundationModels) ...[
            InferenceSwitch(model: m, state: state),
            const SizedBox(height: 8),
          ],
          _WormPreview(state: state),
        ],
      ),
    );
  }
}

class _RailAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _RailAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(VvuRadii.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(VvuRadii.sm),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WormPreview extends StatelessWidget {
  final EstateState state;
  const _WormPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final entries = state.wormLog.take(6).toList();
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: VvuColors.panelRaised,
            borderRadius: BorderRadius.circular(VvuRadii.md),
            border: Border.all(color: VvuColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.link_rounded,
                      size: 12, color: VvuColors.armed),
                  const SizedBox(width: 6),
                  const Text('WORM CHAIN', style: VvuTypography.labelMuted),
                  const Spacer(),
                  Text('${state.evidenceCount} sealed',
                      style: VvuTypography.micro),
                ],
              ),
              const SizedBox(height: 6),
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Text(
                        '#${e.seq.toString().padLeft(4, '0')}',
                        style: VvuTypography.micro,
                      ),
                      const SizedBox(width: 6),
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
                      const SizedBox(width: 4),
                      Text(
                        e.hash.substring(0, 6),
                        style: TextStyle(
                          fontFamily: VvuTypography.mono,
                          fontSize: 9,
                          color: VvuColors.twin,
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
