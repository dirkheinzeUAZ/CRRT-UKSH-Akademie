import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Zeichnet eine Schlauchrollenpumpe (peristaltische Pumpe) im multiFiltrate-Stil:
/// weißes/cremefarbenes Gehäuse mit rotierenden Rollen + farbiger Schlauchführung.
void drawPeristalticPump(
  Canvas canvas, {
  required Offset center,
  required double r,
  required Color color,
  required double angle,
  required bool active,
  required String label,
  bool visible = true,
}) {
  if (!visible) return;
  final cx = center.dx, cy = center.dy;

  // Gehäusering
  canvas.drawCircle(Offset(cx, cy), r + 7,
      Paint()..color = const Color(0xFFF3F5F9));
  canvas.drawCircle(Offset(cx, cy), r + 7,
      Paint()
        ..color = const Color(0xFFAEB8C8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6);

  // Farbiger Schlauchbogen (zeigt welches Fluid)
  final arcPaint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round;
  canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r + 3),
      -math.pi * 0.85, math.pi * 1.55, false, arcPaint);

  // Pumpenkörper (Kunststoff, leicht gräulich mit Radial-Glanz)
  final bodyRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
  final bodyPaint = Paint()
    ..shader = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: const [Color(0xFFFFFFFF), Color(0xFFDCE1EA)],
    ).createShader(bodyRect);
  canvas.drawCircle(Offset(cx, cy), r, bodyPaint);
  canvas.drawCircle(Offset(cx, cy), r,
      Paint()
        ..color = const Color(0xFFB8C0D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);

  // Rotor-Zentrum
  canvas.drawCircle(Offset(cx, cy), r * 0.5, Paint()..color = const Color(0xFFE4E8EF));

  // Rollen
  final numR = r > 45 ? 3 : 3;
  final rR = r > 45 ? 9.0 : 6.5;
  for (int i = 0; i < numR; i++) {
    final a = angle + (i * math.pi * 2 / numR);
    final rx = cx + r * 0.54 * math.cos(a);
    final ry = cy + r * 0.54 * math.sin(a);
    canvas.drawCircle(Offset(rx, ry), rR,
        Paint()..color = active ? color : const Color(0xFF9AA4B4));
    canvas.drawCircle(Offset(rx, ry), rR,
        Paint()
          ..color = active ? color.withValues(alpha: 0.55) : const Color(0xFF7C879A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }
  canvas.drawCircle(Offset(cx, cy), 3.2, Paint()..color = const Color(0xFF808A9C));

  // Klappe/Deckel-Andeutung (halbtransparenter Ring, wie Schutzabdeckung)
  canvas.drawCircle(Offset(cx, cy), r + 3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
}

