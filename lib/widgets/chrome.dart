// VVU Unified Roof — Chrome widgets (top status strip, side rail, footer).
import 'package:flutter/material.dart';
import '../models/estate.dart';
import '../state/estate_state.dart';
import 'tokens.dart';

/// The horizontal status strip across the top of the body.
class StatusStrip extends StatelessWidget {
  final EstateState state;
  const StatusStrip({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: VvuColors.panel,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Estate mark — Borromean rings logo
          Image.asset(
            'assets/images/vvu_borromean_rings.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('VVU UNIFIED ROOF', style: VvuTypography.h2),
              Text(
                'estate · gqeberha za',
                style: VvuTypography.micro,
              ),
            ],
          ),
          const SizedBox(width: 16),
          const _ModeTag(),
          const SizedBox(width: 16),
          Flexible(
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _TelemetryChip(
                  label: 'PRESSURE',
                  value: state.pipelinePressure.toStringAsFixed(2),
                  unit: 'bar',
                  accent: VvuColors.twin,
                ),
                _TelemetryChip(
                  label: 'FLOW',
                  value: state.flow.toStringAsFixed(1),
                  unit: 'l/s',
                  accent: VvuColors.armed,
                ),
                _TelemetryChip(
                  label: 'NODES',
                  value: '${state.nodes}',
                  unit: 'live',
                  accent: VvuColors.studio,
                ),
              ],
            ),
          ),
          const Spacer(),
          _BackendHealth(state: state),
          const SizedBox(width: 12),
          _TakeoffButton(state: state),
          const SizedBox(width: 12),
          BeatRail(beat: state.beat),
          const SizedBox(width: 12),
          _TimeChip(),
        ],
      ),
    );
  }
}

class _TelemetryChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color accent;

  const _TelemetryChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: VvuColors.panelRaised,
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        border: Border.all(color: VvuColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: VvuTypography.micro),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
          const SizedBox(width: 4),
          Text(unit, style: VvuTypography.micro),
        ],
      ),
    );
  }
}

class _ModeTag extends StatelessWidget {
  const _ModeTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: VvuColors.ink,
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        border: Border.all(color: VvuColors.lineStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: VvuColors.twin,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text('TWIN', style: VvuTypography.labelMuted),
        ],
      ),
    );
  }
}

class _BackendHealth extends StatelessWidget {
  final EstateState state;
  const _BackendHealth({required this.state});

  static const _entries = [
    ('fluid_studio', '3001'),
    ('proof_bridge', '3002'),
    ('ubuntu_pools', '3003'),
    ('safegrid', '3004'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in _entries)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: ':${e.$2}',
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (state.backendHealth[e.$1] ?? false)
                      ? VvuColors.armed
                      : VvuColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TakeoffButton extends StatelessWidget {
  final EstateState state;
  const _TakeoffButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final armed = state.takeoffArmed;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: state.toggleTakeoff,
            borderRadius: BorderRadius.circular(VvuRadii.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: armed
                    ? VvuColors.armed.withOpacity(0.12)
                    : VvuColors.panelRaised,
                borderRadius: BorderRadius.circular(VvuRadii.sm),
                border: Border.all(
                  color: armed ? VvuColors.armed : VvuColors.lineStrong,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    armed
                        ? Icons.power_settings_new_rounded
                        : Icons.flash_on_rounded,
                    size: 14,
                    color: armed ? VvuColors.armed : VvuColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    armed ? 'STAND DOWN' : 'TAKEOFF',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w600,
                      color: armed ? VvuColors.armed : VvuColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BeatRail extends StatelessWidget {
  final int beat;
  const BeatRail({super.key, required this.beat});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (i) {
        final active = (beat + i) % 8 < 3;
        return Container(
          width: 6,
          height: 18,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: active
                ? VvuColors.beat.withOpacity(0.85)
                : VvuColors.line,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class _TimeChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snap) {
        final t = snap.data!;
        return Text(
          '${t.hour.toString().padLeft(2, '0')}'
          ':${t.minute.toString().padLeft(2, '0')}'
          ':${t.second.toString().padLeft(2, '0')}',
          style: VvuTypography.labelMuted,
        );
      },
    );
  }
}

/// The left navigation rail.
class SideRail extends StatelessWidget {
  final EstateState state;
  final void Function(String surfaceId) onSelect;
  const SideRail({super.key, required this.state, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      color: VvuColors.panel,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              for (final side in SurfaceSide.values) ...[
                _SideHeader(label: side.label),
                for (final s in kSurfaces.where((s) => s.side == side))
                  _SideItem(
                    surface: s,
                    active: state.activeSurface == s.id,
                    onTap: () => onSelect(s.id),
                  ),
                if (side == SurfaceSide.scada)
                  _GatewaySummary(state: state),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SideHeader extends StatelessWidget {
  final String label;
  const _SideHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
      child: Text(label, style: VvuTypography.labelMuted),
    );
  }
}

class _SideItem extends StatelessWidget {
  final Surface surface;
  final bool active;
  final VoidCallback onTap;
  const _SideItem({
    required this.surface,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2,
                color: active ? surface.accent : Colors.transparent,
              ),
            ),
            color: active
                ? surface.accent.withOpacity(0.08)
                : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(surface.icon, size: 16, color: surface.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surface.name,
                      style: TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 12,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w500,
                        color: active ? VvuColors.text : VvuColors.textMuted,
                      ),
                    ),
                    Text(
                      surface.blurb,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VvuTypography.micro,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GatewaySummary extends StatelessWidget {
  final EstateState state;
  const _GatewaySummary({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: VvuColors.panelRaised,
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        border: Border.all(color: VvuColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, size: 14, color: VvuColors.armed),
          const SizedBox(width: 6),
          Text(
            'GATES ${state.armedCount}/${state.totalCount}',
            style: VvuTypography.labelMuted,
          ),
        ],
      ),
    );
  }
}

/// The bottom trust footer.
class TrustFooter extends StatelessWidget {
  final EstateState state;
  const TrustFooter({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final last = state.wormLog.isNotEmpty ? state.wormLog.first : null;
        return Container(
          height: 30,
          color: VvuColors.panel,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                state.chainIntact ? Icons.link_rounded : Icons.link_off_rounded,
                size: 12,
                color: state.chainIntact ? VvuColors.armed : VvuColors.danger,
              ),
              const SizedBox(width: 6),
              Text(
                'WORM ${state.chainIntact ? 'INTACT' : 'BROKEN'}',
                style: VvuTypography.micro,
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 14,
                color: VvuColors.line,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  last != null
                      ? '#${last.seq.toString().padLeft(4, '0')} ${last.message}'
                      : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: VvuTypography.micro,
                ),
              ),
              const SizedBox(width: 12),
              Text('GQEBERHA ZA', style: VvuTypography.micro),
            ],
          ),
        );
      },
    );
  }
}
