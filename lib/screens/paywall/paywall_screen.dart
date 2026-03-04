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
              // ── Brand ──────────────────────────────────────────────────────
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
                'You\'ve tested the method. Now commit to the training.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),

              const Spacer(),

              // ── Price card ─────────────────────────────────────────────────
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
                          '€49',
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

                    // Feature list
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
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isPaid
                      ? null
                      : () {
                          // TODO: Open Stripe Checkout
                          // For now, show a "coming soon" snackbar so
                          // the screen is testable end-to-end.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Stripe checkout coming soon — use a voucher for now.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                  child: isPaid
                      ? const Text('UNLOCKED ✓')
                      : const Text('UNLOCK NEUROLOAD — €49'),
                ),
              ),

              const SizedBox(height: 12),

              // ── Voucher CTA ────────────────────────────────────────────────
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
                  'EU digital goods — 14-day refund policy applies.',
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

  // ── Voucher redemption ─────────────────────────────────────────────────────
  //
  // Stub: any 8-character uppercase code is accepted while Stripe is not
  // wired. When `markPaid()` is called the `isPaidProvider` listener above
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
                                  content:
                                      Text('Enter a valid 8-character code.')),
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
