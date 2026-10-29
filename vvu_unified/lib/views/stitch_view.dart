// VVU Unified Roof — Stitch payment management surface.
import 'package:flutter/material.dart';

import '../services/stitch_api.dart';
import '../state/estate_state.dart';
import '../widgets/tokens.dart';

/// Stitch management surface: config status, balance, link creation, webhooks.
class StitchView extends StatefulWidget {
  final EstateState state;
  const StitchView({super.key, required this.state});

  @override
  State<StitchView> createState() => _StitchViewState();
}

class _StitchViewState extends State<StitchView> {
  static const _accent = VvuColors.studio;

  final _amountCtrl = TextEditingController(text: '100');
  final _nameCtrl = TextEditingController(text: 'ops@vvu.za');
  final _refCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _webhookCtrl =
      TextEditingController(text: 'https://vvu.za/api/stitch/webhook');

  Map<String, dynamic>? _balance;
  String? _balanceError;
  bool _balanceLoading = false;

  String? _linkResult;
  String? _linkError;

  String? _webhookResult;
  String? _webhookError;
  bool _webhookBusy = false;

  @override
  void initState() {
    super.initState();
    _refCtrl.text = 'stitch_${DateTime.now().millisecondsSinceEpoch}';
    _loadBalance();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _refCtrl.dispose();
    _emailCtrl.dispose();
    _webhookCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    setState(() {
      _balanceLoading = true;
      _balanceError = null;
    });
    final r = await StitchApi.getBalance();
    setState(() {
      _balanceLoading = false;
      if (r.ok && r.data != null) {
        _balance = r.data;
      } else {
        _balanceError = r.error ?? 'Failed to load balance';
      }
    });
  }

  Future<void> _createLink({int? forcedAmountCents}) async {
    final amount = forcedAmountCents ??
        (int.tryParse(_amountCtrl.text.trim()) ?? 0);
    if (amount <= 0) return;
    setState(() {
      _linkError = null;
      _linkResult = null;
    });
    final r = await StitchApi.createPaymentLink(
      amountCents: amount,
      payerName: _nameCtrl.text.trim().isEmpty
          ? 'ops@vvu.za'
          : _nameCtrl.text.trim(),
      merchantReference: _refCtrl.text.trim().isEmpty
          ? 'stitch_${DateTime.now().millisecondsSinceEpoch}'
          : _refCtrl.text.trim(),
      payerEmail:
          _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
    );
    setState(() {
      if (r.ok && r.data != null) {
        _linkResult = (r.data!['url'] ??
                r.data!['paymentUrl'] ??
                '(no URL)')
            .toString();
        widget.state.appendLogPublic('stitch link · R${(amount / 100).toStringAsFixed(2)}');
      } else {
        _linkError = r.error ?? 'Failed to create link';
      }
    });
  }

