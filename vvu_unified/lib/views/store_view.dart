// VVU Unified Roof — Store surface with real Stitch integration.
import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/stitch_api.dart';
import '../state/estate_state.dart';
import '../widgets/tokens.dart';

/// STORE surface: subscriptions, products, cart, and Stitch checkout.
class StoreView extends StatefulWidget {
  final EstateState state;
  const StoreView({super.key, required this.state});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreTier {
  final String id;
  final String name;
  final int amountCents;
  final String blurb;
  final bool highlighted;
  const _StoreTier({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.blurb,
    this.highlighted = false,
  });
}

class _StoreProduct {
  final String id;
  final String name;
  final int priceCents;
  final String blurb;
  const _StoreProduct({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.blurb,
  });
}

class _StoreViewState extends State<StoreView> {
  static const _accent = VvuColors.studio;

  static const _tiers = [
    _StoreTier(
      id: 'supporter',
      name: 'SUPPORTER',
      amountCents: 4900,
      blurb: 'Single-seat pilot · WORM chain access.',
    ),
    _StoreTier(
      id: 'superfan',
      name: 'SUPER FAN',
      amountCents: 9900,
      blurb: 'All 25 surfaces · 5 inference gates · priority doctor.',
      highlighted: true,
    ),
    _StoreTier(
      id: 'vip',
      name: 'VIP',
      amountCents: 24900,
      blurb: 'Multi-tenant · canary · enterprise SLA.',
    ),
  ];

  // Catalogue seeded locally; replaced if SafeGrid returns products.
  final List<_StoreProduct> _products = [
    _StoreProduct(id: 'p1', name: 'Forge Receipt Pack', priceCents: 9900, blurb: '100 minted WORM receipts.'),
    _StoreProduct(id: 'p2', name: 'Twin Mesh Tile', priceCents: 14900, blurb: 'Photorealistic 3D mesh tile.'),
    _StoreProduct(id: 'p3', name: 'DInSAR Overlay', priceCents: 12900, blurb: 'Millimetre deformation overlay.'),
    _StoreProduct(id: 'p4', name: 'MSFMAMBA License', priceCents: 19900, blurb: 'Per-seat sensor-fusion license.'),
    _StoreProduct(id: 'p5', name: 'Surv Tamper Kit', priceCents: 7900, blurb: 'Surveillance tamper detection.'),
    _StoreProduct(id: 'p6', name: 'ROSCA Pool Seat', priceCents: 4900, blurb: 'Annual ROSCA pool membership.'),
  ];

  final Map<String, int> _cart = {};
  bool _loadingProducts = true;
  String? _busy;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    final r = await SafeGridApi.getProducts();
    if (r.ok && r.data != null && r.data!.isNotEmpty) {
      final parsed = <_StoreProduct>[];
      for (final p in r.data!) {
        if (p is! Map) continue;
        parsed.add(_StoreProduct(
          id: (p['id'] ?? '').toString(),
          name: (p['name'] ?? 'Untitled').toString(),
          priceCents: (p['priceCents'] is int
              ? p['priceCents'] as int
              : ((p['priceCents'] ?? 0) as num).toInt()),
          blurb: (p['blurb'] ?? '').toString(),
        ));
      }
      if (parsed.isNotEmpty) {
        setState(() {
          _products
            ..clear()
            ..addAll(parsed);
        });
      }
    }
    setState(() => _loadingProducts = false);
  }

  int get _cartTotal => _products.fold<int>(
        0,
        (sum, p) => sum + p.priceCents * (_cart[p.id] ?? 0),
      );

  void _add(String id) {
    setState(() => _cart[id] = (_cart[id] ?? 0) + 1);
  }

  void _remove(String id) {
    final v = (_cart[id] ?? 0) - 1;
    if (v <= 0) {
      _cart.remove(id);
    } else {
      _cart[id] = v;
    }
    setState(() {});
  }

