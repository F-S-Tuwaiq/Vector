import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/vector_colors.dart';
import '../widgets/brand_loader/v_logo_animation.dart';

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
  late final AnimationController _bobController;
  bool _completed = false;
  bool _animationFinished = false;
  bool _isExiting = false;
  bool _buttonPressed = false;

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
      duration: const Duration(milliseconds: 1100),
    );
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _animationFinished = true;
      _bobController.stop();
    } else {
      if (!_controller.isAnimating && _controller.value == 0) {
        _controller.forward();
      }
      if (!_bobController.isAnimating) {
        _bobController.repeat(reverse: true);
      }
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
    _bobController.dispose();
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
          final double t = Curves.easeInOutCubic.transform(
            _exitController.value,
          );

          final double fade = const Interval(
            0.35,
            1,
            curve: Curves.easeInOut,
          ).transform(_exitController.value);
          final double notch =
              0.14 *
              const Interval(
                0,
                0.6,
                curve: Curves.easeInOutCubic,
              ).transform(_exitController.value);
          return FractionalTranslation(
            translation: Offset(0, -(1 + notch) * t),
            child: Opacity(
              opacity: 1 - fade,
              child: ClipPath(
                clipper: _TriangleExitClipper(notchFactor: notch),
                child: child,
              ),
            ),
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
                                child: OverflowBox(
                                  maxWidth: markWidth * 500 / 275,
                                  maxHeight: markWidth * 500 / 275,
                                  child: CustomPaint(
                                    size: Size.square(markWidth * 500 / 275),
                                    painter: VLogoAnimation.painterAt(
                                      (_controller.value *
                                              _totalDuration /
                                              2000)
                                          .clamp(0.0, 1.0),
                                    ),
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
                          child: AnimatedSlide(
                            offset: _animationFinished
                                ? Offset.zero
                                : const Offset(0, 0.35),
                            duration: const Duration(milliseconds: 500),
                            curve: const Cubic(0.22, 1, 0.36, 1),
                            child: AnimatedOpacity(
                              opacity: _animationFinished ? 1 : 0,
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeOut,
                              child: _ContinueButton(
                                pressed: _buttonPressed,
                                bob: _bobController,
                                onPressChanged: (v) =>
                                    setState(() => _buttonPressed = v),
                                onTap: _complete,
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

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.pressed,
    required this.bob,
    required this.onPressChanged,
    required this.onTap,
  });

  final bool pressed;
  final AnimationController bob;
  final ValueChanged<bool> onPressChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onPressChanged(true),
        onTapCancel: () => onPressChanged(false),
        onTapUp: (_) {
          onPressChanged(false);
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: pressed ? 0.94 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: const Cubic(0.22, 1, 0.36, 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: pressed
                        ? VectorColors.apricot.withValues(alpha: 0.15)
                        : Colors.transparent,
                    border: Border.all(
                      color: VectorColors.textOnPurple.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: bob,
                      builder: (context, child) {
                        final dy = -3.0 * Curves.easeInOut.transform(bob.value);
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        );
                      },
                      child: const CustomPaint(
                        size: Size(14, 12),
                        painter: _TriangleGlyphPainter(
                          color: VectorColors.apricot,
                        ),
                      ),
                    ),
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

class _TriangleGlyphPainter extends CustomPainter {
  const _TriangleGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TriangleGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _TriangleExitClipper extends CustomClipper<Path> {
  const _TriangleExitClipper({required this.notchFactor});

  final double notchFactor;

  @override
  Path getClip(Size size) {
    final d = size.height * notchFactor;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - d)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height - d)
      ..close();
  }

  @override
  bool shouldReclip(covariant _TriangleExitClipper oldDelegate) =>
      oldDelegate.notchFactor != notchFactor;
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

class AppLauncher extends StatefulWidget {
  const AppLauncher({required this.next, super.key});

  final Widget next;

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  bool _splashDone = false;

  void _onSplashComplete() {
    if (!mounted) return;
    setState(() => _splashDone = true);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.next,
        if (!_splashDone) VectorSplash(onComplete: _onSplashComplete),
      ],
    );
  }
}
