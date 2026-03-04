import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:drift/drift.dart' show Value;

import '../../data/app_database.dart';
import '../../data/daos/session_dao.dart';
import '../../data/tables.dart';
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

  // Page 5 – Baseline Test
  bool _baselineCompleted = false;

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
        return _baselineCompleted;
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
                  _SensorCalibrationPage(
                    onCalibrated: () => setState(() => _canProceed = true),
                  ),
                  _IntentPracticePage(
                    controller: _intentController,
                    onChanged: (v) {
                      setState(() {
                        _canProceed = v.length >= 10;
                      });
                    },
                  ),
                  _BaselineTestPage(
                    onCompleted: () => setState(() {
                      _baselineCompleted = true;
                      _canProceed = true;
                    }),
                  ),
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

enum _CalibrationPhase { idle, sampling, done }

class _SensorCalibrationPage extends StatefulWidget {
  final VoidCallback onCalibrated;
  const _SensorCalibrationPage({required this.onCalibrated});

  @override
  State<_SensorCalibrationPage> createState() => _SensorCalibrationPageState();
}

class _SensorCalibrationPageState extends State<_SensorCalibrationPage>
    with SingleTickerProviderStateMixin {
  _CalibrationPhase _phase = _CalibrationPhase.idle;

  // Live sensor state
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  double _currentZ = 0.0;

  // Sample collection
  static const int _targetSamples = 3;
  final List<double> _samples = [];

  // Animation for the progress arc
  late final AnimationController _arcController;
  late final Animation<double> _arcAnim;

  // Per-sample countdown timer
  Timer? _sampleTimer;

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _targetSamples),
    );
    _arcAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_arcController);
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    _sampleTimer?.cancel();
    _arcController.dispose();
    super.dispose();
  }

  void _startCalibration() {
    setState(() {
      _phase = _CalibrationPhase.sampling;
      _samples.clear();
    });
    _arcController.forward(from: 0.0);

    // Subscribe to accelerometer
    _sensorSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen((e) {
      if (mounted) setState(() => _currentZ = e.z);
    }, onError: (_) => _onSensorError());

    // Collect 1 sample per second
    _sampleTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _samples.add(_currentZ);
      if (_samples.length >= _targetSamples) {
        t.cancel();
        _sensorSub?.cancel();
        _finishCalibration();
      }
    });
  }

  Future<void> _finishCalibration() async {
    final avg = _samples.reduce((a, b) => a + b) / _samples.length;

    // Persist the averaged baseline
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sensor_z_baseline', avg);

    HapticFeedback.mediumImpact();
    if (mounted) {
      setState(() => _phase = _CalibrationPhase.done);
      widget.onCalibrated();
    }
  }

  void _onSensorError() {
    _sampleTimer?.cancel();
    if (mounted && _phase == _CalibrationPhase.sampling) {
      _arcController.stop();
      _skip(); // Graceful degradation on sensor failure
    }
  }

  void _skip() {
    widget.onCalibrated(); // Unlock Continue without saving any baseline
  }

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
          const SizedBox(height: 20),
          Text(
            'Place your phone face-down on your desk to start sessions '
            'without touching the screen. We\'ll take a 3-second reading '
            'to calibrate the trigger threshold to your exact surface.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
          ),
          const Spacer(),

          // ── Central visual ────────────────────────────────────────────────
          Center(child: _buildVisual(context)),
          const SizedBox(height: 32),

          // ── Calibrate button ──────────────────────────────────────────────
          if (_phase != _CalibrationPhase.done)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _phase == _CalibrationPhase.idle
                    ? _startCalibration
                    : null, // disabled while sampling
                child: Text(
                  _phase == _CalibrationPhase.sampling
                      ? 'Calibrating…'
                      : 'Calibrate',
                ),
              ),
            ),

          // ── Skip link ─────────────────────────────────────────────────────
          if (_phase == _CalibrationPhase.idle) ...[
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _skip,
                child: Text(
                  'Skip calibration',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVisual(BuildContext context) {
    switch (_phase) {
      case _CalibrationPhase.idle:
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
          ),
          child: const Icon(Icons.phone_android,
              size: 72, color: AppColors.silverGray),
        );

      case _CalibrationPhase.sampling:
        return AnimatedBuilder(
          animation: _arcAnim,
          builder: (_, __) => SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress arc
                CustomPaint(
                  size: const Size(160, 160),
                  painter: _ArcPainter(progress: _arcAnim.value),
                ),
                // Live Z readout
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentZ.toStringAsFixed(2),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: AppColors.teal, fontFeatures: [
                        const FontFeature.tabularFigures()
                      ]),
                    ),
                    Text(
                      'm/s²  Z',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sample ${_samples.length + 1}/$_targetSamples',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      case _CalibrationPhase.done:
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.tealDim,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.teal, width: 1),
          ),
          child:
              const Icon(Icons.check_rounded, size: 72, color: AppColors.teal),
        );
    }
  }
}

/// Custom painter that draws a sweeping teal arc from the top
class _ArcPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  const _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.silverGrayDim.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Sweep arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start at 12 o'clock
      2 * pi * progress, // sweep clockwise
      false,
      Paint()
        ..color = AppColors.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
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

enum _BaselinePhase { idle, running, done }

