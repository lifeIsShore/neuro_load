import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../providers/session_provider.dart';
import '../../providers/sensor_provider.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _subCatController = TextEditingController();
  final TextEditingController _intentController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _recentSubCategories = [
    'Deep Work',
    'Research',
    'Chapter 3',
    'Emails',
    'Code review',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _subCatController.dispose();
    _intentController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startSession() {
    final session = ref.read(sessionProvider);
    if (session.category == null) return;

    ref.read(sessionProvider.notifier).setSubCategory(_subCatController.text);
    ref.read(sessionProvider.notifier).setIntent(_intentController.text);
    ref.read(sessionProvider.notifier).startSession();

    HapticFeedback.mediumImpact();
    context.go('/timer');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final canStart = session.category != null;

    // Listen to face-down sensor
    ref.listen(faceDownStartProvider, (previous, next) {
      if (next == true && canStart) {
        _startSession();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEUROLOAD',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.teal,
                                  letterSpacing: 3,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'New Session',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune, color: AppColors.silverGray),
                      onPressed: () => context.go('/settings'),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── Primary Category ─────────────────────────────────────────
                const _SectionLabel(label: 'SELECT CATEGORY'),
                const SizedBox(height: 12),
                _CategorySelector(
                  selected: session.category,
                  onSelected: (cat) {
                    ref.read(sessionProvider.notifier).selectCategory(cat);
                    HapticFeedback.selectionClick();
                  },
                ),

                const SizedBox(height: 32),

                // ── Sub-Category ─────────────────────────────────────────────
                const _SectionLabel(label: 'WHAT SPECIFICALLY?'),
                const SizedBox(height: 12),
                TextField(
                  controller: _subCatController,
                  maxLength: 30,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Chapter 3, Sprint planning…',
                    counterStyle: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: 8),
                // Suggestion chips
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _recentSubCategories.map((s) {
                    return ActionChip(
                      label: Text(s),
                      labelStyle:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                      backgroundColor: AppColors.surfaceElevated,
                      side: const BorderSide(
                          color: AppColors.silverGrayDim, width: 0.5),
                      onPressed: () => setState(() {
                        _subCatController.text = s;
                      }),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // ── Baseline Aim ─────────────────────────────────────────────
                const _SectionLabel(label: 'BASELINE AIM'),
                const SizedBox(height: 12),
                _BaselineAimSelector(
                  onSelected: (d) =>
                      ref.read(sessionProvider.notifier).setTargetDuration(d),
                  selected: session.targetDuration,
                ),

                const SizedBox(height: 32),

                // ── Intent Statement ─────────────────────────────────────────
                const _SectionLabel(label: 'PRE-FLOW INTENT'),
                const SizedBox(height: 12),
                TextField(
                  controller: _intentController,
                  maxLength: 100,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'I will finish… without…',
                    counterStyle: TextStyle(color: AppColors.textTertiary),
                  ),
                ),

                const SizedBox(height: 48),

                // ── Start Button ─────────────────────────────────────────────
                AnimatedOpacity(
                  opacity: canStart ? 1.0 : 0.35,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: canStart ? _startSession : null,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 22),
                          SizedBox(width: 8),
                          Text('START SESSION'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Or flip phone face-down to start automatically.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category Selector ────────────────────────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  final PrimaryCategory? selected;
  final ValueChanged<PrimaryCategory> onSelected;

  const _CategorySelector({required this.selected, required this.onSelected});

  static const _colors = {
    PrimaryCategory.study: AppColors.categoryStudy,
    PrimaryCategory.work: AppColors.categoryWork,
    PrimaryCategory.creative: AppColors.categoryCreative,
    PrimaryCategory.admin: AppColors.categoryAdmin,
    PrimaryCategory.lifestyle: AppColors.categoryLifestyle,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: PrimaryCategory.values.map((cat) {
        final isSelected = cat == selected;
        final color = _colors[cat] ?? AppColors.teal;
        return GestureDetector(
          onTap: () => onSelected(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.15)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isSelected ? color : AppColors.silverGrayDim,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Text(
              cat.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Baseline Aim ─────────────────────────────────────────────────────────────

class _BaselineAimSelector extends StatelessWidget {
  final Duration? selected;
  final ValueChanged<Duration> onSelected;

  const _BaselineAimSelector(
      {required this.selected, required this.onSelected});

  static const _presets = [
    ('25 min', Duration(minutes: 25)),
    ('45 min', Duration(minutes: 45)),
    ('60 min', Duration(minutes: 60)),
    ('90 min', Duration(minutes: 90)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _presets.map((preset) {
        final (label, duration) = preset;
        final isSelected = selected == duration;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(duration),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.teal.withOpacity(0.15)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.teal : AppColors.silverGrayDim,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? AppColors.teal
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 2,
          ),
    );
  }
}
