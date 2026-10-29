// VVU Unified Roof — Inference switch (per-foundation-model gate widget).
import 'package:flutter/material.dart';
import '../models/estate.dart';
import '../state/estate_state.dart';
import 'tokens.dart';

/// A live inference gate control for a single foundation model.
class InferenceSwitch extends StatefulWidget {
  final FoundationModel model;
  final EstateState state;

  const InferenceSwitch({
    super.key,
    required this.model,
    required this.state,
  });

  @override
  State<InferenceSwitch> createState() => _InferenceSwitchState();
}

class _InferenceSwitchState extends State<InferenceSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beat;

  @override
  void initState() {
    super.initState();
    _beat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final s = widget.state.gateState(widget.model.id);
        final v = widget.state.gateVerdict(widget.model.id);
        final runs = widget.state.gateRuns(widget.model.id);
        final last = widget.state.gateLastRun(widget.model.id);
        final reason = widget.state.gateReason(widget.model.id);

        final accent = widget.model.iconColor;
        final stateColor = s.color;

        return AnimatedBuilder(
          animation: s == InferenceState.running ? _beat : kAlwaysDismissedAnimation,
          builder: (context, child) {
            final pulse = s == InferenceState.running
                ? (0.4 + 0.6 * (_beat.value))
                : 1.0;
            return Container(
              decoration: BoxDecoration(
                color: VvuColors.panelRaised,
                borderRadius: BorderRadius.circular(VvuRadii.md),
                border: Border.all(
                  color: s == InferenceState.running
                      ? stateColor.withOpacity(pulse)
                      : s == InferenceState.off
                          ? VvuColors.line
                          : stateColor.withOpacity(0.5),
                  width: s == InferenceState.running ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Annunciator
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(VvuRadii.md),
                          border: Border.all(
                            color: accent.withOpacity(0.4),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          widget.model.icon,
                          size: 20,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.model.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: VvuTypography.mono,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: VvuColors.text,
                              ),
                            ),
                            Text(
                              widget.model.classLabel,
                              style: VvuTypography.micro,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.model.job,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: VvuTypography.sans,
                      fontSize: 11,
                      height: 1.35,
                      color: VvuColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _Stat(label: 'THRESH', value: widget.model.threshold),
                      _Stat(label: 'RUNS', value: '$runs'),
                      _Stat(
                        label: 'LAST',
                        value: last != null
                            ? '${last.hour.toString().padLeft(2, '0')}'
                                ':${last.minute.toString().padLeft(2, '0')}'
                                ':${last.second.toString().padLeft(2, '0')}'
                            : '—',
                      ),
                    ],
                  ),
                  if (s == InferenceState.verdict && v != VerdictKind.none) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: v.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(VvuRadii.sm),
                        border: Border.all(
                          color: v.color.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            v.label,
                            style: TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 10,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                              color: v.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: VvuTypography.sans,
                                fontSize: 10,
                                color: VvuColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _StateToggle(
                          state: s,
                          color: stateColor,
                          onTap: () => widget.state.toggleGate(widget.model.id),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RunButton(
                            enabled: s == InferenceState.armed,
                            running: s == InferenceState.running,
                            color: accent,
                            onTap: () => widget.state.runGate(widget.model.id),
                          ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: VvuColors.ink,
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        border: Border.all(color: VvuColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ', style: VvuTypography.micro),
          Text(
            value,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 10,
              color: VvuColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateToggle extends StatelessWidget {
  final InferenceState state;
  final Color color;
  final VoidCallback onTap;
  const _StateToggle({
    required this.state,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final armed = state != InferenceState.off;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: armed ? color.withOpacity(0.12) : VvuColors.ink,
            borderRadius: BorderRadius.circular(VvuRadii.sm),
            border: Border.all(
              color: armed ? color.withOpacity(0.5) : VvuColors.lineStrong,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                armed ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                size: 14,
                color: armed ? color : VvuColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                state.label,
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                  color: armed ? color : VvuColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunButton extends StatelessWidget {
  final bool enabled;
  final bool running;
  final Color color;
  final VoidCallback onTap;
  const _RunButton({
    required this.enabled,
    required this.running,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        child: Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.18) : VvuColors.ink,
            borderRadius: BorderRadius.circular(VvuRadii.sm),
            border: Border.all(
              color: enabled ? color.withOpacity(0.5) : VvuColors.line,
            ),
          ),
          alignment: Alignment.center,
          child: running
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Icon(
                  Icons.play_arrow_rounded,
                  size: 16,
                  color: enabled ? color : VvuColors.textFaint,
                ),
        ),
      ),
    );
  }
}
