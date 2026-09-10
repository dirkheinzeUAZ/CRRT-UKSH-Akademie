import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../machine_layout.dart';
import '../../theme/app_colors.dart';
import '../../models/crrt_state.dart';
import 'draw_utils.dart';

/// Visualisiert an der Abflusspumpe, aus welchen Anteilen sich ihre Fördermenge
/// zusammensetzt (Dialysat / Entzug / Substituat) – zeigt anschaulich die
/// "Kommunikation" der Pumpen untereinander. Das Substituat wird HIER IMMER
/// berücksichtigt (unabhängig von Prä-/Postdilution), da es klinisch stets
/// zusätzlich zum Netto-Entzug abgeführt werden muss (siehe qEff-Getter).
/// Die drei Segmente sind echte Anteile am Gesamt-Qeff (Kreis = 100% von Qeff).
void drawEffluentIndicator(Canvas canvas, CrrtState st) {
  const cx = ML.p1cx, cy = ML.p1cy, r = ML.p1r;
  final outerR = r + 16;

  final qEff = st.qEff;
  final qdFrac = qEff > 0 ? st.qd / qEff : 0.0;
  final qufFrac = qEff > 0 ? st.quf / qEff : 0.0;
  final qsFrac = qEff > 0 ? st.qs / qEff : 0.0;

  double start = -math.pi / 2;
  if (st.hasDialysat && qdFrac > 0) {
    final sweep = math.pi * 2 * qdFrac;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: outerR), start, sweep, false,
        Paint()..color = AppColors.dialysate..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    start += sweep;
  }
  if (qufFrac > 0) {
    final sweep = math.pi * 2 * qufFrac;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: outerR), start, sweep, false,
        Paint()..color = const Color(0xFFE94560)..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    start += sweep;
  }
  if (qsFrac > 0) {
    final sweep = math.pi * 2 * qsFrac;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: outerR), start, sweep, false,
        Paint()..color = AppColors.substituate..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }

  // Geschwindigkeit in %
  drawText(canvas, '${(st.speedEffluent.clamp(0, 1) * 100).toStringAsFixed(0)}%', Offset(cx, cy + r * 0.32),
      color: AppColors.effluent, fontSize: 10, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'monospace');

  // Mini-Legende neben Pumpe
  final lx = cx + outerR + 8;
  double ly = cy - 16;
  if (st.hasDialysat) {
    drawText(canvas, 'QD', Offset(lx, ly), color: AppColors.dialysate, fontSize: 8, fontFamily: 'sans-serif');
    ly += 12;
  }
  drawText(canvas, 'QUF', Offset(lx, ly), color: const Color(0xFFE94560), fontSize: 8, fontFamily: 'sans-serif');
  ly += 12;
  if (st.qs > 0) {
    drawText(canvas, 'QS', Offset(lx, ly), color: AppColors.substituate, fontSize: 8, fontFamily: 'sans-serif');
  }
}
