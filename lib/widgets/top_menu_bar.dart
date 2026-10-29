// VVU Unified Roof — Top menu bar.
import 'package:flutter/material.dart';
import '../state/estate_state.dart';
import 'tokens.dart';

/// A Mac/VS-Code-style top menu bar.
class TopMenuBar extends StatelessWidget implements PreferredSizeWidget {
  final EstateState state;
  final VoidCallback onOpenDrawer;
  final ValueChanged<String>? onNavigate;

  const TopMenuBar({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    this.onNavigate,
  });

  @override
  Size get preferredSize => const Size.fromHeight(36);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: VvuColors.ink,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: onOpenDrawer,
            icon: const Icon(Icons.menu_rounded, size: 18),
            color: VvuColors.textMuted,
            tooltip: 'Open drawer',
            splashRadius: 16,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 4),
          Image.asset(
            'assets/images/vvu_borromean_rings.png',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 6),
          const Text(
            'VVU',
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              color: VvuColors.text,
            ),
          ),
          const SizedBox(width: 16),
          _MenuButton(
            label: 'File',
            items: [
              _MenuItem('New Document', () => onNavigate?.call('documents')),
              _MenuItem('Open Twin', () => onNavigate?.call('twin')),
              _MenuItem('Open Store', () => onNavigate?.call('store')),
              _MenuItem('Open Play', () => onNavigate?.call('play')),
            ],
          ),
          _MenuButton(
            label: 'View',
            items: [
              _MenuItem('Single Layout', () => state.setLayout(LayoutMode.single)),
              _MenuItem('Split-4 Layout', () => state.setLayout(LayoutMode.split4)),
              _MenuItem('Overview', () => onNavigate?.call('overview')),
              _MenuItem('Tactical Map', () => onNavigate?.call('tactical')),
              _MenuItem('Replay', () => onNavigate?.call('replay')),
            ],
          ),
          _MenuButton(
            label: 'System',
            items: [
              _MenuItem('Run Doctor', () => state.runDoctor()),
              _MenuItem('Open Admin', () => onNavigate?.call('admin')),
              _MenuItem('Open Observe', () => onNavigate?.call('observe')),
              _MenuItem('Force Frontend Update', state.forceFrontendUpdate),
              _MenuItem('Switch to PRODUCTION',
                  () => state.setEnvironment(Environment.production)),
              _MenuItem('Switch to STAGING',
                  () => state.setEnvironment(Environment.staging)),
              _MenuItem('Switch to DEVELOPMENT',
                  () => state.setEnvironment(Environment.development)),
            ],
          ),
          _MenuButton(
            label: 'Help',
            items: [
              _MenuItem('About VVU', () => onNavigate?.call('landing')),
              _MenuItem('Documentation', () => onNavigate?.call('documents')),
              _MenuItem('Settings', () => onNavigate?.call('settings')),
            ],
          ),
          const Spacer(),
          _EnvIndicator(state: state),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _EnvIndicator extends StatelessWidget {
  final EstateState state;
  const _EnvIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final color = state.environment == Environment.production
            ? VvuColors.armed
            : state.environment == Environment.staging
                ? VvuColors.warn
                : VvuColors.twin;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.label, this.onTap);
}

class _MenuButton extends StatelessWidget {
  final String label;
  final List<_MenuItem> items;
  const _MenuButton({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: label,
      position: PopupMenuPosition.under,
      color: VvuColors.panelRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VvuRadii.md),
        side: const BorderSide(color: VvuColors.lineStrong),
      ),
      offset: const Offset(0, 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: VvuTypography.sans,
            fontSize: 13,
            color: VvuColors.textMuted,
          ),
        ),
      ),
      itemBuilder: (context) => List.generate(items.length, (i) {
        final it = items[i];
        return PopupMenuItem<int>(
          value: i,
          height: 30,
          child: Text(
            it.label,
            style: TextStyle(
              fontFamily: VvuTypography.sans,
              fontSize: 12,
              color: VvuColors.text,
            ),
          ),
        );
      }),
      onSelected: (i) => items[i].onTap(),
    );
  }
}
