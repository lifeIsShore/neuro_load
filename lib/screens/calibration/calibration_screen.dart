// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';

// ── Public entry point ────────────────────────────────────────────────────────

/// Full-screen calibration flow — used as a standalone route (/calibration)
/// navigated to from Settings → "Recalibrate Sensor".
class CalibrationScreen extends StatelessWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.silverGray),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'RECALIBRATE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.teal,
                letterSpacing: 3,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CalibrationWidget(
          standalone: true,
          onCalibrated: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

// ── Shared calibration widget ─────────────────────────────────────────────────

/// Self-contained guided calibration widget.
/// Used both inside onboarding and in [CalibrationScreen].
///
/// [onCalibrated] is called when the user completes or skips calibration.
/// [standalone] = true removes the onboarding-style display header.
class CalibrationWidget extends StatefulWidget {
  final VoidCallback onCalibrated;
  final bool standalone;

  const CalibrationWidget({
    super.key,
    required this.onCalibrated,
    this.standalone = false,
  });

  @override
  State<CalibrationWidget> createState() => _CalibrationWidgetState();
}

// ── Internal enums ────────────────────────────────────────────────────────────

enum _CalPhase {
  instruction, // Phase 1 — show instruction card
  checkpoint,  // Phase 2/3 — live bubble-level + 3-checkpoint flow
  summary,     // Phase 4a — show results + "Test It Now" button
  testing,     // Phase 4b — live flip test
  done,        // Phase 4c — test passed / saved
}

class _Checkpoint {
  final String title;
  final String hint;
  final String completedHint;
  final bool Function(double x, double y, double z) isSatisfied;

  const _Checkpoint({
    required this.title,
    required this.hint,
    required this.completedHint,
    required this.isSatisfied,
  });
}

// ── State ─────────────────────────────────────────────────────────────────────

class _CalibrationWidgetState extends State<CalibrationWidget>
    with SingleTickerProviderStateMixin {
  _CalPhase _phase = _CalPhase.instruction;

  // Live sensor
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  double _ax = 0, _ay = 0, _az = 9.8;

  // Checkpoint state
  int _cpIndex = 0;
  final List<bool> _cpDone = [false, false, false];
  final List<double> _cpZ = [0.0, 0.0, 0.0]; // captured Z values per CP
  Timer? _holdTimer;
  Timer? _holdProgressTimer;
  bool _holding = false;
  double _holdProgress = 0.0; // 0.0 – 1.0 used for arc in bubble widget

  static const _holdDuration = Duration(milliseconds: 800);

  // Summary / test state
  double _savedBaseline = 0.0;
  Timer? _testTimer;
  bool _testPassed = false;
  bool _testTimedOut = false;

  late AnimationController _tickPulse;

  // The 3 checkpoints
  static final List<_Checkpoint> _checkpoints = [
    _Checkpoint(
      title: 'Screen facing you',
      hint: 'Hold phone flat, screen facing you',
      completedHint: 'Screen-up baseline locked ✓',
      isSatisfied: (x, y, z) => z > 7.0,   // Z ≈ +9.8 face-up
    ),
    _Checkpoint(
      title: 'Tilt 90° right',
      hint: 'Rotate so the right edge points down',
      completedHint: 'Lateral tilt locked ✓',
      isSatisfied: (x, y, z) => x < -7.0,  // gravity shifts to -X axis
    ),
    _Checkpoint(
      title: 'Screen face-down',
      hint: 'Flip phone completely face-down',
      completedHint: 'Face-down threshold locked ✓',
      isSatisfied: (x, y, z) => z < -7.0,  // Z ≈ -9.8 face-down
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tickPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    _holdTimer?.cancel();
    _holdProgressTimer?.cancel();
    _testTimer?.cancel();
    _tickPulse.dispose();
    super.dispose();
  }

  // ── Sensor ────────────────────────────────────────────────────────────────

  void _startSensor() {
    _sensorSub?.cancel();
    _sensorSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50), // ~20 Hz
    ).listen(_onEvent, onError: (_) => _skip());
  }

  void _stopSensor() {
    _sensorSub?.cancel();
    _sensorSub = null;
  }

  void _onEvent(AccelerometerEvent e) {
    if (!mounted) return;
    setState(() { _ax = e.x; _ay = e.y; _az = e.z; });
    if (_phase == _CalPhase.checkpoint) _evalCheckpoint(e.x, e.y, e.z);
    if (_phase == _CalPhase.testing)    _evalTest(e.z);
  }

  // ── Checkpoint evaluation ─────────────────────────────────────────────────

  void _evalCheckpoint(double x, double y, double z) {
    if (_cpIndex >= _checkpoints.length) return;
    if (_cpDone[_cpIndex]) return;

    final cp = _checkpoints[_cpIndex];
    final ok = cp.isSatisfied(x, y, z);

    if (ok && !_holding) {
      _holding = true;
      _holdProgress = 0;
      _holdProgressTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() {
          _holdProgress =
              (_holdProgress + 50 / _holdDuration.inMilliseconds).clamp(0.0, 1.0);
        });
      });
      _holdTimer = Timer(_holdDuration, () {
        if (!mounted) return;
        if (cp.isSatisfied(_ax, _ay, _az)) {
          _confirmCP(z);
        } else {
          _cancelHold();
        }
      });
    } else if (!ok && _holding) {
      _cancelHold();
    }
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdProgressTimer?.cancel();
    if (mounted) setState(() { _holding = false; _holdProgress = 0; });
  }

  void _confirmCP(double capturedZ) {
    _holdTimer?.cancel();
    _holdProgressTimer?.cancel();
    HapticFeedback.mediumImpact();

    setState(() {
      _holding = false;
      _holdProgress = 0;
      _cpDone[_cpIndex] = true;
      _cpZ[_cpIndex] = capturedZ;
    });
    _tickPulse.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_cpIndex < _checkpoints.length - 1) {
        setState(() => _cpIndex++);
      } else {
        _finishCheckpoints();
      }
    });
  }

  void _finishCheckpoints() {
    // face-down Z + small hysteresis margin → trigger threshold
    _savedBaseline = _cpZ[2] + 1.5;
    _stopSensor();
    setState(() => _phase = _CalPhase.summary);
  }

  // ── Test phase ────────────────────────────────────────────────────────────

  void _startTest() {
    setState(() {
      _phase = _CalPhase.testing;
      _testPassed = false;
      _testTimedOut = false;
    });
    _startSensor();
    _testTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted || _testPassed) return;
      _stopSensor();
      setState(() => _testTimedOut = true);
    });
  }

  void _evalTest(double z) {
    if (_testPassed) return;
    if (z <= _savedBaseline) {
      _testTimer?.cancel();
      _stopSensor();
      HapticFeedback.heavyImpact();
      setState(() => _testPassed = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _saveAndFinish();
      });
    }
  }

  Future<void> _saveAndFinish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sensor_z_baseline', _savedBaseline);
    _stopSensor();
    if (mounted) setState(() => _phase = _CalPhase.done);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) widget.onCalibrated();
    });
  }

  Future<void> _saveSkip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sensor_z_baseline', _savedBaseline);
    if (mounted) widget.onCalibrated();
  }

  void _skip() {
    _stopSensor();
    _holdTimer?.cancel();
    _holdProgressTimer?.cancel();
    _testTimer?.cancel();
    widget.onCalibrated();
  }

  void _redoCheckpoints() {
    _stopSensor();
    setState(() {
      _phase = _CalPhase.checkpoint;
      _cpIndex = 0;
      _cpDone.fillRange(0, 3, false);
      _holding = false;
      _holdProgress = 0;
    });
    _startSensor();
  }

  void _onReadyPressed() {
    setState(() {
      _phase = _CalPhase.checkpoint;
      _cpIndex = 0;
      _cpDone.fillRange(0, 3, false);
    });
    _startSensor();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildPhase(context),
      ),
    );
  }

  Widget _buildPhase(BuildContext context) {
    switch (_phase) {
      case _CalPhase.instruction: return _phaseInstruction(context);
      case _CalPhase.checkpoint:  return _phaseCheckpoints(context);
      case _CalPhase.summary:     return _phaseSummary(context);
      case _CalPhase.testing:     return _phaseTesting(context);
      case _CalPhase.done:        return _phaseDone(context);
    }
  }

  // ─────────────────────────────── Phase 1: Instruction ────────────────────

  Widget _phaseInstruction(BuildContext context) {
    return Column(
      key: const ValueKey('instr'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.standalone) ...[
          Text(
            'FACE-DOWN\nTRIGGER',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.teal, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Container(width: 40, height: 2, color: AppColors.teal),
          const SizedBox(height: 20),
        ],
        Text(
          "Let's calibrate your phone flip. We'll guide you through "
          "3 orientations to precisely measure how your device moves "
          "so the flip trigger works reliably.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.75),
        ),
        const Spacer(),
        const Center(child: _PhoneIcon(rotated: false)),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Hold your phone flat, screen facing you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _onReadyPressed,
            child: const Text("I'M READY"),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _skip,
            child: Text('Skip calibration',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.underline)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─────────────────────────────── Phase 2/3: Checkpoints ──────────────────

  Widget _phaseCheckpoints(BuildContext context) {
    final cp = _checkpoints[_cpIndex];
    final isDone = _cpDone[_cpIndex];

    return Column(
      key: const ValueKey('cp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _StepDots(total: 3, current: _cpIndex, done: _cpDone),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isDone ? cp.completedHint : cp.hint,
            key: ValueKey(isDone),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDone ? AppColors.teal : AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: _BubbleLevel(
            ax: _ax, ay: _ay, az: _az,
            isLocked: isDone,
            holdProgress: _holding ? _holdProgress : 0.0,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Z ${_az.toStringAsFixed(2)}  X ${_ax.toStringAsFixed(2)}  Y ${_ay.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontFeatures: [const FontFeature.tabularFigures()]),
          ),
        ),
        const Spacer(),
        _CpList(checkpoints: _checkpoints, done: _cpDone, current: _cpIndex),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: _skip,
            child: Text('Skip calibration',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.underline)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─────────────────────────────── Phase 4a: Summary ───────────────────────

  Widget _phaseSummary(BuildContext context) {
    return Column(
      key: const ValueKey('sum'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('CALIBRATION COMPLETE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.teal, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('Here are your measured orientations:',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        _ResultRow(label: 'Screen-up baseline', value: '${_cpZ[0].toStringAsFixed(2)} m/s²'),
        const SizedBox(height: 10),
        _ResultRow(label: 'Lateral 90° tilt',  value: '${_cpZ[1].toStringAsFixed(2)} m/s²'),
        const SizedBox(height: 10),
        _ResultRow(label: 'Face-down threshold', value: '${_cpZ[2].toStringAsFixed(2)} m/s²', highlight: true),
        const SizedBox(height: 8),
        Text(
          'Trigger saved at ${_savedBaseline.toStringAsFixed(2)} m/s²  (face-down + 1.5 buffer)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startTest,
            child: const Text('TEST IT NOW  →'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _saveSkip,
            child: Text('Skip test & save',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.underline)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─────────────────────────────── Phase 4b: Testing ───────────────────────

  Widget _phaseTesting(BuildContext context) {
    return Column(
      key: const ValueKey('test'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text('LIVE FLIP TEST',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.teal, letterSpacing: 2)),
        const Spacer(),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _testPassed
                ? AppColors.teal.withValues(alpha: 0.12)
                : _testTimedOut
                    ? AppColors.dangerDim.withValues(alpha: 0.15)
                    : AppColors.surfaceElevated,
            border: Border.all(
              color: _testPassed
                  ? AppColors.teal
                  : _testTimedOut
                      ? AppColors.danger
                      : AppColors.silverGrayDim,
              width: _testPassed ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _testPassed ? '✓' : _testTimedOut ? '✗' : '📱',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                _testPassed
                    ? 'Flip detected!'
                    : _testTimedOut
                        ? 'Not detected'
                        : 'Flip face-down',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _testPassed
                          ? AppColors.teal
                          : _testTimedOut
                              ? AppColors.danger
                              : AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!_testPassed && !_testTimedOut)
          Text('Flip your phone face-down within 8 seconds.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        if (_testTimedOut) ...[
          Text(
            'The flip was not detected. Try recalibrating.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.textPrimary,
              ),
              onPressed: _redoCheckpoints,
              child: const Text('RECALIBRATE'),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _saveSkip,
            child: Text('Save anyway & continue',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.underline)),
          ),
        ],
        const Spacer(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─────────────────────────────── Phase done ───────────────────────────────

  Widget _phaseDone(BuildContext context) {
    return Column(
      key: const ValueKey('done'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.tealDim,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.teal, width: 1.5),
          ),
          child: const Icon(Icons.check_rounded, size: 72, color: AppColors.teal),
        ),
        const SizedBox(height: 24),
        Text('All done!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.teal)),
        const SizedBox(height: 8),
        Text(
          'Flip trigger saved at ${_savedBaseline.toStringAsFixed(2)} m/s²',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
      ],
    );
  }
}

// ── Bubble Level ──────────────────────────────────────────────────────────────

/// Circular spirit-level gauge. Bubble position driven by accelerometer.
class _BubbleLevel extends StatelessWidget {
  final double ax, ay, az;
  final bool isLocked;
  final double holdProgress; // 0–1

  const _BubbleLevel({
    required this.ax, required this.ay, required this.az,
    required this.isLocked, required this.holdProgress,
  });

  @override
  Widget build(BuildContext context) {
    const r = 72.0;  // gauge radius
    const br = 18.0; // bubble radius
    const maxD = r - br - 4;

    final nx = (ax / 9.8).clamp(-1.0, 1.0);
    final ny = (-ay / 9.8).clamp(-1.0, 1.0);
    final dx = nx * maxD;
    final dy = ny * maxD;

    return SizedBox(
      width: r * 2 + 20,
      height: r * 2 + 20,
      child: CustomPaint(
        painter: _BubblePainter(
          dx: dx, dy: dy,
          isLocked: isLocked,
          holdProgress: holdProgress,
          gaugeR: r, bubbleR: br,
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final double dx, dy, holdProgress, gaugeR, bubbleR;
  final bool isLocked;

  const _BubblePainter({
    required this.dx, required this.dy, required this.holdProgress,
    required this.isLocked, required this.gaugeR, required this.bubbleR,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // Gauge ring
    canvas.drawCircle(c, gaugeR,
        Paint()
          ..color = (isLocked ? AppColors.teal : AppColors.silverGrayDim)
              .withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Hold progress arc
    if (holdProgress > 0 && !isLocked) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: gaugeR),
        -pi / 2, 2 * pi * holdProgress, false,
        Paint()
          ..color = AppColors.teal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Cross-hairs
    final xp = Paint()
      ..color = AppColors.silverGrayDim.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(c.dx - gaugeR, c.dy), Offset(c.dx + gaugeR, c.dy), xp);
    canvas.drawLine(Offset(c.dx, c.dy - gaugeR), Offset(c.dx, c.dy + gaugeR), xp);

    // Target zone
    canvas.drawCircle(c, bubbleR + 6,
        Paint()
          ..color = (isLocked ? AppColors.teal : AppColors.silverGrayDim)
              .withValues(alpha: 0.12));

    // Bubble fill
    final bc = c + Offset(dx, dy);
    canvas.drawCircle(bc, bubbleR,
        Paint()
          ..color = isLocked
              ? AppColors.teal.withValues(alpha: 0.85)
              : AppColors.silverGray.withValues(alpha: 0.55));

    // Bubble highlight
    canvas.drawCircle(
        bc + Offset(-bubbleR * 0.25, -bubbleR * 0.25), bubbleR * 0.3,
        Paint()
          ..color = Colors.white.withValues(alpha: isLocked ? 0.45 : 0.28));

    // Tick when locked
    if (isLocked) {
      final tp = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
          Offset(bc.dx - 5, bc.dy), Offset(bc.dx - 1, bc.dy + 5), tp);
      canvas.drawLine(
          Offset(bc.dx - 1, bc.dy + 5), Offset(bc.dx + 7, bc.dy - 5), tp);
    }
  }

  @override
  bool shouldRepaint(_BubblePainter o) =>
      o.dx != dx || o.dy != dy || o.isLocked != isLocked ||
      o.holdProgress != holdProgress;
}

// ── Step Dots ─────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  final int total, current;
  final List<bool> done;
  const _StepDots({required this.total, required this.current, required this.done});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final d = done[i];
        final cur = i == current && !d;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              decoration: BoxDecoration(
                color: d
                    ? AppColors.teal
                    : cur
                        ? AppColors.teal.withValues(alpha: 0.4)
                        : AppColors.silverGrayDim,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Checkpoint List ───────────────────────────────────────────────────────────

class _CpList extends StatelessWidget {
  final List<_Checkpoint> checkpoints;
  final List<bool> done;
  final int current;
  const _CpList({required this.checkpoints, required this.done, required this.current});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(checkpoints.length, (i) {
        final d = done[i];
        final cur = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: d
                ? AppColors.teal.withValues(alpha: 0.08)
                : cur
                    ? AppColors.surfaceElevated
                    : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: d
                  ? AppColors.teal.withValues(alpha: 0.4)
                  : cur
                      ? AppColors.silverGrayDim
                      : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                d
                    ? Icons.check_circle_rounded
                    : cur
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                size: 18,
                color: d
                    ? AppColors.teal
                    : cur
                        ? AppColors.silverGray
                        : AppColors.silverGrayDim,
              ),
              const SizedBox(width: 10),
              Text(checkpoints[i].title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: d
                            ? AppColors.teal
                            : cur
                                ? AppColors.textPrimary
                                : AppColors.textTertiary)),
            ],
          ),
        );
      }),
    );
  }
}

// ── Result Row ────────────────────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _ResultRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.teal.withValues(alpha: 0.08)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? AppColors.teal.withValues(alpha: 0.4)
              : AppColors.silverGrayDim,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: highlight ? AppColors.teal : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [const FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}

// ── Phone Icon ────────────────────────────────────────────────────────────────

class _PhoneIcon extends StatelessWidget {
  final bool rotated;
  const _PhoneIcon({required this.rotated});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.5), width: 1.5),
      ),
      child: const Icon(Icons.screen_lock_portrait, size: 28, color: AppColors.teal),
    );
  }
}
