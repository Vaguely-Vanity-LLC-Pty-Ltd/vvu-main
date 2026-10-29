// VVU Unified Roof — Ops views (admin, doctor, observe).
import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../state/estate_state.dart';
import '../widgets/tokens.dart';

// ── Admin ─────────────────────────────────────────────────────────────────

class AdminView extends StatefulWidget {
  final EstateState state;
  const AdminView({super.key, required this.state});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final _emailCtrl = TextEditingController();
  final _tenantCtrl = TextEditingController(text: 'gqeberha');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tenantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('ADMIN', style: VvuTypography.h1),
          const SizedBox(height: 4),
          const Text(
            'Feature flags · RBAC · tenants · audit.',
            style: VvuTypography.body,
          ),
          const SizedBox(height: 16),
          // Feature flags
          _Section(title: 'FEATURE FLAGS', accent: VvuColors.studio, children: [
            for (final id in EstateState.kFlagIds)
              ListenableBuilder(
                listenable: widget.state,
                builder: (context, _) {
                  final v = widget.state.flag(id);
                  return Padding(
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
                          widget.state.flagActor(id),
                          style: VvuTypography.micro,
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: v,
                          onChanged: (_) =>
                              widget.state.toggleFlag(id, 'admin@vvu'),
                          activeColor: VvuColors.studio,
                          inactiveThumbColor: VvuColors.textFaint,
                          inactiveTrackColor: VvuColors.line,
                        ),
                      ],
                    ),
                  );
                },
              ),
          ]),
          const SizedBox(height: 16),
          // RBAC users
          _Section(title: 'RBAC USERS', accent: VvuColors.studio, children: [
            for (final u in widget.state.users)
              ListenableBuilder(
                listenable: widget.state,
                builder: (context, _) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: VvuColors.studio.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: VvuColors.studio.withOpacity(0.4)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            u.email[0].toUpperCase(),
                            style: const TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 11,
                              color: VvuColors.studio,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.email,
                                style: const TextStyle(
                                  fontFamily: VvuTypography.mono,
                                  fontSize: 11,
                                  color: VvuColors.text,
                                ),
                              ),
                              Text(
                                '${u.role} · ${u.tenant}',
                                style: VvuTypography.micro,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (u.active
                                    ? VvuColors.armed
                                    : VvuColors.textFaint)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(VvuRadii.sm),
                            border: Border.all(
                              color: (u.active
                                      ? VvuColors.armed
                                      : VvuColors.textFaint)
                                  .withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            u.active ? 'ACTIVE' : 'DISABLED',
                            style: TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 9,
                              letterSpacing: 1.4,
                              color: u.active
                                  ? VvuColors.armed
                                  : VvuColors.textFaint,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => widget.state.toggleUserActive(u.id),
                          icon: Icon(
                            u.active
                                ? Icons.toggle_on_rounded
                                : Icons.toggle_off_rounded,
                            size: 18,
                            color: u.active
                                ? VvuColors.armed
                                : VvuColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ]),
          const SizedBox(height: 16),
          // Tenant provisioning
          _Section(
              title: 'TENANT PROVISIONING',
              accent: VvuColors.studio,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailCtrl,
                        style: const TextStyle(
                          fontFamily: VvuTypography.mono,
                          fontSize: 12,
                          color: VvuColors.text,
                        ),
                        decoration: _deco('Tenant email'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _tenantCtrl,
                        style: const TextStyle(
                          fontFamily: VvuTypography.mono,
                          fontSize: 12,
                          color: VvuColors.text,
                        ),
                        decoration: _deco('Tenant name'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final email = _emailCtrl.text.trim();
                          final tenant = _tenantCtrl.text.trim();
                          if (email.isEmpty || tenant.isEmpty) return;
                          widget.state.provisionTenant(
                              email: email, tenant: tenant);
                          _emailCtrl.clear();
                        },
                        borderRadius: BorderRadius.circular(VvuRadii.sm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: VvuColors.studio.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(VvuRadii.sm),
                            border: Border.all(
                                color: VvuColors.studio.withOpacity(0.5)),
                          ),
                          child: const Text(
                            'PROVISION',
                            style: TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 10,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                              color: VvuColors.studio,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
          const SizedBox(height: 16),
          // WORM audit
          _Section(title: 'WORM AUDIT LOG', accent: VvuColors.studio, children: [
            for (final e in widget.state.wormLog.take(10))
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
          ]),
        ],
      ),
    );
  }
}

InputDecoration _deco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: VvuColors.textFaint),
      filled: true,
      fillColor: VvuColors.ink,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        borderSide: const BorderSide(color: VvuColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        borderSide: const BorderSide(color: VvuColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        borderSide: const BorderSide(color: VvuColors.lineStrong),
      ),
    );

