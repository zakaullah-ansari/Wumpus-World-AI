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

    if (hasStench) {
      final stenchPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.green.withOpacity(0.55),
            Colors.green.withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.5),
        );
      canvas.drawCircle(center, size.width * 0.5, stenchPaint);
    }

    if (hasBreeze) {
      final windPaint = Paint()
        ..color = Colors.lightBlueAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      // Draw 4 diagonal "wind vector" lines radiating out from the centre,
      // each capped with a tiny arrowhead.
      for (int i = 0; i < 4; i++) {
        final angle = (pi / 2) * i + pi / 4;
        final direction = Offset(cos(angle), sin(angle));
        final start = center + direction * (size.width * 0.15);
        final end = center + direction * (size.width * 0.38);
        canvas.drawLine(start, end, windPaint);
        _drawArrowHead(canvas, end, angle, windPaint);
      }
    }
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
