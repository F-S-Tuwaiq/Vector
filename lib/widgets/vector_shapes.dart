import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class VectorBackground extends CustomPainter {
  VectorBackground({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 390;
    final scaleY = size.height / 680;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    const bounds = Rect.fromLTWH(0, 0, 390, 680);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            AppColors.backgroundBright,
            AppColors.backgroundSoft,
            AppColors.backgroundWhite,
          ],
        ).createShader(bounds),
    );

    _paintFloatingTriangles(canvas);

    final ribbon = Path()
      ..moveTo(245, 145)
      ..lineTo(390, 177)
      ..lineTo(390, 292)
      ..lineTo(215, 250)
      ..quadraticBezierTo(191, 245, 200, 227)
      ..lineTo(238, 158)
      ..quadraticBezierTo(242, 150, 245, 145)
      ..close();
    canvas.drawPath(
      ribbon,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            AppColors.surfaceWhite,
            AppColors.lavender,
            AppColors.backgroundWhite,
          ],
        ).createShader(const Rect.fromLTWH(190, 145, 200, 155)),
    );

    final header = Path()
      ..moveTo(0, 0)
      ..lineTo(259, 0)
      ..lineTo(260, 155)
      ..cubicTo(262, 188, 253, 214, 226, 225)
      ..cubicTo(214, 230, 205, 229, 187, 230)
      ..lineTo(0, 234)
      ..close();
    canvas.drawPath(
      header,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            AppColors.purpleMid,
            AppColors.purple,
            AppColors.purpleLight,
          ],
        ).createShader(const Rect.fromLTWH(0, 0, 260, 234)),
    );

    canvas.save();
    canvas.clipPath(header);
    final phase = animation.value * math.pi * 2;
    final ghost = Path()
      ..moveTo(260, 36)
      ..lineTo(111, 124)
      ..quadraticBezierTo(100, 131, 110, 139)
      ..lineTo(253, 228)
      ..close();
    canvas.drawPath(
      ghost.shift(Offset(math.sin(phase) * 2, math.cos(phase) * 2.5)),
      Paint()..color = AppColors.lavenderMid.withValues(alpha: 0.11),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 179)
        ..lineTo(89, 108)
        ..lineTo(27, 233)
        ..lineTo(0, 234)
        ..close(),
      Paint()..color = AppColors.lavenderDeep.withValues(alpha: 0.12),
    );
    canvas.restore();

    canvas.drawPath(
      Path()
        ..moveTo(260, 151)
        ..cubicTo(262, 188, 253, 214, 226, 225)
        ..quadraticBezierTo(219, 228, 210, 229),
      Paint()
        ..color = AppColors.apricot
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85,
    );
    canvas.restore();
  }

  void _paintFloatingTriangles(Canvas canvas) {
    final phase = animation.value * math.pi * 2;
    _triangle(
      canvas,
      const Offset(319, 47),
      26,
      0,
      AppColors.lavenderTriangle.withValues(alpha: 0.22),
      phase,
    );
    _triangle(
      canvas,
      const Offset(339, 103),
      12,
      math.pi,
      AppColors.apricot.withValues(alpha: 0.24),
      phase + 1.8,
    );
    _triangle(
      canvas,
      const Offset(349, 592),
      21,
      0,
      AppColors.lavenderTriangle.withValues(alpha: 0.24),
      phase + 3.4,
    );
  }

  void _triangle(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    Color color,
    double phase,
  ) {
    canvas.save();
    canvas.translate(
      center.dx + math.sin(phase) * 2.2,
      center.dy + math.cos(phase) * 3.1,
    );
    canvas.rotate(rotation);
    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(-radius * 0.55, -radius * 0.86)
      ..lineTo(-radius * 0.55, radius * 0.86)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VectorBackground oldDelegate) =>
      oldDelegate.animation != animation;
}

class VectorSignUpHeaderPainter extends CustomPainter {
  VectorSignUpHeaderPainter({required this.animation})
    : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 390;

    canvas.save();
    canvas.scale(scale);

