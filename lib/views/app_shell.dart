// VVU Unified Roof - App shell (top-level scaffold).
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/estate.dart';
import '../state/estate_state.dart';
import '../widgets/chrome.dart';
import '../widgets/status_bar.dart';
import '../widgets/tokens.dart';
import '../widgets/top_menu_bar.dart';
import 'hostafrica_view.dart';
import 'ide_views.dart';
import 'landing_view.dart';
import 'ops_views.dart';
import 'play_view.dart';
import 'scada_views.dart';
import 'stitch_view.dart';
import 'store_view.dart';
import 'trust_views.dart';
import 'trust_views_2.dart';
import 'twin_view.dart';

/// Top-level stateful widget that owns the [EstateState] and renders the shell.
class VvuUnifiedRoof extends StatefulWidget {
  const VvuUnifiedRoof({super.key});

  @override
  State<VvuUnifiedRoof> createState() => _VvuUnifiedRoofState();
}

class _VvuUnifiedRoofState extends State<VvuUnifiedRoof> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final EstateState _state;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _state = EstateState();
    _syncUrlToState();
    _state.addListener(_onStateChanged);
    html.window.addEventListener('popstate', (_) => _onPopState());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _state.removeListener(_onStateChanged);
    _state.dispose();
    super.dispose();
  }

  void _onPopState() {
    _syncUrlToState();
  }

  void _onStateChanged() {
    _syncStateToUrl();
  }

  void _syncUrlToState() {
    final path = html.window.location.pathname;
    final cleanPath = path.endsWith('/') ? path.substring(0, path.length - 1) : path;
    final surfaceId = cleanPath.isEmpty ? 'twin' : cleanPath.substring(1);

    // Validate the surface ID
    final validSurface = kSurfaces.any((s) => s.id == surfaceId);
    if (validSurface && _state.activeSurface != surfaceId) {
      _state.setActiveSurface(surfaceId);
    } else if (!validSurface && cleanPath != '') {
      // Invalid route - redirect to twin
      html.window.history.pushState(null, '', '/twin');
      _state.setActiveSurface('twin');
    }
  }

  void _syncStateToUrl() {
    final currentPath = html.window.location.pathname;
    final targetPath = '/${_state.activeSurface}';

    if (currentPath != targetPath) {
      html.window.history.pushState(null, '', targetPath);
    }
  }

  void _navigate(String id) {
    _state.setActiveSurface(id);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  /// Keyboard shortcuts: Ctrl+1..9 -> first 9 surfaces.
  void _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final ctrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!ctrl) return;
    final key = event.logicalKey;
    final map = {
      LogicalKeyboardKey.digit1: 0,
      LogicalKeyboardKey.digit2: 1,
      LogicalKeyboardKey.digit3: 2,
      LogicalKeyboardKey.digit4: 3,
      LogicalKeyboardKey.digit5: 4,
      LogicalKeyboardKey.digit6: 5,
      LogicalKeyboardKey.digit7: 6,
      LogicalKeyboardKey.digit8: 7,
      LogicalKeyboardKey.digit9: 8,
    };
    final idx = map[key];
    if (idx == null || idx >= kSurfaces.length) {
      return;
    }
    _navigate(kSurfaces[idx].id);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: VvuColors.background,
        drawer: MediaQuery.of(context).size.width < 900
            ? _Drawer(state: _state, onSelect: _navigate)
            : null,
        body: Column(
          children: [
            TopMenuBar(
              state: _state,
              onOpenDrawer: () =>
                  _scaffoldKey.currentState?.openDrawer(),
              onNavigate: _navigate,
            ),
            const Divider(height: 1, color: VvuColors.line),
            StatusStrip(state: _state),
            const Divider(height: 1, color: VvuColors.line),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final desktop = c.maxWidth >= 900;
                  final showSide =
                      desktop && (_state.layout == LayoutMode.single);
                  return ListenableBuilder(
                    listenable: _state,
                    builder: (context, _) {
                      return Row(
                        children: [
                          if (showSide)
                            SideRail(state: _state, onSelect: _navigate),
                          if (showSide)
                            const VerticalDivider(
                                width: 1, color: VvuColors.line),
                          Expanded(
                            child: _state.layout == LayoutMode.split4
                                ? _Split4View(state: _state)
                                : _activeSurfaceView(_state.activeSurface),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1, color: VvuColors.line),
            StatusBar(
              state: _state,
              onOpenFlags: () => _showFlagsDialog(context),
            ),
            const Divider(height: 1, color: VvuColors.line),
            TrustFooter(state: _state),
          ],
        ),
      ),
    );
  }

  Widget _activeSurfaceView(String id) {
    switch (id) {
      // TRUST UI
      case 'landing':
        return LandingView(state: _state, onNavigate: _navigate);
      case 'stitch':
        return StitchView(state: _state);
      case 'hostafrica':
        return HostAfricaView(state: _state);
      case 'forge':
        return ForgeView(state: _state);
      case 'fire':
        return FireView(state: _state);
      case 'press':
        return PressView(state: _state);
      case 'bench':
        return BenchView(state: _state);
      case 'field':
        return FieldView(state: _state);
      case 'spatial':
        return SpatialView(state: _state);
      case 'surv':
        return SurvView(state: _state);
      case 'twin-hologram':
        return TwinHologramView(state: _state);
      // OPS
      case 'admin':
        return AdminView(state: _state);
      case 'doctor':
        return DoctorView(state: _state);
      case 'observe':
        return ObserveView(state: _state);
      // SCADA
      case 'twin':
        return TwinView(state: _state);
      case 'overview':
        return OverviewView(state: _state);
      case 'tactical':
        return TacticalMapView(state: _state);
      case 'replay':
        return ReplayView(state: _state);
      // IDE
      case 'documents':
        return DocumentsView(state: _state);
      case 'spreadsheets':
        return SpreadsheetsView(state: _state);
      case 'publications':
        return PublicationsView(state: _state);
      case 'ledger':
        return LedgerView(state: _state);
      case 'settings':
        return SettingsView(state: _state);
      // NEW
      case 'play':
        return PlayView(state: _state);
      case 'store':
        return StoreView(state: _state);
      default:
        return _NotFound(id: id);
    }
  }

  void _showFlagsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _FlagDialog(state: _state),
    );
  }
}

