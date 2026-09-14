import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/vector_colors.dart';

class VectorSplash extends StatefulWidget {
  const VectorSplash({
    required this.onComplete,
    this.speedFactor = 1.0,
    super.key,
  });

  final VoidCallback onComplete;
  final double speedFactor;

  @override
  State<VectorSplash> createState() => _VectorSplashState();
}

class _VectorSplashState extends State<VectorSplash>
  with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _exitController;
  bool _completed = false;
  bool _animationFinished = false;
  bool _isExiting = false;

  static const _totalDuration = 3000;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (_totalDuration * widget.speedFactor).round(),
      ),
    )..addStatusListener(_handleStatus);
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _animationFinished = true;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        !MediaQuery.disableAnimationsOf(context)) {
      setState(() => _animationFinished = true);
    }
  }

  Future<void> _complete() async {
    if (_completed || _isExiting || !mounted) return;
    _completed = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      widget.onComplete();
      return;
    }
    setState(() => _isExiting = true);
    await _exitController.forward();
    if (mounted) widget.onComplete();
  }

  double _value(double start, double end, Curve curve) {
    final progress =
        ((_controller.value - start / _totalDuration) /
                ((end - start) / _totalDuration))
            .clamp(0.0, 1.0);
    return curve.transform(progress);
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          final double t = const Cubic(
            0.22,
            1,
            0.36,
            1,
          ).transform(_exitController.value);
          return FractionalTranslation(
            translation: Offset(0, -t),
            child: Opacity(opacity: 1 - t, child: child),
          );
        },
        child: ColoredBox(
          color: VectorColors.purpleBrand,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final markWidth = constraints.maxWidth * 0.164;
              final markHeight = markWidth * (58 / 64);
              final fontSize = markWidth * 1.0625;
              final wordmarkStyle = TextStyle(
                color: VectorColors.textOnPurple,
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: fontSize * -0.02,
              );
              final textPainter = TextPainter(
                text: TextSpan(text: 'ector', style: wordmarkStyle),
                textDirection: TextDirection.ltr,
              )..layout();
              final metrics = textPainter.computeLineMetrics().first;
              final baseline = markWidth * (50 / 64);
              final textTop = baseline - metrics.ascent;
              final textHeight = metrics.height;
              final minY = 0.0 < textTop ? 0.0 : textTop;
              final maxY = markHeight > textTop + textHeight
                  ? markHeight
                  : textTop + textHeight;
              final groupHeight = maxY - minY;
              final overlap = markWidth * 0.156;
              final totalSpan = markWidth + textPainter.width - overlap;
              final initialOffset = (totalSpan / 2) - (markWidth / 2);

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final leftProgress = _value(
                    0,
                    550,
                    const Cubic(0.65, 0, 0.35, 1),
                  );
                  final rightProgress = _value(
                    220,
                    770,
                    const Cubic(0.65, 0, 0.35, 1),
                  );
                  final dotScale = _value(
                    720,
                    1220,
                    const Cubic(0.34, 1.56, 0.64, 1),
                  );
                  final slide = _value(
                    1350,
                    2200,
                    const Cubic(0.76, 0, 0.24, 1),
                  );
                  final wipe = _value(
                    1850,
                    2750,
                    const Cubic(0.22, 1, 0.36, 1),
                  );
                  final wipeOpacity = (wipe / 0.12).clamp(0.0, 1.0);
                  final typedProgress =
                      ((_controller.value - 1850 / _totalDuration) /
                              ((2450 - 1850) / _totalDuration))
                          .clamp(0.0, 1.0);
                  final typedTextPainter = TextPainter(
                    text: TextSpan(
                      children: [
                        for (var index = 0; index < 'ector'.length; index++)
                          TextSpan(
                            text: 'ector'[index],
                            style: wordmarkStyle.copyWith(
                              color: wordmarkStyle.color!.withValues(
                                alpha: Curves.easeOut.transform(
                                  ((typedProgress - index / 'ector'.length) *
                                          'ector'.length /
                                          0.35)
                                      .clamp(0.0, 1.0),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    textDirection: TextDirection.ltr,
                  )..layout();
                  final glowProgress = _value(0, 1400, Curves.easeOut);
                  final glowDiameter = constraints.maxWidth * 1.33;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: glowProgress,
                        child: Transform.scale(
                          scale: 0.7 + (0.3 * glowProgress),
                          child: Container(
                            width: glowDiameter,
                            height: glowDiameter,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  VectorColors.apricot.withValues(alpha: 0.2),
                                  VectorColors.apricot.withValues(alpha: 0),
                                  VectorColors.apricot.withValues(alpha: 0),
                                ],
                                stops: const [0, 0.65, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(initialOffset * (1 - slide), 0),
                        child: SizedBox(
                          width: totalSpan,
                          height: groupHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                top: -minY,
                                width: markWidth,
                                height: markHeight,
                                child: CustomPaint(
                                  painter: _VectorMarkPainter(
                                    leftProgress: leftProgress,
                                    rightProgress: rightProgress,
                                    dotScale: dotScale,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: markWidth - overlap,
                                top: textTop - minY,
                                width: textPainter.width,
                                height: textHeight,
                                child: Opacity(
                                  opacity: wipeOpacity,
                                  child: ClipRect(
                                    child: CustomPaint(
                                      size: Size(textPainter.width, textHeight),
                                      painter: _WordmarkPainter(
                                        typedTextPainter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 64,
                        child: IgnorePointer(
                          ignoring: !_animationFinished || _isExiting,
                          child: AnimatedOpacity(
                            opacity: _animationFinished ? 1 : 0,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOut,
                            child: FilledButton.icon(
                              onPressed: _complete,
                              icon: const Icon(
                                Icons.arrow_drop_up,
                                color: Color(0xFFF2B880),
                                size: 24,
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF493252),
                                foregroundColor: const Color(0xFFF7F4F8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                              ),
                              label: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VectorMarkPainter extends CustomPainter {
  const _VectorMarkPainter({
    required this.leftProgress,
    required this.rightProgress,
    required this.dotScale,
  });

  final double leftProgress;
  final double rightProgress;
  final double dotScale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 58);

    final leftPath = Path()
      ..moveTo(6, 6)
      ..lineTo(32, 50);
    final rightPath = Path()
      ..moveTo(58, 6)
      ..lineTo(32, 50);
    _drawProgressivePath(
      canvas,
      leftPath,
      leftProgress,
      const Color(0xFFF7F4F8),
    );
    _drawProgressivePath(
      canvas,
      rightPath,
      rightProgress,
      const Color(0xFFF2B880),
    );

    final dotPaint = Paint()
      ..color = const Color(0xFFF7F4F8)
          .withValues(alpha: dotScale.clamp(0.0, 1.0));
    canvas.drawCircle(const Offset(32, 50), 4 * dotScale, dotPaint);
    canvas.restore();
  }

  void _drawProgressivePath(
    Canvas canvas,
    Path path,
    double progress,
    Color color,
  ) {
    final metric = path.computeMetrics().first;
    final revealed = metric.extractPath(
      0,
      metric.length * progress.clamp(0.0, 1.0),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(revealed, paint);
  }

  @override
  bool shouldRepaint(covariant _VectorMarkPainter oldDelegate) {
    return leftProgress != oldDelegate.leftProgress ||
        rightProgress != oldDelegate.rightProgress ||
        dotScale != oldDelegate.dotScale;
  }
}

class _WordmarkPainter extends CustomPainter {
  const _WordmarkPainter(this.textPainter);

  final TextPainter textPainter;

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant _WordmarkPainter oldDelegate) => true;
}
