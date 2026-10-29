// VVU Unified Roof — IDE views (documents, spreadsheets, publications, ledger, settings).
import 'dart:math';

import 'package:flutter/material.dart';

import '../state/estate_state.dart';
import '../widgets/tokens.dart';

/// Markdown-style document editor.
class DocumentsView extends StatefulWidget {
  final EstateState state;
  const DocumentsView({super.key, required this.state});

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<DocumentsView> {
  int _selected = 0;
  late final TextEditingController _controller;

  static const _docs = [
    ('README.md', '# VVU Unified Roof\n\nA 25-surface operational control room for the Venture Vision Ubuntu estate.'),
    ('ROADMAP.md', '# Roadmap\n\n- WORM chain hardening\n- 7-stage hologram lifecycle\n- Stitch ZAR payments'),
    ('ARCHITECTURE.md', '# Architecture\n\nFlutter web · 4 microservices · 5 inference gates.'),
    ('POA.md', '# Plan of Action\n\n1. ARM ALL gates\n2. TAKEOFF\n3. Sealed evidence to WORM'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _docs[0].$2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int i) {
    setState(() {
      _selected = i;
      _controller.text = _docs[i].$2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      child: Row(
        children: [
          // Doc list
          Container(
            width: 220,
            color: VvuColors.panel,
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('DOCUMENTS', style: VvuTypography.h2),
                ),
                for (int i = 0; i < _docs.length; i++)
                  _DocItem(
                    name: _docs[i].$1,
                    active: _selected == i,
                    onTap: () => _select(i),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: VvuColors.line),
          // Editor
          Expanded(
            child: Column(
              children: [
                // Toolbar
                Container(
                  height: 36,
                  color: VvuColors.panel,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _ToolBtn(icon: Icons.save_rounded, onTap: () {}),
                      _ToolBtn(icon: Icons.undo_rounded, onTap: () {}),
                      _ToolBtn(icon: Icons.redo_rounded, onTap: () {}),
                      const VerticalDivider(
                          width: 16, color: VvuColors.line),
                      _ToolBtn(icon: Icons.format_bold_rounded, onTap: () {}),
                      _ToolBtn(icon: Icons.format_italic_rounded, onTap: () {}),
                      _ToolBtn(
                          icon: Icons.format_list_bulleted_rounded,
                          onTap: () {}),
                      const Spacer(),
                      Text(_docs[_selected].$1,
                          style: VvuTypography.labelMuted),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const Divider(height: 1, color: VvuColors.line),
                Expanded(
                  child: Container(
                    color: VvuColors.background,
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 13,
                        height: 1.6,
                        color: VvuColors.text,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Begin writing…',
                        hintStyle:
                            TextStyle(color: VvuColors.textFaint),
                      ),
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

class _DocItem extends StatelessWidget {
  final String name;
  final bool active;
  final VoidCallback onTap;
  const _DocItem({
    required this.name,
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
                color: active ? const Color(0xFFE5484D) : Colors.transparent,
              ),
            ),
            color: active ? VvuColors.panelRaised : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.description_outlined,
                  size: 14, color: VvuColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 11,
                    color: active ? VvuColors.text : VvuColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ToolBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      color: VvuColors.textMuted,
      splashRadius: 14,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      padding: EdgeInsets.zero,
    );
  }
}

/// Telemetry spreadsheet view.
class SpreadsheetsView extends StatelessWidget {
  final EstateState state;
  const SpreadsheetsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final rng = Random(13);
    final rows = List.generate(12, (i) {
      return (
        'N-${(1000 + i).toString()}',
        'gqeberha-${i + 1}',
        '${(4.4 + rng.nextDouble() * 0.6).toStringAsFixed(2)} bar',
        '${(180 + rng.nextDouble() * 30).toStringAsFixed(1)} l/s',
        rng.nextBool() ? 'ARMED' : 'OFF',
      );
    });
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TELEMETRY TABLE', style: VvuTypography.h1),
          const SizedBox(height: 4),
          const Text(
            'Live node telemetry · 12 rows · auto-refresh',
            style: VvuTypography.body,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: VvuColors.panel,
                borderRadius: BorderRadius.circular(VvuRadii.md),
                border: Border.all(color: VvuColors.line),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: VvuTypography.labelMuted,
                  dataTextStyle: TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 11,
                    color: VvuColors.textMuted,
                  ),
                  columns: const [
                    DataColumn(label: Text('NODE')),
                    DataColumn(label: Text('CLUSTER')),
                    DataColumn(label: Text('PRESSURE')),
                    DataColumn(label: Text('FLOW')),
                    DataColumn(label: Text('STATE')),
                  ],
                  rows: [
                    for (final r in rows)
                      DataRow(
                        cells: [
                          DataCell(Text(r.$1)),
                          DataCell(Text(r.$2)),
                          DataCell(Text(r.$3)),
                          DataCell(Text(r.$4)),
                          DataCell(
                            Text(
                              r.$5,
                              style: TextStyle(
                                color: r.$5 == 'ARMED'
                                    ? VvuColors.armed
                                    : VvuColors.textFaint,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Publication cards.
class PublicationsView extends StatelessWidget {
  final EstateState state;
  const PublicationsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final pubs = [
      ('VVU Field Manual', 'Operational doctrine for the 25-surface estate.', VvuColors.twin, Icons.menu_book_rounded),
      ('Forge Receipt Spec', 'On-chain receipt minting protocol.', VvuColors.armed, Icons.build_circle_rounded),
      ('ROSCA ZAR Pools', 'Ubuntu savings pools in South African Rand.', VvuColors.studio, Icons.local_fire_department_rounded),
      ('7-Stage Hologram', 'Fresnel lifecycle for digital twins.', const Color(0xFFA3E635), Icons.threed_rotation_rounded),
      ('WORM Chain', 'Write-once read-many audit evidence.', VvuColors.danger, Icons.link_rounded),
      ('Doctor 4-State', 'Healthy, degraded, blocked, unknown.', VvuColors.twin, Icons.health_and_safety_rounded),
    ];
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('PUBLICATIONS', style: VvuTypography.h1),
          const SizedBox(height: 4),
          const Text(
            'Sealed, peer-reviewed artefacts.',
            style: VvuTypography.body,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final p in pubs)
                Container(
                  width: 240,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VvuColors.panel,
                    borderRadius: BorderRadius.circular(VvuRadii.md),
                    border: Border.all(color: VvuColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: p.$3.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(VvuRadii.sm),
                          border:
                              Border.all(color: p.$3.withOpacity(0.4)),
                        ),
                        alignment: Alignment.center,
                        child: Icon(p.$4, size: 16, color: p.$3),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        p.$1,
                        style: const TextStyle(
                          fontFamily: VvuTypography.mono,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: VvuColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.$2,
                        style: const TextStyle(
                          fontFamily: VvuTypography.sans,
                          fontSize: 12,
                          height: 1.4,
                          color: VvuColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// WORM ledger viewer.
class LedgerView extends StatelessWidget {
  final EstateState state;
  const LedgerView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Container(
          color: VvuColors.background,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WORM LEDGER', style: VvuTypography.h1),
              const SizedBox(height: 4),
              Text(
                'Anchor ${state.wormAnchor} · ${state.wormLog.length} entries shown · chain ${state.chainIntact ? 'INTACT' : 'BROKEN'}',
                style: VvuTypography.body,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: VvuColors.panel,
                    borderRadius: BorderRadius.circular(VvuRadii.md),
                    border: Border.all(color: VvuColors.line),
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingTextStyle: VvuTypography.labelMuted,
                      dataTextStyle: TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 11,
                        color: VvuColors.textMuted,
                      ),
                      columns: const [
                        DataColumn(label: Text('SEQ')),
                        DataColumn(label: Text('TIMESTAMP')),
                        DataColumn(label: Text('MESSAGE')),
                        DataColumn(label: Text('HASH')),
                        DataColumn(label: Text('PREV')),
                      ],
                      rows: [
                        for (final e in state.wormLog)
                          DataRow(
                            cells: [
                              DataCell(Text(
                                '#${e.seq.toString().padLeft(4, '0')}',
                                style: TextStyle(
                                  color: VvuColors.text,
                                ),
                              )),
                              DataCell(Text(
                                '${e.ts.hour.toString().padLeft(2, '0')}'
                                ':${e.ts.minute.toString().padLeft(2, '0')}'
                                ':${e.ts.second.toString().padLeft(2, '0')}',
                              )),
                              DataCell(Text(e.message)),
                              DataCell(Text(
                                e.hash,
                                style: TextStyle(
                                  color: VvuColors.twin,
                                ),
                              )),
                              DataCell(Text(
                                e.prevHash,
                                style: TextStyle(
                                  color: VvuColors.textFaint,
                                ),
                              )),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Settings surface.
class SettingsView extends StatefulWidget {
  final EstateState state;
  const SettingsView({super.key, required this.state});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _thresholds = <String, double>{
    'PROVEN': 0.90,
    'INCONCLUSIVE': 0.65,
    'BLOCKED': 0.40,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('SETTINGS', style: VvuTypography.h1),
          const SizedBox(height: 16),
          // Gateway thresholds
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
                const Text('GATEWAY THRESHOLDS',
                    style: VvuTypography.labelMuted),
                const SizedBox(height: 12),
                for (final entry in _thresholds.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 11,
                              color: VvuColors.text,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: VvuColors.studio,
                              inactiveTrackColor: VvuColors.line,
                              thumbColor: VvuColors.studio,
                              trackHeight: 2,
                            ),
                            child: Slider(
                              value: entry.value,
                              min: 0,
                              max: 1,
                              divisions: 100,
                              onChanged: (v) {
                                setState(() {
                                  _thresholds[entry.key] = v;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            entry.value.toStringAsFixed(2),
                            style: const TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 11,
                              color: VvuColors.studio,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Identity & account
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Panel(
                  title: 'IDENTITY',
                  children: [
                    _FieldRow(label: 'Tenant', value: 'gqeberha'),
                    _FieldRow(label: 'User', value: 'ops@vvu.za'),
                    _FieldRow(label: 'Role', value: 'ADMIN'),
                    _FieldRow(
                        label: 'Environment',
                        value: widget.state.environment.label),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Panel(
                  title: 'ACCOUNT',
                  children: [
                    _FieldRow(label: 'Plan', value: 'Enterprise'),
                    _FieldRow(
                        label: 'Surfaces', value: '${25} active'),
                    _FieldRow(
                        label: 'Version',
                        value: 'v${widget.state.appVersion}'),
                    _FieldRow(
                        label: 'Build',
                        value: widget.state.buildHash),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Panel({required this.title, required this.children});

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
          Text(title, style: VvuTypography.labelMuted),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: VvuTypography.micro),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 12,
                color: VvuColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