/// Mobile drawer: a compact SideRail.
class _Drawer extends StatelessWidget {
  final EstateState state;
  final void Function(String) onSelect;
  const _Drawer({required this.state, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: VvuColors.panel,
      width: 260,
      child: SideRail(state: state, onSelect: onSelect),
    );
  }
}

/// 2x2 split layout showing 4 surfaces simultaneously.
class _Split4View extends StatelessWidget {
  final EstateState state;
  const _Split4View({required this.state});

  @override
  Widget build(BuildContext context) {
    final ids = [
      'twin',
      'overview',
      'admin',
      'observe',
    ];
    return Container(
      color: VvuColors.background,
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1.6,
        children: [
          for (final id in ids)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: VvuColors.line),
              ),
              child: ClipRect(child: _activeView(id)),
            ),
        ],
      ),
    );
  }

  Widget _activeView(String id) {
    switch (id) {
      case 'twin':
        return TwinView(state: state);
      case 'overview':
        return OverviewView(state: state);
      case 'admin':
        return AdminView(state: state);
      case 'observe':
        return ObserveView(state: state);
      default:
        return _NotFound(id: id);
    }
  }
}

class _NotFound extends StatelessWidget {
  final String id;
  const _NotFound({required this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: VvuColors.danger),
          const SizedBox(height: 16),
          Text(
            '404 - Surface not found',
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 18,
              color: VvuColors.danger,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Surface "$id" does not exist',
            style: VvuTypography.body,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => html.window.location.href = '/twin',
            style: ElevatedButton.styleFrom(
              backgroundColor: VvuColors.twin,
              foregroundColor: VvuColors.background,
            ),
            child: const Text('Go to Twin'),
          ),
        ],
      ),
    );
  }
}

/// Popup with all 8 flags and switches.
class _FlagDialog extends StatelessWidget {
  final EstateState state;
  const _FlagDialog({required this.state});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: VvuColors.panelRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VvuRadii.md),
        side: const BorderSide(color: VvuColors.lineStrong),
      ),
      title: const Text(
        'FEATURE FLAGS',
        style: VvuTypography.h2,
      ),
      content: SizedBox(
        width: 380,
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final id in EstateState.kFlagIds)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            id,
                            style: const TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 11,
                              color: VvuColors.text,
                            ),
                          ),
                        ),
                        Text(
                          state.flagActor(id),
                          style: VvuTypography.micro,
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: state.flag(id),
                          onChanged: (_) =>
                              state.toggleFlag(id, 'dialog'),
                          activeColor: VvuColors.studio,
                          inactiveThumbColor: VvuColors.textFaint,
                          inactiveTrackColor: VvuColors.line,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE',
              style: TextStyle(color: VvuColors.twin)),
        ),
      ],
    );
  }
}