class _BaselineTestPage extends StatefulWidget {
  final VoidCallback onCompleted;

  const _BaselineTestPage({required this.onCompleted});

  @override
  State<_BaselineTestPage> createState() => _BaselineTestPageState();
}

class _BaselineTestPageState extends State<_BaselineTestPage>
    with SingleTickerProviderStateMixin {
  static const _totalSeconds = 300; // 5 minutes

  _BaselinePhase _phase = _BaselinePhase.idle;
  int _remaining = _totalSeconds;
  int _lapCount = 0;
  int _sessionId = -1;
  late int _startedAtMs;

  Timer? _ticker;

  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ringController.dispose();
    super.dispose();
  }

  // ── Timer control ──────────────────────────────────────────────────────────

  Future<void> _begin() async {
    _startedAtMs = DateTime.now().millisecondsSinceEpoch;

    // Create the session row in Drift immediately
    final dao = AppDatabase.instance.sessionDao;
    _sessionId = await dao.insertSession(
      SessionsCompanion.insert(
        startedAt: _startedAtMs,
        category: 'baseline',
        subCategory: const Value(''),
        intent: const Value('Baseline measurement session'),
        baselineAimSeconds: const Value(_totalSeconds),
      ),
    );

    setState(() => _phase = _BaselinePhase.running);
    _ringController.forward(from: 0);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) _finish();
    });
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    _ringController.stop();

    final elapsed = _totalSeconds - _remaining.clamp(0, _totalSeconds);
    final quality = (100.0 - _lapCount * 10.0).clamp(0.0, 100.0);
    final focusDensity = (_lapCount == 0
        ? 1.0
        : (elapsed - _lapCount * 30.0).clamp(0.0, elapsed.toDouble()) /
            elapsed);
    // 1RM = time until first distraction, or full elapsed if no laps
    final oneRm = _lapCount == 0 ? elapsed : (elapsed ~/ (_lapCount + 1));

    if (_sessionId != -1) {
      await AppDatabase.instance.sessionDao.finishSession(
        id: _sessionId,
        endedAtMs: DateTime.now().millisecondsSinceEpoch,
        qualityScore: quality,
        focusDensity: focusDensity.clamp(0.0, 1.0),
        oneRmSeconds: oneRm.clamp(0, elapsed),
        totalElapsedSeconds: elapsed,
        lapCount: _lapCount,
      );
    }

    HapticFeedback.mediumImpact();
    if (mounted) {
      setState(() => _phase = _BaselinePhase.done);
      widget.onCompleted();
    }
  }

  void _logDistraction() {
    HapticFeedback.heavyImpact();
    setState(() => _lapCount++);
  }

  void _skip() => widget.onCompleted(); // No DB write

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
          const SizedBox(height: 16),

          // Context text — only in idle
          if (_phase == _BaselinePhase.idle)
            Text(
              'Your first real session establishes your initial 1-Rep Max — '
              'the longest you can focus without distraction.\n\n'
              'Run 5 minutes of focused work right now. '
              'Tap "I Got Distracted" every time you lose focus. '
              'Don\'t force it — just be honest.',
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
            ),

          const Spacer(),

          // ── Central visual ────────────────────────────────────────────────
          Center(child: _buildCentral(context)),
          const SizedBox(height: 32),

          // ── Primary action ────────────────────────────────────────────────
          if (_phase == _BaselinePhase.idle)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _begin,
                child: const Text('BEGIN BASELINE'),
              ),
            ),

          if (_phase == _BaselinePhase.running)
            SizedBox(
              width: double.infinity,
              height: 72,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceElevated,
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.silverGrayDim),
                ),
                onPressed: _logDistraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I GOT DISTRACTED',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 2,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      '$_lapCount ${_lapCount == 1 ? 'lap' : 'laps'} logged',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

          // ── Skip link ─────────────────────────────────────────────────────
          if (_phase != _BaselinePhase.done) ...[
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _skip,
                child: Text(
                  'Skip baseline',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCentral(BuildContext context) {
    switch (_phase) {
      // ── Idle ──────────────────────────────────────────────────────────────
      case _BaselinePhase.idle:
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.tealDim, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⏱', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              Text(
                '5:00',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.teal,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );

      // ── Running ───────────────────────────────────────────────────────────
      case _BaselinePhase.running:
        final progress = 1.0 - (_remaining / _totalSeconds).clamp(0.0, 1.0);
        return SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox.expand(
                child: AnimatedBuilder(
                  animation: _ringController,
                  builder: (_, __) => CustomPaint(
                    painter: _ArcPainter(progress: progress),
                  ),
                ),
              ),
              // Countdown text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _fmt(_remaining),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.teal,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );

      // ── Done ───────────────────────────────────────────────────────────────
      case _BaselinePhase.done:
        final elapsed = _totalSeconds - _remaining.clamp(0, _totalSeconds);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.tealDim,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.teal, width: 1),
              ),
              child: const Icon(Icons.check_rounded,
                  size: 72, color: AppColors.teal),
            ),
            const SizedBox(height: 20),
            Text(
              'Baseline recorded',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.teal),
            ),
            const SizedBox(height: 8),
            Text(
              '${_fmt(elapsed)} focused · $_lapCount ${_lapCount == 1 ? 'distraction' : 'distractions'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
    }
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
