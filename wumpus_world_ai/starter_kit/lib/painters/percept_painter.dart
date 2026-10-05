import 'dart:math';
import 'package:flutter/material.dart';

/// Paints two sensory overlays directly onto a single cave tile's canvas:
///   - Stench: a soft green "fog cloud" radial gradient
///   - Breeze: four short outward "wind vector" arrows
///
/// PRODUCTION MENTAL MODEL: a [CustomPainter] is a blank sheet of acetate
/// laid on top of (or behind) your widget. Every `canvas.draw...` call is
/// one more mark on that same sheet, painted in the order you call it —
/// later calls sit visually on top of earlier ones. Unlike normal widgets,
/// nothing here is "laid out" by Flutter; you are given raw pixels (`size`)
/// and full responsibility for where things go.
class PerceptPainter extends CustomPainter {
  final bool hasBreeze;
  final bool hasStench;

  PerceptPainter({required this.hasBreeze, required this.hasStench});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // TODO (BLOCK 2 — LIVE CODE WITH TRAINER), part A: paint the STENCH cloud.
    // 1. If `hasStench` is true, build a Paint with a RadialGradient shader
    //    (e.g. Colors.green.withOpacity(0.55) fading to withOpacity(0.0)),
    //    created via `.createShader(Rect.fromCircle(center: center, radius: size.width * 0.5))`.
    // 2. canvas.drawCircle(center, size.width * 0.5, thatPaint);

    // TODO (BLOCK 2 — LIVE CODE WITH TRAINER), part B: paint the BREEZE vectors.
    // 1. If `hasBreeze` is true, build a stroke Paint (e.g. Colors.lightBlueAccent,
    //    strokeWidth 2.5, style PaintingStyle.stroke).
    // 2. Loop `for (int i = 0; i < 4; i++)`, compute `angle = (pi / 2) * i + pi / 4`.
    // 3. Compute a `direction = Offset(cos(angle), sin(angle))`.
    // 4. Draw a line from `center + direction * (size.width * 0.15)`
    //    to `center + direction * (size.width * 0.38)` using canvas.drawLine.
    // 5. (Bonus) call `_drawArrowHead(canvas, end, angle, windPaint)` for a
    //    proper arrow tip.
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Paint paint) {
    const arrowLength = 6.0;
    final p1 = tip - Offset(cos(angle - 0.5), sin(angle - 0.5)) * arrowLength;
    final p2 = tip - Offset(cos(angle + 0.5), sin(angle + 0.5)) * arrowLength;
    canvas.drawLine(tip, p1, paint);
    canvas.drawLine(tip, p2, paint);
  }

  @override
  bool shouldRepaint(covariant PerceptPainter oldDelegate) =>
      oldDelegate.hasBreeze != hasBreeze || oldDelegate.hasStench != hasStench;
}