  Future<void> _subscribe(_StoreTier t) async {
    setState(() => _busy = t.id);
    final r = await StitchApi.createPaymentLink(
      amountCents: t.amountCents,
      payerName: 'ops@vvu.za',
      merchantReference: 'sub_${t.id}_${DateTime.now().millisecondsSinceEpoch}',
    );
    setState(() => _busy = null);
    _showResult(context, r, title: '${t.name} subscription');
  }

  Future<void> _checkout() async {
    if (_cartTotal == 0) return;
    setState(() => _busy = 'checkout');
    final r = await StitchApi.createPaymentLink(
      amountCents: _cartTotal,
      payerName: 'ops@vvu.za',
      merchantReference: 'cart_${DateTime.now().millisecondsSinceEpoch}',
    );
    setState(() => _busy = null);
    _showResult(context, r, title: 'Cart checkout');
  }

  void _showResult(
    BuildContext context,
    ApiResult<Map<String, dynamic>> r, {
    required String title,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VvuColors.panelRaised,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: VvuTypography.mono,
            fontSize: 14,
            color: VvuColors.text,
          ),
        ),
        content: SizedBox(
          width: 360,
          child: r.ok && r.data != null
              ? SelectableText(
                  'Payment link created.\n\n'
                  'URL: ${r.data!['url'] ?? r.data!['paymentUrl'] ?? '(no URL returned)'}\n'
                  'Reference: ${r.data!['merchantReference'] ?? '-'}',
                  style: TextStyle(
                    fontFamily: VvuTypography.mono,
                    fontSize: 11,
                    color: VvuColors.text,
                  ),
                )
              : Text(
                  'Stitch request failed.\n\n${r.error ?? 'Unknown error'}',
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
            child: const Text(
              'CLOSE',
              style: TextStyle(color: _accent),
            ),
          ),
        ],
      ),
    );
    if (r.ok) {
      widget.state.appendLogPublic('store payment link created · $title');
    }
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
                child: const Icon(Icons.storefront_rounded,
                    size: 18, color: _accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('STORE', style: VvuTypography.h1),
                    Text(
                      'Subscriptions · products · cart · Stitch ZAR checkout.',
                      style: VvuTypography.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!StitchApi.isConfigured)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: VvuColors.warn.withOpacity(0.10),
                borderRadius: BorderRadius.circular(VvuRadii.sm),
                border: Border.all(color: VvuColors.warn.withOpacity(0.4)),
              ),
              child: Text(
                'Stitch not configured — payment link requests will fail but UI remains explorable.',
                style: TextStyle(
                  fontFamily: VvuTypography.mono,
                  fontSize: 10,
                  color: VvuColors.warn,
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Subscription tiers
          LayoutBuilder(
            builder: (context, c) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final t in _tiers)
                    Container(
                      width: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: VvuColors.panel,
                        borderRadius: BorderRadius.circular(VvuRadii.md),
                        border: Border.all(
                          color: t.highlighted
                              ? _accent
                              : VvuColors.line,
                          width: t.highlighted ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.highlighted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.18),
                                borderRadius:
                                    BorderRadius.circular(VvuRadii.sm),
                              ),
                              child: const Text(
                                'MOST POPULAR',
                                style: TextStyle(
                                  fontFamily: VvuTypography.mono,
                                  fontSize: 8,
                                  letterSpacing: 1.4,
                                  color: _accent,
                                ),
                              ),
                            ),
                          Text(
                            t.name,
                            style: TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 14,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w600,
                              color:
                                  t.highlighted ? _accent : VvuColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'R ${(t.amountCents / 100).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontFamily: VvuTypography.mono,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: t.highlighted
                                      ? _accent
                                      : VvuColors.text,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('/mo',
                                  style: VvuTypography.micro),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t.blurb,
                            style: const TextStyle(
                              fontFamily: VvuTypography.sans,
                              fontSize: 12,
                              height: 1.4,
                              color: VvuColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _StoreBtn(
                            label: _busy == t.id ? '…' : 'SUBSCRIBE',
                            accent: _accent,
                            filled: t.highlighted,
                            onTap: _busy == t.id ? null : () => _subscribe(t),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // Product catalogue
          const Text('PRODUCT CATALOGUE', style: VvuTypography.labelMuted),
          const SizedBox(height: 8),
          if (_loadingProducts)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: _accent),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, c) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final p in _products)
                      Container(
                        width: 280,
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
                              p.name,
                              style: const TextStyle(
                                fontFamily: VvuTypography.mono,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: VvuColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.blurb,
                              style: const TextStyle(
                                fontFamily: VvuTypography.sans,
                                fontSize: 12,
                                height: 1.4,
                                color: VvuColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'R ${(p.priceCents / 100).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: VvuTypography.mono,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _accent,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => _remove(p.id),
                                  icon: const Icon(Icons.remove_rounded,
                                      size: 16),
                                  color: VvuColors.textMuted,
                                  constraints: const BoxConstraints(
                                      minWidth: 28, minHeight: 28),
                                  padding: EdgeInsets.zero,
                                ),
                                Text(
                                  '${_cart[p.id] ?? 0}',
                                  style: const TextStyle(
                                    fontFamily: VvuTypography.mono,
                                    fontSize: 12,
                                    color: VvuColors.text,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _add(p.id),
                                  icon: const Icon(Icons.add_rounded,
                                      size: 16),
                                  color: _accent,
                                  constraints: const BoxConstraints(
                                      minWidth: 28, minHeight: 28),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 24),
          // Cart
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
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_rounded,
                        size: 16, color: _accent),
                    const SizedBox(width: 8),
                    const Text('CART', style: VvuTypography.labelMuted),
                    const Spacer(),
                    Text(
                      'R ${(_cartTotal / 100).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: VvuTypography.mono,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_cart.isEmpty)
                  const Text('Cart is empty.',
                      style: TextStyle(
                          fontFamily: VvuTypography.sans,
                          fontSize: 12,
                          color: VvuColors.textMuted))
                else
                  for (final entry in _cart.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_products.firstWhere((p) => p.id == entry.key).name} × ${entry.value}',
                              style: const TextStyle(
                                fontFamily: VvuTypography.mono,
                                fontSize: 11,
                                color: VvuColors.textMuted,
                              ),
                            ),
                          ),
                          Text(
                            'R ${((_products.firstWhere((p) => p.id == entry.key).priceCents * entry.value) / 100).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: VvuTypography.mono,
                              fontSize: 11,
                              color: VvuColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 10),
                _StoreBtn(
                  label: _busy == 'checkout'
                      ? 'CREATING LINK…'
                      : 'CHECKOUT VIA STITCH',
                  accent: _accent,
                  filled: true,
                  onTap: _cartTotal == 0 || _busy == 'checkout'
                      ? null
                      : _checkout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ZAR discipline notice
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: VvuColors.ink,
              borderRadius: BorderRadius.circular(VvuRadii.sm),
              border: Border.all(color: VvuColors.line),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: VvuColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ZAR DISCIPLINE — every price on this surface is denominated in South African Rand. '
                    'Stitch payments are settled in ZAR. Refunds honour POPIA.',
                    style: TextStyle(
                      fontFamily: VvuTypography.sans,
                      fontSize: 11,
                      height: 1.4,
                      color: VvuColors.textMuted,
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

class _StoreBtn extends StatelessWidget {
  final String label;
  final Color accent;
  final bool filled;
  final VoidCallback? onTap;
  const _StoreBtn({
    required this.label,
    required this.accent,
    required this.filled,
    this.onTap,
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
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: filled ? accent : accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(VvuRadii.sm),
            border: Border.all(
              color: accent.withOpacity(filled ? 1.0 : 0.5),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: VvuTypography.mono,
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
              color: filled ? VvuColors.background : accent,
            ),
          ),
        ),
      ),
    );
  }
}
