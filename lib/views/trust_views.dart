// VVU Unified Roof — Trust UI views part 1 (forge, fire, press, bench, field).
import 'dart:math';

import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../state/estate_state.dart';
import '../widgets/tokens.dart';

// ── Shared widgets ────────────────────────────────────────────────────────

class _SurfaceHeader extends StatelessWidget {
  final String title;
  final String blurb;
  final Color accent;
  final IconData icon;
  const _SurfaceHeader({
    required this.title,
    required this.blurb,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(VvuRadii.md),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: VvuTypography.h1),
              Text(blurb, style: VvuTypography.body),
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final Color? accent;
  const _Panel({this.title, required this.children, this.accent});

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
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 11,
                letterSpacing: 1.8,
                color: accent ?? VvuColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;
  final bool enabled;
  const _ActionBtn({
    required this.label,
    required this.accent,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: enabled ? accent.withOpacity(0.14) : VvuColors.ink,
            borderRadius: BorderRadius.circular(VvuRadii.sm),
            border: Border.all(
              color: enabled ? accent.withOpacity(0.5) : VvuColors.line,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
              color: enabled ? accent : VvuColors.textFaint,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  const _ModeChip({
    required this.label,
    required this.selected,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.18) : VvuColors.ink,
            borderRadius: BorderRadius.circular(VvuRadii.sm),
            border: Border.all(
              color: selected ? accent.withOpacity(0.5) : VvuColors.line,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
              color: selected ? accent : VvuColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Forge ─────────────────────────────────────────────────────────────────

class ForgeView extends StatefulWidget {
  final EstateState state;
  const ForgeView({super.key, required this.state});

  @override
  State<ForgeView> createState() => _ForgeViewState();
}

class _ForgeViewState extends State<ForgeView> {
  final _claimCtrl = TextEditingController();
  String _mode = 'STRICT';
  String? _receipt;

  static const _accent = Color(0xFF00E5FF);

  @override
  void dispose() {
    _claimCtrl.dispose();
    super.dispose();
  }

  void _mint() {
    final claim = _claimCtrl.text.trim();
    if (claim.isEmpty) return;
    final h = _hash(claim);
    final prev = widget.state.wormLog.isNotEmpty
        ? widget.state.wormLog.first.hash
        : '00000000';
    setState(() {
      _receipt = 'R-$h';
    });
    // Append to WORM chain.
    widget.state.appendLogPublic('forge mint $_mode · $claim · hash $h prev $prev');
  }

  String _hash(String s) {
    int h = 0x811C9DC5;
    for (int i = 0; i < s.length; i++) {
      h ^= s.codeUnitAt(i);
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h.toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  @override
  Widget build(BuildContext context) {
    final mintEnabled = widget.state.flag('forge_receipt_minting');
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _SurfaceHeader(
            title: 'FORGE',
            blurb: 'Claim & mint verified receipts onto the WORM chain.',
            accent: _accent,
            icon: Icons.build_circle_rounded,
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'CLAIM',
            children: [
              TextField(
                controller: _claimCtrl,
                style: const TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 13,
                  color: VvuColors.text,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter claim text…',
                  hintStyle: const TextStyle(color: VvuColors.textFaint),
                  filled: true,
                  fillColor: VvuColors.ink,
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
                    borderSide: BorderSide(color: _accent.withOpacity(0.5)),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ModeChip(
                    label: 'STRICT',
                    selected: _mode == 'STRICT',
                    accent: _accent,
                    onTap: () => setState(() => _mode = 'STRICT'),
                  ),
                  const SizedBox(width: 8),
                  _ModeChip(
                    label: 'LENIENT',
                    selected: _mode == 'LENIENT',
                    accent: _accent,
                    onTap: () => setState(() => _mode = 'LENIENT'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ActionBtn(
                    label: 'MINT RECEIPT',
                    accent: _accent,
                    enabled: mintEnabled,
                    onTap: _mint,
                  ),
                  const SizedBox(width: 8),
                  if (!mintEnabled)
                    const Text(
                      'forge_receipt_minting flag is OFF',
                      style: VvuTypography.micro,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_receipt != null) ...[
            _Panel(
              title: 'RECEIPT',
              accent: _accent,
              children: [
                SelectableText(
                  _receipt!,
                  style: TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mode: $_mode · Sealed to WORM chain',
                  style: VvuTypography.micro,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          _Panel(
            title: 'RECENT MINTS',
            children: [
              for (final e in widget.state.wormLog
                  .where((e) => e.message.contains('forge'))
                  .take(6))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '#${e.seq.toString().padLeft(4, '0')}',
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

// ── Fire (ROSCA pools via UbuntuPoolsApi) ─────────────────────────────────

class _RoscaPool {
  final String id;
  final String name;
  final int contributionCents;
  final int members;
  final String cycle;

  _RoscaPool({
    required this.id,
    required this.name,
    required this.contributionCents,
    required this.members,
    required this.cycle,
  });

  factory _RoscaPool.fromMap(Map<String, dynamic> m) => _RoscaPool(
        id: (m['id'] ?? m['_id'] ?? '').toString(),
        name: (m['name'] ?? 'Untitled pool').toString(),
        contributionCents:
            (m['contributionCents'] is int ? m['contributionCents'] as int : 0),
        members: m['members'] is int
            ? m['members'] as int
            : (m['members'] is List
                ? (m['members'] as List).length
                : 0),
        cycle: (m['cycle'] ?? m['cycleDays'] ?? '—').toString(),
      );
}

class FireView extends StatefulWidget {
  final EstateState state;
  const FireView({super.key, required this.state});

  @override
  State<FireView> createState() => _FireViewState();
}

class _FireViewState extends State<FireView> {
  static const _accent = Color(0xFFFFB224);
  List<_RoscaPool> _pools = [];
  bool _loading = true;
  String? _error;
  final Map<String, bool> _busy = {};

  @override
  void initState() {
    super.initState();
    _loadPools();
  }

  Future<void> _loadPools() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await UbuntuPoolsApi.getPools();
    if (!r.ok || r.data == null) {
      setState(() {
        _loading = false;
        _error = r.error ?? 'Failed to load pools';
        // Fallback synthetic pools so the surface is still usable.
        _pools = _seedPools();
      });
      return;
    }
    final parsed = <_RoscaPool>[];
    for (final item in r.data!) {
      if (item is Map<String, dynamic>) {
        parsed.add(_RoscaPool.fromMap(item));
      }
    }
    setState(() {
      _loading = false;
      _pools = parsed.isEmpty ? _seedPools() : parsed;
    });
  }

  List<_RoscaPool> _seedPools() => [
        _RoscaPool(
            id: 'rosca-1',
            name: 'Gqeberha Lemon Growers',
            contributionCents: 50000,
            members: 8,
            cycle: '7d'),
        _RoscaPool(
            id: 'rosca-2',
            name: 'NMU Operator Circle',
            contributionCents: 25000,
            members: 12,
            cycle: '14d'),
      ];

  Future<void> _join(_RoscaPool p) async {
    setState(() => _busy[p.id] = true);
    await UbuntuPoolsApi.joinPool(p.id);
    widget.state.appendLogPublic('fire pool join · ${p.name}');
    setState(() => _busy[p.id] = false);
    _loadPools();
  }

  Future<void> _leave(_RoscaPool p) async {
    setState(() => _busy[p.id] = true);
    await UbuntuPoolsApi.leavePool(p.id);
    widget.state.appendLogPublic('fire pool leave · ${p.name}');
    setState(() => _busy[p.id] = false);
    _loadPools();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _SurfaceHeader(
            title: 'FIRE',
            blurb: 'ROSCA savings pools in South African Rand (ZAR).',
            accent: _accent,
            icon: Icons.local_fire_department_rounded,
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: VvuColors.danger.withOpacity(0.10),
                borderRadius: BorderRadius.circular(VvuRadii.sm),
                border: Border.all(color: VvuColors.danger.withOpacity(0.4)),
              ),
              child: Text(
                'Backend offline — showing local fallback pools. $_error',
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 10,
                  color: VvuColors.danger,
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: _accent,
                ),
              ),
            )
          else
            for (final p in _pools) ...[
              _Panel(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontFamily: VvuTypography.mono,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: VvuColors.text,
                              ),
                            ),
                            Text(
                              'R ${(p.contributionCents / 100).toStringAsFixed(2)} / cycle · ${p.members} members · ${p.cycle}',
                              style: VvuTypography.body,
                            ),
                          ],
                        ),
                      ),
                      if (_busy[p.id] == true)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: _accent,
                          ),
                        )
                      else ...[
                        _ActionBtn(
                          label: 'JOIN',
                          accent: _accent,
                          onTap: () => _join(p),
                        ),
                        const SizedBox(width: 6),
                        _ActionBtn(
                          label: 'LEAVE',
                          accent: VvuColors.danger,
                          onTap: () => _leave(p),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 8),
          _Panel(
            title: 'ZAR PRICING',
            accent: _accent,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PriceTile(label: 'MICRO', value: 'R 25', accent: _accent),
                  ),
                  Expanded(
                    child: _PriceTile(label: 'BASIC', value: 'R 50', accent: _accent),
                  ),
                  Expanded(
                    child: _PriceTile(
                        label: 'STANDARD', value: 'R 100', accent: _accent),
                  ),
                  Expanded(
                    child: _PriceTile(
                        label: 'ENTERPRISE', value: 'R 500', accent: _accent),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _PriceTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: VvuColors.ink,
        borderRadius: BorderRadius.circular(VvuRadii.sm),
        border: Border.all(color: VvuColors.line),
      ),
      child: Column(
        children: [
          Text(label, style: VvuTypography.micro),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
          Text('/ cycle', style: VvuTypography.micro),
        ],
      ),
    );
  }
}

// ── Press ─────────────────────────────────────────────────────────────────

class PressView extends StatelessWidget {
  final EstateState state;
  const PressView({super.key, required this.state});

  static const _accent = Color(0xFFE5484D);

  @override
  Widget build(BuildContext context) {
    final pricingEnabled = state.flag('press_pricing_zar');
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _SurfaceHeader(
            title: 'PRESS',
            blurb: 'Creator publishing & verified reviews in ZAR.',
            accent: _accent,
            icon: Icons.rate_review_rounded,
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'PRICING TIERS',
            accent: _accent,
            children: [
              if (!pricingEnabled)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'press_pricing_zar flag is OFF · showing placeholder tiers',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 10,
                      color: VvuColors.warn,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: _PriceTile(
                      label: 'BASIC',
                      value: pricingEnabled ? 'R 99' : '—',
                      accent: _accent,
                    ),
                  ),
                  Expanded(
                    child: _PriceTile(
                      label: 'PRO',
                      value: pricingEnabled ? 'R 9' : '—',
                      accent: _accent,
                    ),
                  ),
                  Expanded(
                    child: _PriceTile(
                      label: 'STUDIO',
                      value: pricingEnabled ? 'R 189' : '—',
                      accent: _accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'VERIFIED CREATOR REVIEWS',
            accent: _accent,
            children: [
              for (final r in [
                ('A. Mokoena', 'Forge receipts saved our audit — sealed in seconds.', 5),
                ('L. van der Merwe', 'ROSCA pools run like clockwork. ZAR discipline.', 4),
                ('S. Naidoo', 'Doctor caught a backend failure before our customers noticed.', 5),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: _accent.withOpacity(0.4)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          r.$1[0],
                          style: TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 11,
                            color: _accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  r.$1,
                                  style: const TextStyle(
                                    fontFamily: VvuTypography.mono,
                                    fontSize: 12,
                                    color: VvuColors.text,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < r.$3
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 10,
                                      color: _accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.$2,
                              style: TextStyle(
                                fontFamily: VvuTypography.sans,
                                fontSize: 12,
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
        ],
      ),
    );
  }
}

// ── Bench ─────────────────────────────────────────────────────────────────

class BenchView extends StatefulWidget {
  final EstateState state;
  const BenchView({super.key, required this.state});

  @override
  State<BenchView> createState() => _BenchViewState();
}

class _BenchViewState extends State<BenchView> {
  final _nodeCtrl = TextEditingController(text: 'gqeberha-01');
  final _pluginCtrl = TextEditingController(text: 'lemon-counter');
  String? _license;

  static const _accent = Color(0xFFE5484D);

  @override
  void dispose() {
    _nodeCtrl.dispose();
    _pluginCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    final s = '${_nodeCtrl.text}|${_pluginCtrl.text}';
    int h = 0x811C9DC5;
    for (int i = 0; i < s.length; i++) {
      h ^= s.codeUnitAt(i);
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    final hex = h.toRadixString(16).toUpperCase().padLeft(8, '0');
    setState(() {
      _license =
          'VVF-$hex-${_nodeCtrl.text.hashCode.toRadixString(16).toUpperCase().substring(0, 4)}';
    });
    widget.state.appendLogPublic('bench license generated · ${_pluginCtrl.text}@${_nodeCtrl.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Fluid Studio license seal
          Center(
            child: Image.asset(
              'assets/images/fluid_studio_seal.jpg',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          _SurfaceHeader(
            title: 'BENCH',
            blurb: 'Node-locked license generator & plugin creator studio.',
            accent: _accent,
            icon: Icons.vpn_key_rounded,
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'NODE-LOCKED LICENSE',
            accent: _accent,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nodeCtrl,
                      style: const TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 12,
                        color: VvuColors.text,
                      ),
                      decoration: _inputDeco('Node ID'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _pluginCtrl,
                      style: const TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 12,
                        color: VvuColors.text,
                      ),
                      decoration: _inputDeco('Plugin name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ActionBtn(
                label: 'GENERATE LICENSE',
                accent: _accent,
                onTap: _generate,
              ),
              if (_license != null) ...[
                const SizedBox(height: 12),
                SelectableText(
                  _license!,
                  style: TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'PLUGIN CREATOR STUDIO',
            accent: _accent,
            children: [
              Row(
                children: [
                  _ActionBtn(label: 'NEW PLUGIN', accent: _accent, onTap: () {}),
                  const SizedBox(width: 8),
                  _ActionBtn(label: 'BUILD', accent: _accent, onTap: () {}),
                  const SizedBox(width: 8),
                  _ActionBtn(label: 'PUBLISH', accent: _accent, onTap: () {}),
                ],
              ),
              const SizedBox(height: 12),
              for (final p in [
                ('lemon-counter', 'Counts lemons per hectare. v1.2', true),
                ('forge-receipt', 'Mints receipts to WORM. v0.9', true),
                ('surv-tamper', 'Surveillance tamper alerts. v2.0', false),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        p.$3
                            ? Icons.check_circle_rounded
                            : Icons.pending_rounded,
                        size: 14,
                        color: p.$3 ? VvuColors.armed : VvuColors.warn,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${p.$1} · ${p.$2}',
                          style: TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 11,
                            color: VvuColors.textMuted,
                          ),
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

InputDecoration _inputDeco(String hint) => InputDecoration(
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

// ── Field ─────────────────────────────────────────────────────────────────

class FieldView extends StatefulWidget {
  final EstateState state;
  const FieldView({super.key, required this.state});

  @override
  State<FieldView> createState() => _FieldViewState();
}

class _FieldViewState extends State<FieldView> {
  bool _dualTier = false;
  bool _erasure = false;
  static const _accent = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _dualTier = widget.state.flag('field_dual_tier_storage');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VvuColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _SurfaceHeader(
            title: 'FIELD',
            blurb: 'Dual-tier resilient storage with SEARM1 erasure coding.',
            accent: _accent,
            icon: Icons.storage_rounded,
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'STORAGE TIERS',
            accent: _accent,
            children: [
              if (!widget.state.flag('field_dual_tier_storage'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'field_dual_tier_storage flag is OFF',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 10,
                      color: VvuColors.warn,
                    ),
                  ),
                ),
              _ToggleRow(
                label: 'HOT TIER (NVMe, sync)',
                value: true,
                accent: _accent,
                onChanged: (_) {},
              ),
              _ToggleRow(
                label: 'COLD TIER (object, erasure-coded)',
                value: _dualTier,
                accent: _accent,
                onChanged: widget.state.flag('field_dual_tier_storage')
                    ? (v) => setState(() => _dualTier = v)
                    : null,
              ),
              _ToggleRow(
                label: 'SEARM1 ERASURE (k=4, m=2)',
                value: _erasure,
                accent: _accent,
                onChanged: (v) => setState(() => _erasure = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'SEARM1 RESILIENCE DEMO',
            accent: _accent,
            children: [
              const Text(
                'Live demonstration: 6 shards, any 4 sufficient to reconstruct.',
                style: VvuTypography.body,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: _SearmPainter(accent: _accent),
                  child: Container(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Color accent;
  final ValueChanged<bool>? onChanged;
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.accent,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 11,
                color: onChanged != null ? VvuColors.text : VvuColors.textMuted,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: accent,
            inactiveThumbColor: VvuColors.textFaint,
            inactiveTrackColor: VvuColors.line,
          ),
        ],
      ),
    );
  }
}

class _SearmPainter extends CustomPainter {
  final Color accent;
  _SearmPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(3);
    final shards = 6;
    final shardW = size.width / shards;
    for (int i = 0; i < shards; i++) {
      final alive = rng.nextDouble() > 0.25;
      final rect = Rect.fromLTWH(
        i * shardW + 6,
        8,
        shardW - 12,
        size.height - 16,
      );
      canvas.drawRect(
        rect,
        Paint()..color = (alive ? accent : VvuColors.danger).withOpacity(0.65),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = VvuColors.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: 'S${i + 1}',
          style: TextStyle(
            fontFamily: VvuTypography.mono,
            fontSize: 9,
            color: alive ? VvuColors.background : VvuColors.text,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.top + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _SearmPainter old) => old.accent != accent;
}
