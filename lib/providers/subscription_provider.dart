import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Keys ──────────────────────────────────────────────────────────────────────

const _kIsPaid = 'subscription_is_paid';
const _kFreeSessionsUsed = 'subscription_free_sessions_used';

/// How many sessions a free user gets before hitting the paywall.
const kFreeSessionLimit = 1;

// ── Providers ─────────────────────────────────────────────────────────────────

/// True if the user has purchased NeuroLoad Plus (or redeemed a voucher).
/// Backed by SharedPreferences — survives app restarts.
final isPaidProvider = StateNotifierProvider<SubscriptionNotifier, bool>((ref) {
  return SubscriptionNotifier();
});

/// How many completed sessions the free user has burned through.
final freeSessionsUsedProvider =
    StateNotifierProvider<FreeSessionsNotifier, int>((ref) {
  return FreeSessionsNotifier();
});

/// True when the user has exhausted their free sessions AND is not paid.
final paywallGateProvider = Provider<bool>((ref) {
  final paid = ref.watch(isPaidProvider);
  final used = ref.watch(freeSessionsUsedProvider);
  return !paid && used >= kFreeSessionLimit;
});

// ── SubscriptionNotifier ──────────────────────────────────────────────────────

class SubscriptionNotifier extends StateNotifier<bool> {
  SubscriptionNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kIsPaid) ?? false;
  }

  /// Call this after Stripe confirms payment or a valid voucher is redeemed.
  Future<void> markPaid() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPaid, true);
    state = true;
  }

  /// For testing / admin: revoke paid status.
  Future<void> revoke() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPaid, false);
    state = false;
  }
}

// ── FreeSessionsNotifier ──────────────────────────────────────────────────────

class FreeSessionsNotifier extends StateNotifier<int> {
  FreeSessionsNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_kFreeSessionsUsed) ?? 0;
  }

  /// Increment after each completed session. Called from SessionNotifier.finishSession().
  Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final next = state + 1;
    await prefs.setInt(_kFreeSessionsUsed, next);
    state = next;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFreeSessionsUsed, 0);
    state = 0;
  }
}
