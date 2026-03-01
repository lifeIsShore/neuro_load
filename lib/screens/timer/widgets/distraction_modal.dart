import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/session_provider.dart';

class DistractionModal extends StatefulWidget {
  final String? intent;
  final void Function(DistractionTrigger trigger, String? note)
      onTriggerSelected;

  const DistractionModal({
    super.key,
    required this.intent,
    required this.onTriggerSelected,
  });

  @override
  State<DistractionModal> createState() => _DistractionModalState();
}

class _DistractionModalState extends State<DistractionModal> {
  static const _autoDismissDuration = 5;
  Timer? _timer;
  int _remaining = _autoDismissDuration;
  DistractionTrigger? _selectedTrigger;
  final TextEditingController _noteController = TextEditingController();
  bool _showNote = false;
  bool _flashing = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        _flashIntent();
      }
    });
  }

  void _flashIntent() async {
    if (widget.intent != null && widget.intent!.isNotEmpty) {
      setState(() => _flashing = true);
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    if (mounted) Navigator.pop(context);
    widget.onTriggerSelected(
      _selectedTrigger ?? DistractionTrigger.involuntary,
      null,
    );
  }

  void _selectTrigger(DistractionTrigger trigger) {
    _timer?.cancel();
    setState(() {
      _selectedTrigger = trigger;
      _showNote = true;
    });
    HapticFeedback.selectionClick();
  }

  void _submitSelection() {
    final note = _noteController.text.trim();
    // Validate 4-word max
    final words = note.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (words > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 4 words for the note')),
      );
      return;
    }
    Navigator.pop(context);
    widget.onTriggerSelected(_selectedTrigger!, note.isEmpty ? null : note);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flashing && widget.intent != null) {
      return _IntentFlash(intent: widget.intent!);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle + countdown bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.silverGrayDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Countdown bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 0.0),
              duration: Duration(seconds: _autoDismissDuration),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.surfaceElevated,
                valueColor:
                    AlwaysStoppedAnimation(AppColors.teal.withOpacity(0.7)),
                minHeight: 2,
              ),
            ),
            const SizedBox(height: 16),

            if (!_showNote) ...[
              Text(
                'WHAT PULLED YOU AWAY?',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
                children: DistractionTrigger.values
                    .where((t) => t != DistractionTrigger.involuntary)
                    .map((trigger) => _TriggerTile(
                          trigger: trigger,
                          onTap: () => _selectTrigger(trigger),
                        ))
                    .toList(),
              ),
            ] else ...[
              Text(
                '${_selectedTrigger?.emoji ?? ''} ${_selectedTrigger?.label ?? ''}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.teal,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                autofocus: true,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Quick note (max 4 words)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onTriggerSelected(
                          _selectedTrigger!,
                          null,
                        );
                      },
                      child: const Text('Skip note'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitSelection,
                      child: const Text('Log It'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TriggerTile extends StatelessWidget {
  final DistractionTrigger trigger;
  final VoidCallback onTap;

  const _TriggerTile({required this.trigger, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(trigger.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              trigger.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Intent Flash overlay ─────────────────────────────────────────────────────

class _IntentFlash extends StatelessWidget {
  final String intent;
  const _IntentFlash({required this.intent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'YOUR INTENT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.teal,
                    letterSpacing: 3,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '"$intent"',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
