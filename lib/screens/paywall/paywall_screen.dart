import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../providers/subscription_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _redeeming = false;

  // ── Beta flag ────────────────────────────────────────────────────────────────
  // Stripe checkout is disabled during beta to avoid accidental real payments.
  // To re-enable: set _betaMode = false, restore the Stripe imports and
  // _launchStripeCheckout() method from S4-001-STRIPE-SETUP.md / git history.
  static const bool _betaMode = true;

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
                      color: AppColors.teal.withOpacity(0.4), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scarcity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppColors.teal.withOpacity(0.4),
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

              // ── Primary CTA ────────────────────────────────────────────────
              // BETA: payment is disabled. Button shows a greyed-out state
              // and explains to use a voucher code instead.
              // Re-enable by setting _betaMode = false before public launch.
              if (isPaid)
                const SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text('UNLOCKED \u2713'),
                  ),
                )
              else if (_betaMode)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _showBetaNotice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.textTertiary,
                          side: const BorderSide(
                              color: AppColors.silverGrayDim, width: 0.5),
                        ),
                        child: const Text('PAYMENT COMING SOON'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beta build \u2014 use your tester code below to unlock.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                // Production CTA — restore full _launchStripeCheckout() here
                const SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: null, // wire to _launchStripeCheckout
                    child: Text('UNLOCK NEUROLOAD \u2014 \u20ac49'),
                  ),
                ),

              const SizedBox(height: 12),

              // Voucher CTA — always visible
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: (_redeeming || isPaid) ? null : _showVoucherInput,
                  child: Text(
                    isPaid ? 'Unlocked' : 'I have a voucher code',
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

  // ── Beta notice ────────────────────────────────────────────────────────────

  void _showBetaNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment is not available in this beta build. '
          'Use your tester voucher code to unlock full access.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
      ),
    );
  }

  // ── Voucher redemption ─────────────────────────────────────────────────────
  //
  // Accepts exactly 8 uppercase alphanumeric characters (A-Z, 0-9).
  // Post-beta TODO: validate against Supabase RPC claim_voucher(code)
  // instead of accepting any correctly-formatted code.

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
              const SizedBox(height: 4),
              Text(
                '8 characters — letters and numbers only.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLength: 8,
                textCapitalization: TextCapitalization.characters,
                // Only allow A-Z and 0-9 while typing
                onChanged: (v) {
                  final clean =
                      v.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
                  if (clean != v) {
                    controller.value = TextEditingValue(
                      text: clean,
                      selection: TextSelection.collapsed(offset: clean.length),
                    );
                  }
                },
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 6,
                      color: AppColors.teal,
                    ),
                decoration: const InputDecoration(
                  hintText: 'AB12CD34',
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

                          // Strict validation: exactly 8 uppercase
                          // alphanumeric characters.
                          if (!RegExp(r'^[A-Z0-9]{8}$').hasMatch(code)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Invalid code. Must be exactly 8 letters/numbers.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          setModal(() => _redeeming = true);

                          // Simulate network check during beta.
                          // POST-BETA: replace with Supabase RPC call
                          // to validate the code against the voucher table.
                          await Future.delayed(
                              const Duration(milliseconds: 800));

                          if (ctx.mounted) Navigator.pop(ctx);

                          // Mark paid — the isPaidProvider listener
                          // auto-navigates to /setup.
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