class _Section extends StatelessWidget {
  final String title;
  final Color accent;
  final List<Widget> children;
  const _Section({
    required this.title,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VvuColors.panel,
        borderRadius: BorderRadius.circular(VvuRadii.md),
        border: Border.all(color: VvuColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 11,
              letterSpacing: 1.8,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

// ── Doctor ────────────────────────────────────────────────────────────────

class DoctorView extends StatelessWidget {
  final EstateState state;
  const DoctorView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              const Text('DOCTOR', style: VvuTypography.h1),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: state.runDoctor,
                  borderRadius: BorderRadius.circular(VvuRadii.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: VvuColors.armed.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(VvuRadii.sm),
                      border: Border.all(
                          color: VvuColors.armed.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            size: 14, color: VvuColors.armed),
                        SizedBox(width: 6),
                        Text(
                          'RUN DOCTOR',
                          style: TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: VvuColors.armed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '4-state health model · pings all 4 backends.',
            style: VvuTypography.body,
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'CHECKS',
            accent: VvuColors.armed,
            children: [
              for (final id in EstateState.kDoctorCheckIds)
                ListenableBuilder(
                  listenable: state,
                  builder: (context, _) {
                    final s = state.doctorCheck(id);
                    final color = _stateColor(s);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              id.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: VvuTypography.mono,
                                fontSize: 11,
                                color: VvuColors.text,
                              ),
                            ),
                          ),
                          Text(
                            s.label,
                            style: TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 10,
                              letterSpacing: 1.4,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(title: 'CANARY', accent: VvuColors.armed, children: [
            ListenableBuilder(
              listenable: state,
              builder: (context, _) {
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Runs: ${state.canaryRuns}',
                            style: const TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 12,
                              color: VvuColors.text,
                            ),
                          ),
                          Text(
                            'Last: ${state.canaryLastStatus}',
                            style: VvuTypography.micro,
                          ),
                        ],
                      ),
                    ),
                    if (state.canaryRunning)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: state.stopCanary,
                          borderRadius: BorderRadius.circular(VvuRadii.sm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: VvuColors.danger.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(VvuRadii.sm),
                              border: Border.all(
                                  color:
                                      VvuColors.danger.withOpacity(0.5)),
                            ),
                            child: const Text(
                              'STOP CANARY',
                              style: TextStyle(
                                fontFamily: VvuTypography.mono,
                                fontSize: 10,
                                letterSpacing: 1.4,
                                color: VvuColors.danger,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: state.startCanary,
                          borderRadius: BorderRadius.circular(VvuRadii.sm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: VvuColors.armed.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(VvuRadii.sm),
                              border: Border.all(
                                  color:
                                      VvuColors.armed.withOpacity(0.5)),
                            ),
                            child: const Text(
                              'START CANARY',
                              style: TextStyle(
                                fontFamily: VvuTypography.mono,
                                fontSize: 10,
                                letterSpacing: 1.4,
                                color: VvuColors.armed,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ]),
          const SizedBox(height: 16),
          _Section(
              title: '4-STATE HEALTH REFERENCE',
              accent: VvuColors.armed,
              children: [
                for (final s in CheckState.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _stateColor(s),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          s.label,
                          style: const TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 11,
                            color: VvuColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
              ]),
        ],
      ),
    );
  }

  Color _stateColor(CheckState s) {
    switch (s) {
      case CheckState.healthy:
        return VvuColors.armed;
      case CheckState.degraded:
        return VvuColors.warn;
      case CheckState.blocked:
        return VvuColors.danger;
      case CheckState.running:
        return VvuColors.beat;
      case CheckState.unknown:
        return VvuColors.textFaint;
    }
  }
}

// ── Observe (real traces via SafeGridApi + UbuntuPoolsApi) ────────────────

class ObserveView extends StatefulWidget {
  final EstateState state;
  const ObserveView({super.key, required this.state});

  @override
  State<ObserveView> createState() => _ObserveViewState();
}

class _ObserveViewState extends State<ObserveView> {
  List<dynamic> _remoteTraces = [];
  List<dynamic> _remoteWorm = [];
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
    final tr = await SafeGridApi.getTraces();
    final worm = await UbuntuPoolsApi.getWormLog();
    setState(() {
      _loading = false;
      if (tr.ok && tr.data != null) _remoteTraces = tr.data!;
      if (worm.ok && worm.data != null) _remoteWorm = worm.data!;
      _error = (!tr.ok ? 'traces: ${tr.error}; ' : '') +
          (!worm.ok ? 'worm: ${worm.error}' : '');
      if (_error!.isEmpty) _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              const Text('OBSERVE', style: VvuTypography.h1),
              const Spacer(),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                color: VvuColors.twin,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Distributed traces · remote state · session replay.',
            style: VvuTypography.body,
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
                'Some backends offline — showing local fallback. $_error',
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 10,
                  color: VvuColors.danger,
                ),
              ),
            ),
          // Trace table — prefers remote, falls back to local derived.
          _Section(
            title: 'TRACES',
            accent: VvuColors.twin,
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: CircularProgressIndicator(color: VvuColors.twin),
                  ),
                )
              else ...[
                if (_remoteTraces.isNotEmpty)
                  for (final t in _remoteTraces.take(12))
                    _TraceRow(
                      traceId: (t is Map ? t['traceId'] : '—').toString(),
                      service: (t is Map ? t['service'] : '—').toString(),
                      operation: (t is Map ? t['operation'] : '—').toString(),
                      status: (t is Map ? t['status'] : 'OK').toString(),
                    )
                else
                  for (final t in widget.state.traces.take(12))
                    _TraceRow(
                      traceId: t.traceId,
                      service: t.service,
                      operation: t.operation,
                      status: t.status.label,
                    ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Remote state inspector
          _Section(
            title: 'REMOTE STATE INSPECTOR (live EstateState)',
            accent: VvuColors.twin,
            children: [
              ListenableBuilder(
                listenable: widget.state,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Kv('activeSurface', widget.state.activeSurface),
                      _Kv('activeMapView', widget.state.activeMapView),
                      _Kv('beat', '${widget.state.beat}'),
                      _Kv('pipelinePressure',
                          widget.state.pipelinePressure.toStringAsFixed(2)),
                      _Kv('flow', widget.state.flow.toStringAsFixed(1)),
                      _Kv('nodes', '${widget.state.nodes}'),
                      _Kv('gates', '${widget.state.armedCount}/${widget.state.totalCount}'),
                      _Kv('backendsOnline', '${widget.state.backendsOnline}/4'),
                      _Kv('chainIntact', widget.state.chainIntact.toString()),
                      _Kv('evidenceCount', '${widget.state.evidenceCount}'),
                      _Kv('canary', '${widget.state.canaryRuns} · ${widget.state.canaryLastStatus}'),
                      _Kv('layout', widget.state.layout.label),
                      _Kv('environment', widget.state.environment.label),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Session replay timeline
          _Section(
            title: 'SESSION REPLAY TIMELINE',
            accent: VvuColors.twin,
            children: [
              SizedBox(
                height: 80,
                child: ListenableBuilder(
                  listenable: widget.state,
                  builder: (context, _) {
                    final entries = widget.state.wormLog.take(40).toList();
                    return CustomPaint(
                      painter: _ReplayTimelinePainter(entries: entries),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Kv extends StatelessWidget {
  final String k;
  final String v;
  const _Kv(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              k,
              style: const TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 11,
                color: VvuColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              v,
              style: TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 11,
                color: VvuColors.twin,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TraceRow extends StatelessWidget {
  final String traceId;
  final String service;
  final String operation;
  final String status;
  const _TraceRow({
    required this.traceId,
    required this.service,
    required this.operation,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    final color = s.contains('ERR')
        ? VvuColors.danger
        : s.contains('WARN')
            ? VvuColors.warn
            : VvuColors.armed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              traceId,
              style: TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 10,
                color: VvuColors.twin,
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 120,
            child: Text(
              service,
              style: const TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 10,
                color: VvuColors.text,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              operation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 10,
                color: VvuColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            s,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 9,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplayTimelinePainter extends CustomPainter {
  final List<dynamic> entries;
  _ReplayTimelinePainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    final step = size.width / entries.length;
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final msg = (e is WormLogEntry)
          ? e.message
          : (e is Map ? (e['message'] ?? '').toString() : '');
      final isError = msg.contains('FAIL') || msg.contains('BLOCKED');
      final isWarn = msg.contains('warn') || msg.contains('DEGRADED');
      final color = isError
          ? VvuColors.danger
          : isWarn
              ? VvuColors.warn
              : VvuColors.armed;
      canvas.drawRect(
        Rect.fromLTWH(
          i * step + 1,
          size.height * 0.2,
          step - 2,
          size.height * 0.6,
        ),
        Paint()..color = color.withOpacity(0.65),
      );
    }
    // Baseline.
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.8),
      Paint()..color = VvuColors.line,
    );
  }

  @override
  bool shouldRepaint(covariant _ReplayTimelinePainter old) =>
      old.entries != entries;
}