  Future<void> _registerWebhook() async {
    final url = _webhookCtrl.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _webhookBusy = true;
      _webhookError = null;
      _webhookResult = null;
    });
    final r = await StitchApi.registerWebhook(url);
    setState(() {
      _webhookBusy = false;
      if (r.ok && r.data != null) {
        _webhookResult = 'Webhook registered: ${r.data}';
        widget.state.appendLogPublic('stitch webhook registered · $url');
      } else {
        _webhookError = r.error ?? 'Failed to register webhook';
      }
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(VvuRadii.md),
                  border: Border.all(color: _accent.withOpacity(0.4)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.credit_card_rounded,
                    size: 18, color: _accent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('STITCH', style: VvuTypography.h1),
                    Text(
                      'Payment orchestration · ZAR · client-credentials.',
                      style: VvuTypography.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Config status banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: StitchApi.isConfigured
                  ? VvuColors.armed.withOpacity(0.10)
                  : VvuColors.warn.withOpacity(0.10),
              borderRadius: BorderRadius.circular(VvuRadii.sm),
              border: Border.all(
                color: StitchApi.isConfigured
                    ? VvuColors.armed.withOpacity(0.4)
                    : VvuColors.warn.withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  StitchApi.isConfigured
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: StitchApi.isConfigured
                      ? VvuColors.armed
                      : VvuColors.warn,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    StitchApi.isConfigured
                        ? 'Stitch configured — client credentials loaded. Live API calls enabled.'
                        : 'Stitch NOT configured — calls will fail but UI is explorable.',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 10,
                      color: StitchApi.isConfigured
                          ? VvuColors.armed
                          : VvuColors.warn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Balance
          _Panel(
            title: 'ACCOUNT BALANCE',
            accent: _accent,
            child: Row(
              children: [
                Expanded(
                  child: _balanceLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: _accent,
                          ),
                        )
                      : Text(
                          _balance != null
                              ? 'R ${((_balance!['availableCents'] ?? _balance!['balanceCents'] ?? 0) as num).toDouble() / 100}'
                              : _balanceError != null
                                  ? 'Error: $_balanceError'
                                  : '—',
                          style: TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _balance != null
                                ? _accent
                                : VvuColors.danger,
                          ),
                        ),
                ),
                TextButton.icon(
                  onPressed: _loadBalance,
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('REFRESH'),
                  style: TextButton.styleFrom(
                    foregroundColor: _accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Create payment link form
          _Panel(
            title: 'CREATE PAYMENT LINK',
            accent: _accent,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _Field(
                        controller: _amountCtrl,
                        label: 'AMOUNT (cents)',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _Field(
                        controller: _nameCtrl,
                        label: 'PAYER NAME',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _Field(
                        controller: _refCtrl,
                        label: 'MERCHANT REFERENCE',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _Field(
                        controller: _emailCtrl,
                        label: 'PAYER EMAIL (optional)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _createLink(),
                        borderRadius: BorderRadius.circular(VvuRadii.sm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(VvuRadii.sm),
                            border: Border.all(
                                color: _accent.withOpacity(0.5)),
                          ),
                          child: const Text(
                            'CREATE LINK',
                            style: TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 10,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                              color: _accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _createLink(forcedAmountCents: 100),
                        borderRadius: BorderRadius.circular(VvuRadii.sm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: VvuColors.armed.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(VvuRadii.sm),
                            border: Border.all(
                                color: VvuColors.armed.withOpacity(0.5)),
                          ),
                          child: const Text(
                            'CREATE TEST R1.00 LINK',
                            style: TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 10,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                              color: VvuColors.armed,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_linkResult != null) ...[
                  const SizedBox(height: 10),
                  SelectableText(
                    'Payment link: $_linkResult',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 11,
                      color: VvuColors.armed,
                    ),
                  ),
                ],
                if (_linkError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Error: $_linkError',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 11,
                      color: VvuColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Subscriptions panel (informational)
          _Panel(
            title: 'SUBSCRIPTIONS',
            accent: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recurring subscriptions are created via createSubscription() — '
                  'see Store surface for tier-aware subscription flows.',
                  style: TextStyle(
                    fontFamily: VvuTypography.sans,
                    fontSize: 12,
                    color: VvuColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                for (final t in [
                  ('SUPPORTER', 'R 49.00 / month'),
                  ('SUPER FAN', 'R 99.00 / month'),
                  ('VIP', 'R 249.00 / month'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: _accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t.$1,
                          style: const TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 11,
                            color: VvuColors.text,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          t.$2,
                          style: TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 11,
                            color: _accent,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Webhook registration
          _Panel(
            title: 'WEBHOOK REGISTRATION',
            accent: _accent,
            child: Column(
              children: [
                _Field(
                  controller: _webhookCtrl,
                  label: 'WEBHOOK URL',
                ),
                const SizedBox(height: 10),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _webhookBusy ? null : _registerWebhook,
                    borderRadius: BorderRadius.circular(VvuRadii.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(VvuRadii.sm),
                        border:
                            Border.all(color: _accent.withOpacity(0.5)),
                      ),
                      child: Text(
                        _webhookBusy ? 'REGISTERING…' : 'REGISTER WEBHOOK',
                        style: const TextStyle(
                          fontFamily: VvuTypography.mono,
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w600,
                          color: _accent,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_webhookResult != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _webhookResult!,
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 11,
                      color: VvuColors.armed,
                    ),
                  ),
                ],
                if (_webhookError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Error: $_webhookError',
                    style: TextStyle(
                      fontFamily: VvuTypography.mono,
                      fontSize: 11,
                      color: VvuColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Color accent;
  final Widget child;
  const _Panel({
    required this.title,
    required this.accent,
    required this.child,
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
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _Field({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: VvuTypography.micro),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: VvuTypography.mono,
            fontSize: 12,
            color: VvuColors.text,
          ),
          decoration: InputDecoration(
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
              borderSide: BorderSide(color: VvuColors.lineStrong),
            ),
          ),
        ),
      ],
    );
  }
}
