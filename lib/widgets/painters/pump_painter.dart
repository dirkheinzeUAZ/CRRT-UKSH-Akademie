import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'draw_utils.dart';

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

/// Zeichnet die Heparin-Spritzenpumpe (rechteckiges Modul mit Glaszylinder + Kolben).
void drawSyringePump(Canvas canvas, {
  required Rect rect,
  required Color color,
  required bool active,
  required double machTick,
}) {
  final x = rect.left, y = rect.top, w = rect.width, h = rect.height;

  canvas.drawPath(roundedRectPath(x - 3, y - 3, w + 6, h + 6, 9),
      Paint()..color = const Color(0xFFF3F5F9));
  canvas.drawPath(roundedRectPath(x - 3, y - 3, w + 6, h + 6, 9),
      Paint()
        ..color = const Color(0xFFAEB8C8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4);

  // Glaszylinder
  canvas.drawPath(roundedRectPath(x + 6, y + 4, w - 24, h - 8, 5),
      Paint()..color = Colors.white.withValues(alpha: 0.55));
  canvas.drawPath(roundedRectPath(x + 6, y + 4, w - 24, h - 8, 5),
      Paint()
        ..color = const Color(0xFF9FB0C8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);

  // Skalenstriche
  final tickPaint = Paint()
    ..color = const Color(0xFF9FB0C8).withValues(alpha: 0.6)
    ..strokeWidth = 0.8;
  for (int i = 0; i < 5; i++) {
    final tx = x + 12 + i * (w - 34) / 4;
    canvas.drawLine(Offset(tx, y + 5), Offset(tx, y + h - 5), tickPaint);
  }

  // Kolben (bewegt sich, wenn aktiv)
  final plx = x + 10 + (active ? ((machTick * 0.5) % (w - 26)) : (w - 26) * 0.5);
  canvas.drawLine(Offset(plx, y + 3), Offset(plx, y + h - 3),
      Paint()
        ..color = color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round);

  // Ansatzstück rechts
  final tipPath = Path()
    ..moveTo(x + w - 12, y + h / 2 - 4)
    ..lineTo(x + w - 12, y + h / 2 + 4)
    ..lineTo(x + w - 2, y + h / 2)
    ..close();
  canvas.drawPath(tipPath, Paint()..color = const Color(0xFF8B96A8));

  drawText(canvas, 'Heparin', Offset(x + w / 2, y + h + 12),
      color: color, fontSize: 9, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
}
