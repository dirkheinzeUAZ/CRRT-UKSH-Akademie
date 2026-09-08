import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Zeichnet ein Rechteck mit abgerundeten Ecken als Path (für Fill/Stroke).
Path roundedRectPath(double x, double y, double w, double h, double r) {
  return Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)));
}

/// Zeichnet eine einfache Pfeilspitze an Position (x,y) in Richtung `angle` (rad).
void drawArrowHead(Canvas canvas, Offset pos, double angle, Color color, {double size = 8}) {
  final paint = Paint()..color = color..style = PaintingStyle.fill;
  final p1 = Offset(
    pos.dx - size * math.cos(angle - 0.4),
    pos.dy - size * math.sin(angle - 0.4),
  );
  final p2 = Offset(
    pos.dx - size * math.cos(angle + 0.4),
    pos.dy - size * math.sin(angle + 0.4),
  );
  final path = Path()
    ..moveTo(pos.dx, pos.dy)
    ..lineTo(p1.dx, p1.dy)
    ..lineTo(p2.dx, p2.dy)
    ..close();
  canvas.drawPath(path, paint);
}

/// Zeichnet eine gepunktete/gestrichelte Polylinie mit Flow-Animation (Offset verschiebt Muster).
void drawDashedPolyline(
  Canvas canvas,
  List<Offset> points,
  Paint paint, {
  double dash = 8,
  double gap = 5,
  double offset = 0,
}) {
  if (points.length < 2) return;
  final pattern = dash + gap;
  double patternPos = offset % pattern;
  if (patternPos < 0) patternPos += pattern;

  for (int i = 0; i < points.length - 1; i++) {
    final p0 = points[i];
    final p1 = points[i + 1];
    final segLen = (p1 - p0).distance;
    if (segLen < 0.001) continue;
    final dirX = (p1.dx - p0.dx) / segLen;
    final dirY = (p1.dy - p0.dy) / segLen;
    double travelled = 0;
    while (travelled < segLen) {
      final posInPattern = patternPos % pattern;
      final isDash = posInPattern < dash;
      double drawLen = isDash ? (dash - posInPattern) : (pattern - posInPattern);
      drawLen = math.min(drawLen, segLen - travelled);
      if (drawLen <= 0) drawLen = 0.01;
      if (isDash) {
        final start = Offset(p0.dx + dirX * travelled, p0.dy + dirY * travelled);
        final end = Offset(p0.dx + dirX * (travelled + drawLen), p0.dy + dirY * (travelled + drawLen));
        canvas.drawLine(start, end, paint);
      }
      travelled += drawLen;
      patternPos += drawLen;
    }
  }
}

/// Zeichnet eine durchgezogene Polylinie (für statische/nicht-fließende Leitungen).
void drawPolyline(Canvas canvas, List<Offset> points, Paint paint) {
  if (points.length < 2) return;
  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (final p in points.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  canvas.drawPath(path, paint);
}

/// Vereinfachtes Text-Zeichnen auf Canvas.
void drawText(
  Canvas canvas,
  String text,
  Offset pos, {
  Color color = Colors.white,
  double fontSize = 10,
  FontWeight weight = FontWeight.normal,
  TextAlign align = TextAlign.left,
  String fontFamily = 'monospace',
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight, fontFamily: fontFamily),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
  );
  tp.layout();
  double dx = pos.dx;
  if (align == TextAlign.center) dx -= tp.width / 2;
  if (align == TextAlign.right) dx -= tp.width;
  tp.paint(canvas, Offset(dx, pos.dy));
}

/// Zeichnet eine Schlauchklemme / Verbindungssymbol (kleiner Zylinder).
void drawConnectorCap(Canvas canvas, Offset pos, Color color, {double r = 11, String? label}) {
  final paint = Paint()..color = color..style = PaintingStyle.fill;
  canvas.drawCircle(pos, r, paint);
  final ring = Paint()
    ..color = Colors.white.withValues(alpha: 0.85)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  canvas.drawCircle(pos, r, ring);
  canvas.drawCircle(pos, r * 0.42, Paint()..color = Colors.white.withValues(alpha: 0.55));
  if (label != null) {
    drawText(canvas, label, Offset(pos.dx, pos.dy + r + 3), color: color, fontSize: 9, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  }
}