    final phase = animation.value * math.pi * 2;

    final ribbon = Path()
      ..moveTo(241, 91)
      ..lineTo(390, 121)
      ..lineTo(390, 181)
      ..lineTo(223, 158)
      ..quadraticBezierTo(199, 155, 205, 139)
      ..lineTo(235, 99)
      ..quadraticBezierTo(239, 93, 241, 91)
      ..close();

    canvas.drawPath(
      ribbon,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            AppColors.surfaceWhite,
            AppColors.lavender,
            AppColors.backgroundWhite,
          ],
        ).createShader(const Rect.fromLTWH(190, 85, 200, 105)),
    );

    final header = Path()
      ..moveTo(0, 0)
      ..lineTo(259, 0)
      ..lineTo(260, 100)
      ..cubicTo(261, 126, 250, 149, 226, 159)
      ..cubicTo(214, 164, 204, 163, 186, 164)
      ..lineTo(0, 168)
      ..close();

    canvas.drawPath(
      header,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            AppColors.purpleMid,
            AppColors.purple,
            AppColors.purpleLight,
          ],
        ).createShader(const Rect.fromLTWH(0, 0, 260, 168)),
    );

    canvas.save();
    canvas.clipPath(header);

    final ghost = Path()
      ..moveTo(260, 22)
      ..lineTo(111, 91)
      ..quadraticBezierTo(101, 98, 111, 105)
      ..lineTo(251, 163)
      ..close();

    canvas.drawPath(
      ghost.shift(Offset(math.sin(phase) * 1.8, math.cos(phase) * 2.1)),
      Paint()..color = AppColors.lavenderMid.withValues(alpha: 0.11),
    );

    canvas.drawPath(
      Path()
        ..moveTo(0, 128)
        ..lineTo(83, 74)
        ..lineTo(27, 167)
        ..lineTo(0, 168)
        ..close(),
      Paint()..color = AppColors.lavenderDeep.withValues(alpha: 0.12),
    );

    canvas.restore();

    canvas.drawPath(
      Path()
        ..moveTo(260, 98)
        ..cubicTo(261, 126, 250, 149, 226, 159)
        ..quadraticBezierTo(219, 162, 209, 163),
      Paint()
        ..color = AppColors.apricot
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85,
    );

    canvas.drawLine(
      const Offset(239, 145),
      const Offset(250, 132),
      Paint()
        ..color = AppColors.apricot
        ..strokeWidth = 2.1
        ..strokeCap = StrokeCap.round,
    );

    _triangle(
      canvas,
      Offset(320 + math.sin(phase) * 2, 47 + math.cos(phase) * 2.5),
      24,
      AppColors.lavenderTriangle.withValues(alpha: 0.22),
    );

    _triangle(
      canvas,
      Offset(
        344 + math.sin(phase + 1.8) * 1.7,
        103 + math.cos(phase + 1.8) * 2,
      ),
      11,
      AppColors.apricot.withValues(alpha: 0.22),
      rotation: math.pi,
    );

    canvas.restore();
  }

  void _triangle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    double rotation = 0,
  }) {
    canvas.save();

    canvas.translate(center.dx, center.dy);

    canvas.rotate(rotation);

    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(-radius * 0.55, -radius * 0.86)
      ..lineTo(-radius * 0.55, radius * 0.86)
      ..close();

    canvas.drawPath(path, Paint()..color = color);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VectorSignUpHeaderPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class ButtonTrianglePainter extends CustomPainter {
  const ButtonTrianglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(1.8, 0.8)
      ..quadraticBezierTo(0, 0, 0, 2)
      ..lineTo(0, size.height - 2)
      ..quadraticBezierTo(0, size.height, 1.8, size.height - 0.8)
      ..lineTo(size.width - 1, size.height / 2 + 1)
      ..quadraticBezierTo(
        size.width + 0.5,
        size.height / 2,
        size.width - 1,
        size.height / 2 - 1,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.purple);
  }

  @override
  bool shouldRepaint(covariant ButtonTrianglePainter oldDelegate) => false;
}
