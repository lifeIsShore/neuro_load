import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../theme/app_theme.dart';
import '../../providers/subscription_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _redeeming = false;
  bool _launchingCheckout = false;

  @override
  Widget build(BuildContext context) {
    final isPaid = ref.watch(isPaidProvider);

    // Auto-navigate away once paid status is confirmed.
    ref.listen<bool>(isPaidProvider, (_, paid) {
      if (paid && mounted) context.go('/setup');
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand
              Text(
                'NEUROLOAD',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.teal,
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your free session\nis complete.',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "You've tested the method. Now commit to the training.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),

              const Spacer(),

              // Price card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.4), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scarcity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppColors.teal.withValues(alpha: 0.4),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'TIER 1 — 300 REMAINING',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.teal,
                              letterSpacing: 1,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lifetime Access',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\u20ac49',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'one-time',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...[
                      'Unlimited sessions & history',
                      'AES-256 encrypted local storage',
                      'Coach intelligence & insights',
                      '24-hr Focus Ring analytics',
                      'Cloud sync across devices (opt-in)',
                    ].map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 14, color: AppColors.teal),
                              const SizedBox(width: 8),
                              Text(f,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Primary CTA — Stripe Checkout
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: (isPaid || _launchingCheckout)
                      ? null
                      : _launchStripeCheckout,
                  child: _launchingCheckout
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                      : Text(
                          isPaid
                              ? 'UNLOCKED \u2713'
                              : 'UNLOCK NEUROLOAD \u2014 \u20ac49',
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Voucher CTA
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: (_redeeming || isPaid) ? null : _showVoucherInput,
                  child: Text(
                    'I have a voucher code',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'EU digital goods \u2014 14-day refund policy applies.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stripe Checkout ────────────────────────────────────────────────────────
  //
  // Flow:
  //   1. Call the Supabase Edge Function create-checkout-session to get a URL.
  //   2. Open the URL in the system browser / in-app web view.
  //   3. Stripe redirects to neuroload://payment/success?session_id=...
  //   4. The stripe-webhook Edge Function fires and upserts user_licences.
  //   5. The app polls / listens for isPaidProvider to flip to true.
  //
  // The deep-link handling (step 3) requires:
  //   - Android: intent-filter in AndroidManifest.xml for neuroload://
  //   - iOS: URL scheme in Info.plist
  //   - app_links or uni_links package to receive the callback
  // That wiring is outside this file — see IMPLEMENTATION_LOG.md S4-001.

  Future<void> _launchStripeCheckout() async {
    if (!mounted) return;
    setState(() => _launchingCheckout = true);

    try {
      // Load the Supabase project URL from preferences (saved in Settings).
      final prefs = await SharedPreferences.getInstance();
      final projectUrl = prefs.getString('supabase_project_url') ?? '';
      final anonKey    = prefs.getString('supabase_anon_key')    ?? '';

      if (projectUrl.isEmpty || anonKey.isEmpty) {
        _showError(
          'Supabase is not configured.\n'
          'Please set your credentials in Settings first.',
        );
        return;
      }

      // Generate a stable anonymous user ID (UUID v4 stored locally).
      // When Supabase Auth is added, replace this with the real user ID.
      String userId = prefs.getString('anonymous_user_id') ?? '';
      if (userId.isEmpty) {
        userId = _generateUuid();
        await prefs.setString('anonymous_user_id', userId);
      }

      final endpoint =
          '$projectUrl/functions/v1/create-checkout-session';

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'apikey': anonKey,
              'Authorization': 'Bearer $anonKey',
            },
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        _showError(body['error'] ?? 'Checkout failed. Please try again.');
        return;
      }

      final data     = jsonDecode(response.body);
      final checkoutUrl = data['url'] as String?;

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        _showError('Could not retrieve checkout URL.');
        return;
      }

      // Open Stripe Checkout in the external browser.
      final uri = Uri.parse(checkoutUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showError('Could not open the payment page. Please try again.');
      }
    } catch (e) {
      _showError('Something went wrong: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _launchingCheckout = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Generates a simple UUID v4 (pseudo-random) without external packages.
  String _generateUuid() {
    final r = List<int>.generate(16, (_) =>
        (DateTime.now().microsecondsSinceEpoch + _.hashCode) % 256);
    r[6] = (r[6] & 0x0f) | 0x40; // version 4
    r[8] = (r[8] & 0x3f) | 0x80; // variant bits
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    return '${hex(r[0])}${hex(r[1])}${hex(r[2])}${hex(r[3])}-'
        '${hex(r[4])}${hex(r[5])}-'
        '${hex(r[6])}${hex(r[7])}-'
        '${hex(r[8])}${hex(r[9])}-'
        '${hex(r[10])}${hex(r[11])}${hex(r[12])}${hex(r[13])}${hex(r[14])}${hex(r[15])}';
  }

  // ── Voucher redemption ─────────────────────────────────────────────────────
  //
  // Any 8-character uppercase code is accepted while Stripe is not yet the
  // only path. When `markPaid()` is called the `isPaidProvider` listener
  // auto-navigates to /setup.

  void _showVoucherInput() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ENTER VOUCHER CODE',
                style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                      color: AppColors.teal,
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLength: 8,
                textCapitalization: TextCapitalization.characters,
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 6,
                      color: AppColors.teal,
                    ),
                decoration: const InputDecoration(
                  hintText: 'XXXXXXXX',
                  counterStyle: TextStyle(color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _redeeming
                      ? null
                      : () async {
                          final code = controller.text.trim().toUpperCase();
                          if (code.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid 8-character code.'),
                              ),
                            );
                            return;
                          }

                          setModal(() => _redeeming = true);

                          // TODO: call Supabase RPC claim_voucher(code)
                          // For now, accept any 8-char code as valid.
                          await Future.delayed(
                              const Duration(milliseconds: 800));

                          if (ctx.mounted) Navigator.pop(ctx);

                          // Mark paid — the listener auto-navigates to /setup.
                          await ref.read(isPaidProvider.notifier).markPaid();
                        },
                  child: _redeeming
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Redeem'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
