import 'package:flutter/material.dart';

import '../../providers/sensor_provider.dart' show ZombieSession;

// ── Zombie Recovery Modal ─────────────────────────────────────────────────────
//
// Shown on app launch when an incomplete (zombie) session is detected.
// Blocks all navigation until the user explicitly Resume or Discards.

class ZombieRecoveryModal extends StatefulWidget {
  final ZombieSession zombie;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  const ZombieRecoveryModal({
    super.key,
    required this.zombie,
    required this.onResume,
    required this.onDiscard,
  });

  @override
  State<ZombieRecoveryModal> createState() => _ZombieRecoveryModalState();
}

class _ZombieRecoveryModalState extends State<ZombieRecoveryModal>
    with SingleTickerProviderStateMixin {
  bool _confirmingDiscard = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m ago';
    }
    if (d.inMinutes >= 1) return '${d.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final dur = widget.zombie.duration;
    final raw = widget.zombie.category;
    final categoryLabel = raw[0].toUpperCase() + raw.substring(1);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF505050).withOpacity(0.5),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Opacity(
                      opacity: _pulseAnim.value,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE53E3E).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: Color(0xFFE53E3E),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Unfinished Session',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Info chip ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF505050).withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Color(0xFF888888),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$categoryLabel — started ${_formatDuration(dur)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Your previous session was interrupted. Resume where you left off, or discard it to start fresh.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 28),

              // ── Resume CTA ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onResume,
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Resume Session'),
                ),
              ),
              const SizedBox(height: 10),

              // ── Discard (with 2-step confirm) ─────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _confirmingDiscard
                    ? _ConfirmDiscardRow(
                        key: const ValueKey('confirm'),
                        onConfirm: widget.onDiscard,
                        onCancel: () =>
                            setState(() => _confirmingDiscard = false),
                      )
                    : SizedBox(
                        key: const ValueKey('discard'),
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => _confirmingDiscard = true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE53E3E),
                            side: const BorderSide(
                              color: Color(0xFF742A2A),
                              width: 1,
                            ),
                          ),
                          child: const Text('Discard'),
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

// ── Confirm Discard Row ───────────────────────────────────────────────────────
//
// Replaces the single Discard button with a side-by-side "Keep / Yes, discard"
// pair so the user has to make a deliberate second tap.

class _ConfirmDiscardRow extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmDiscardRow({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(onPressed: onCancel, child: const Text('Keep')),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, discard'),
          ),
        ),
      ],
    );
  }
}
