import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _canProceed = false;

  // Page 1 – Manifesto
  final ScrollController _manifestoScrollController = ScrollController();
  bool _hasScrolledManifesto = false;

  // Page 2 – Lap Tutorial
  bool _hasHitDistracted = false;

  // Page 4 – Intent Practice
  final TextEditingController _intentController = TextEditingController();

  // Typewriter effect
  String _typewriterText = '';
  Timer? _typewriterTimer;

  static const String _manifestoFull =
      'Your brain is being trained — just not by you.\n\n'
      'Every notification, every scroll, every tab-switch is a rep. '
      'Your attention is being exercised by algorithms built to distract.\n\n'
      'The result? A Popcorn Brain: one that craves constant input and '
      'loses the ability to hold a single thought longer than 90 seconds.\n\n'
      'NeuroLoad is a gym for the mind.\n\n'
      'Each session is a training block. Each distraction is a rep you log — '
      'not a failure. Your focus is a muscle, and like any muscle, '
      'it can be overloaded, trained, and made stronger.\n\n'
      'This is not a productivity app.\n'
      'This is a discipline system.\n\n'
      'Are you ready to train?';

  @override
  void initState() {
    super.initState();
    _startTypewriter();
    _manifestoScrollController.addListener(() {
      if (_manifestoScrollController.position.pixels >=
          _manifestoScrollController.position.maxScrollExtent - 10) {
        if (!_hasScrolledManifesto) {
          setState(() {
            _hasScrolledManifesto = true;
            _canProceed = true;
          });
        }
      }
    });
  }

  void _startTypewriter() {
    int index = 0;
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 18), (t) {
      if (index < _manifestoFull.length) {
        setState(() {
          _typewriterText = _manifestoFull.substring(0, index + 1);
        });
        index++;
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _pageController.dispose();
    _manifestoScrollController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        _currentPage++;
        _canProceed = _canProceedForPage(_currentPage);
      });
    } else {
      _completeOnboarding();
    }
  }

  bool _canProceedForPage(int page) {
    switch (page) {
      case 0:
        return _hasScrolledManifesto;
      case 1:
        return _hasHitDistracted;
      case 2:
        return true;
      case 3:
        return _intentController.text.length >= 10;
      case 4:
        return true;
      case 5:
        return true;
      default:
        return false;
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    if (mounted) context.go('/setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? AppColors.teal
                          : AppColors.silverGrayDim,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                    _canProceed = _canProceedForPage(page);
                  });
                },
                children: [
                  _ManifestoPage(
                    typewriterText: _typewriterText,
                    scrollController: _manifestoScrollController,
                  ),
                  _LapTutorialPage(
                    onHit: () {
                      setState(() {
                        _hasHitDistracted = true;
                        _canProceed = true;
                      });
                      HapticFeedback.heavyImpact();
                    },
                  ),
                  _SensorCalibrationPage(),
                  _IntentPracticePage(
                    controller: _intentController,
                    onChanged: (v) {
                      setState(() {
                        _canProceed = v.length >= 10;
                      });
                    },
                  ),
                  const _BaselineTestPage(),
                  const _FounderOathPage(),
                ],
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: AnimatedOpacity(
                opacity: _canProceed ? 1.0 : 0.35,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _nextPage : null,
                    child: Text(_currentPage == 5
                        ? 'I Agree – Start Training'
                        : 'Continue'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1: The Manifesto ────────────────────────────────────────────────────

class _ManifestoPage extends StatelessWidget {
  final String typewriterText;
  final ScrollController scrollController;

  const _ManifestoPage({
    required this.typewriterText,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE POPCORN\nBRAIN CRISIS',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.teal,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: AppColors.teal),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Text(
                typewriterText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.8,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '↓ scroll to accept',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 2: Lap Tutorial ─────────────────────────────────────────────────────

class _LapTutorialPage extends StatefulWidget {
  final VoidCallback onHit;
  const _LapTutorialPage({required this.onHit});

  @override
  State<_LapTutorialPage> createState() => _LapTutorialPageState();
}

class _LapTutorialPageState extends State<_LapTutorialPage>
    with SingleTickerProviderStateMixin {
  bool _hit = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISTRACTIONS\nARE REPS',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.teal,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: AppColors.teal),
          const SizedBox(height: 20),
          Text(
            'In other apps, getting distracted means failure.\n\n'
            'In NeuroLoad, a distraction is a rep. You log it, '
            'classify it, and train your resilience. '
            'The goal isn\'t zero laps — it\'s shorter ones over time.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
          ),
          const Spacer(),
          if (!_hit)
            Text(
              'Tap the button below to see how it feels.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          if (_hit)
            Text(
              '✓ That\'s a rep. Now you\'re training.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.teal,
                  ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (!_hit) {
                setState(() => _hit = true);
                widget.onHit();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 88,
              decoration: BoxDecoration(
                color: _hit ? AppColors.tealDim : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hit ? AppColors.teal : AppColors.silverGrayDim,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _hit ? '✓ Logged' : 'DISTRACTED',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _hit ? AppColors.teal : AppColors.textSecondary,
                        letterSpacing: 2,
                        fontSize: 16,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Page 3: Sensor Calibration ───────────────────────────────────────────────

class _SensorCalibrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FACE-DOWN\nTRIGGER',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.teal,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: AppColors.teal),
          const SizedBox(height: 24),
          Text(
            'Place your phone face-down on your desk to start sessions '
            'without touching the screen. The gyroscope calibration happens '
            'automatically — nothing required from you.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
            ),
            child: Column(
              children: [
                Icon(Icons.phone_android,
                    size: 64, color: AppColors.silverGray),
                const SizedBox(height: 16),
                Text(
                  'Phone face-down = session starts',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'A double haptic pulse will confirm.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Page 4: Intent Practice ──────────────────────────────────────────────────

class _IntentPracticePage extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _IntentPracticePage({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR INTENT\nSTATEMENT',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.teal,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: AppColors.teal),
          const SizedBox(height: 24),
          Text(
            'Before each session, you write a single sentence. '
            'A micro-contract with yourself. '
            'If you get distracted, it\'s shown back to you.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLength: 100,
            maxLines: 3,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText:
                  'e.g., "I will finish the project outline without switching tabs."',
              counterStyle: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum 10 characters to continue.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ─── Page 5: Baseline Test ────────────────────────────────────────────────────

class _BaselineTestPage extends StatelessWidget {
  const _BaselineTestPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BASELINE\nSESSION',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.teal,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: AppColors.teal),
          const SizedBox(height: 24),
          Text(
            'Your first real session will establish your initial 1-Rep Max — '
            'the longest you can focus without distraction.\n\n'
            'Once you proceed to the app, start your first session and '
            'focus for as long as you naturally can. Don\'t force it.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.tealDim, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  '⏱',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your first session awaits.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.teal,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Page 6: Founder's Oath ───────────────────────────────────────────────────

class _FounderOathPage extends StatelessWidget {
  const _FounderOathPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE FOUNDER\'S\nOATH',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.teal,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: AppColors.teal),
          const SizedBox(height: 24),
          _PrivacyPoint(
            icon: Icons.lock_outline,
            title: 'Local-First, Always',
            body: 'Every session, every lap, every note is stored encrypted '
                'on your device. We never see it. Ever.',
          ),
          const SizedBox(height: 16),
          _PrivacyPoint(
            icon: Icons.cloud_off_outlined,
            title: 'Cloud is Optional',
            body: 'Multi-device sync is a paid, opt-in feature. '
                'The default is air-gapped privacy.',
          ),
          const SizedBox(height: 16),
          _PrivacyPoint(
            icon: Icons.delete_forever_outlined,
            title: 'Right to Erasure',
            body: 'A single button wipes everything — local and cloud — '
                'permanently and irrevocably.',
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PrivacyPoint(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.teal, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      )),
              const SizedBox(height: 4),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
