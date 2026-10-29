// VVU Unified Roof — HostAfrica VPS management surface.
import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/hostafrica_api.dart';
import '../state/estate_state.dart';
import '../widgets/tokens.dart';

/// HostAfrica surface: VPS list, backup operations, SDK links.
class HostAfricaView extends StatefulWidget {
  final EstateState state;
  const HostAfricaView({super.key, required this.state});

  @override
  State<HostAfricaView> createState() => _HostAfricaViewState();
}

class _Vps {
  final String id;
  final String name;
  final String ip;
  final String status;
  _Vps({
    required this.id,
    required this.name,
    required this.ip,
    required this.status,
  });

  factory _Vps.fromMap(Map<String, dynamic> m) => _Vps(
        id: (m['id'] ?? m['vpsId'] ?? '').toString(),
        name: (m['name'] ?? m['hostname'] ?? 'VPS').toString(),
        ip: (m['ip'] ?? m['ipAddress'] ?? '—').toString(),
        status: (m['status'] ?? 'unknown').toString(),
      );
}

class _HostAfricaViewState extends State<HostAfricaView> {
  static const _accent = Color(0xFFFFB84D);

  List<_Vps> _vps = [];
  bool _loading = true;
  String? _error;
  String? _busyId;

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
    final r = await HostAfricaApi.listVps();
    if (!r.ok || r.data == null) {
      setState(() {
        _loading = false;
        _error = r.error ?? 'Failed to list VPS';
        _vps = _seed();
      });
      return;
    }
    final parsed = <_Vps>[];
    for (final v in r.data!) {
      if (v is Map<String, dynamic>) parsed.add(_Vps.fromMap(v));
    }
    setState(() {
      _loading = false;
      _vps = parsed.isEmpty ? _seed() : parsed;
    });
  }

  List<_Vps> _seed() => [
        _Vps(id: 'vps-1', name: 'gqeberha-01', ip: '102.130.119.10', status: 'running'),
        _Vps(id: 'vps-2', name: 'gqeberha-02', ip: '102.130.119.11', status: 'running'),
        _Vps(id: 'vps-3', name: 'jozi-01', ip: '102.130.119.20', status: 'stopped'),
      ];

  Future<void> _createBackup(_Vps v) async {
    setState(() => _busyId = v.id);
    final r = await HostAfricaApi.createBackup(v.id);
    setState(() => _busyId = null);
    if (r.ok) {
      widget.state.appendLogPublic('hostafrica backup created · ${v.name}');
    }
    _showResult('Create backup · ${v.name}', r);
  }

  Future<void> _listBackups(_Vps v) async {
    setState(() => _busyId = v.id);
    final r = await HostAfricaApi.listBackups(v.id);
    setState(() => _busyId = null);
    final count = r.ok && r.data != null ? r.data!.length : 0;
    _showResult(
      'List backups · ${v.name}',
      r.ok
          ? ApiResult.ok(<String, dynamic>{
              'count': count,
              'backups': r.data ?? [],
            })
          : ApiResult.fail(r.error ?? 'Failed'),
    );
  }

  void _showResult(String title, ApiResult<dynamic> r) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VvuColors.panelRaised,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: VvuTypography.mono,
            fontSize: 13,
            color: VvuColors.text,
          ),
        ),
        content: SizedBox(
          width: 360,
          child: r.ok
              ? SelectableText(
                  'OK\n\n${r.data}',
                  style: const TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 11,
                    color: VvuColors.armed,
                  ),
                )
              : Text(
                  'FAILED\n\n${r.error}',
                  style: const TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 11,
                    color: VvuColors.danger,
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE',
                style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(VvuRadii.md),
                  border: Border.all(color: _accent.withOpacity(0.4)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.dns_rounded,
                    size: 18, color: _accent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HOSTAFRICA', style: VvuTypography.h1),
                    Text(
                      'VPS list · backup operations · scheduling.',
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
          // Config status banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: HostAfricaConfig.isConfigured
                  ? VvuColors.armed.withOpacity(0.10)
                  : VvuColors.warn.withOpacity(0.10),
              borderRadius: BorderRadius.circular(VvuRadii.sm),
              border: Border.all(
                color: HostAfricaConfig.isConfigured
                    ? VvuColors.armed.withOpacity(0.4)
                    : VvuColors.warn.withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  HostAfricaConfig.isConfigured
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: HostAfricaConfig.isConfigured
                      ? VvuColors.armed
                      : VvuColors.warn,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    HostAfricaConfig.isConfigured
                        ? 'HostAfrica API key configured. Live VPS & backup calls enabled.'
                        : 'HostAfrica API key not configured — calls will fail; UI remains explorable.',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 10,
                      color: HostAfricaConfig.isConfigured
                          ? VvuColors.armed
                          : VvuColors.warn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // VPS list
          const Text('VPS INSTANCES', style: VvuTypography.labelMuted),
          const SizedBox(height: 8),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: _accent),
              ),
            )
          else
            for (final v in _vps)
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
                    Icon(
                      v.status == 'running'
                          ? Icons.play_circle_rounded
                          : Icons.pause_circle_rounded,
                      size: 18,
                      color: v.status == 'running'
                          ? VvuColors.armed
                          : VvuColors.textFaint,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.name,
                            style: const TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: VvuColors.text,
                            ),
                          ),
                          Text(
                            '${v.ip} · ${v.status}',
                            style: VvuTypography.micro,
                          ),
                        ],
                      ),
                    ),
                    if (_busyId == v.id)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: _accent,
                        ),
                      )
                    else ...[
                      _OpBtn(
                        label: 'BACKUP',
                        accent: _accent,
                        onTap: () => _createBackup(v),
                      ),
                      const SizedBox(width: 6),
                      _OpBtn(
                        label: 'BACKUPS',
                        accent: VvuColors.twin,
                        onTap: () => _listBackups(v),
                      ),
                    ],
                  ],
                ),
              ),
          const SizedBox(height: 16),
          // Backup operations panel
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: VvuColors.panel,
              borderRadius: BorderRadius.circular(VvuRadii.md),
              border: Border.all(color: VvuColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BACKUP OPERATIONS',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 11,
                      letterSpacing: 1.8,
                      color: _accent,
                    )),
                const SizedBox(height: 10),
                const Text(
                  'Available operations:\n'
                  '• listVps()  → POST /vps/list\n'
                  '• createBackup(vpsId)  → POST /vps/create-backup\n'
                  '• listBackups(vpsId)  → POST /vps/list-backups\n'
                  '• restoreBackup(backupId)  → POST /vps/restore-backup\n'
                  '• createBackupSchedule(vpsId, frequency, retention)\n'
                  '• listBackupSchedules(vpsId)',
                  style: TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 11,
                    height: 1.6,
                    color: VvuColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // SDK links
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: VvuColors.panel,
              borderRadius: BorderRadius.circular(VvuRadii.md),
              border: Border.all(color: VvuColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SDK & DOCS',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 11,
                      letterSpacing: 1.8,
                      color: _accent,
                    )),
                const SizedBox(height: 10),
                for (final link in [
                  ('API docs', 'https://www.hostafrica.com/developers/'),
                  ('Status', 'https://status.hostafrica.com/'),
                  ('Console', 'https://console.hostafrica.com/'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.open_in_new_rounded,
                            size: 12, color: _accent),
                        const SizedBox(width: 6),
                        Text(
                          '${link.$1} — ${link.$2}',
                          style: const TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 11,
                            color: VvuColors.textMuted,
                          ),
                        ),
                      ],
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

class _OpBtn extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;
  const _OpBtn({
    required this.label,
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
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(VvuRadii.sm),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ),
    );
  }
}
