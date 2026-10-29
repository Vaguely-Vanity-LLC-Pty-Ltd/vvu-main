// VVU Unified Roof — Bottom status bar.
import 'package:flutter/material.dart';
import '../state/estate_state.dart';
import 'tokens.dart';

/// Bottom status bar showing version, hash, anchor, env, layout, and flags.
class StatusBar extends StatelessWidget {
  final EstateState state;
  final VoidCallback onOpenFlags;
  const StatusBar({super.key, required this.state, required this.onOpenFlags});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Container(
          height: 24,
          color: VvuColors.panel,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                'v${state.appVersion}',
                style: VvuTypography.micro,
              ),
              const SizedBox(width: 6),
              Text('[${state.appChannel}]', style: VvuTypography.micro),
              const SizedBox(width: 12),
              Text('build ${state.buildHash}', style: VvuTypography.micro),
              const SizedBox(width: 12),
              Text('WORM ${state.wormAnchor}', style: VvuTypography.micro),
              const SizedBox(width: 12),
              _EnvBadge(state: state),
              const SizedBox(width: 12),
              Text('LAYOUT ${state.layout.label}', style: VvuTypography.micro),
              const Spacer(),
              if (state.updateAvailable)
                InkWell(
                  onTap: state.acknowledgeUpdate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: VvuColors.warn.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(VvuRadii.sm),
                      border: Border.all(
                        color: VvuColors.warn.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.system_update_alt,
                            size: 10, color: VvuColors.warn),
                        const SizedBox(width: 4),
                        Text(
                          'UPDATE AVAILABLE · RELOAD',
                          style: TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 9,
                            letterSpacing: 1.4,
                            color: VvuColors.warn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (state.updateAvailable) const SizedBox(width: 12),
              InkWell(
                onTap: onOpenFlags,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_rounded,
                        size: 10, color: VvuColors.studio),
                    const SizedBox(width: 4),
                    Text('FLAGS', style: VvuTypography.micro),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                state.chainIntact ? Icons.link_rounded : Icons.link_off_rounded,
                size: 10,
                color: state.chainIntact ? VvuColors.armed : VvuColors.danger,
              ),
              const SizedBox(width: 4),
              Text(
                state.chainIntact ? 'WORM INTACT' : 'WORM BROKEN',
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 9,
                  letterSpacing: 1.4,
                  color:
                      state.chainIntact ? VvuColors.armed : VvuColors.danger,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EnvBadge extends StatelessWidget {
  final EstateState state;
  const _EnvBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = state.environment == Environment.production
        ? VvuColors.armed
        : state.environment == Environment.staging
            ? VvuColors.warn
            : VvuColors.twin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        state.environment.label,
        style: TextStyle(
          fontFamily: VvuTypography.mono,
          fontSize: 9,
          letterSpacing: 1.4,
          color: color,
        ),
      ),
    );
  }
}
