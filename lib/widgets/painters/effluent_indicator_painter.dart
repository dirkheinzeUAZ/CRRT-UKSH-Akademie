import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../machine_layout.dart';
import '../../theme/app_colors.dart';
import '../../models/crrt_state.dart';
import 'draw_utils.dart';

/// Visualisiert an der Abflusspumpe, aus welchen Anteilen sich ihre Fördermenge
/// zusammensetzt (Dialysat / Entzug / ggf. Substituat bei Prädilution) –
/// zeigt anschaulich die "Kommunikation" der Pumpen untereinander.
void drawEffluentIndicator(Canvas canvas, CrrtState st) {
  const cx = ML.p1cx, cy = ML.p1cy, r = ML.p1r;
  final outerR = r + 16;

  final qd = st.qd / 3000;
  final quf = st.quf / 2500;
  final qsPreFrac = (st.qs > 0 && st.subMode == SubMode.pre) ? st.qs / 3000 * 0.10 : 0.0;

  double start = -math.pi / 2;
  if (st.hasDialysat && qd > 0) {
    final sweep = math.pi * 2 * qd;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: outerR), start, sweep, false,
        Paint()..color = AppColors.dialysate..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    start += sweep;
  }
  if (quf > 0) {
    final sweep = math.pi * 2 * quf;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: outerR), start, sweep, false,
        Paint()..color = const Color(0xFFE94560)..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    start += sweep;
  }
  if (qsPreFrac > 0) {
    final sweep = math.pi * 2 * qsPreFrac;
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
  if (qsPreFrac > 0) {
    drawText(canvas, 'QS', Offset(lx, ly), color: AppColors.substituate, fontSize: 8, fontFamily: 'sans-serif');
  }
}
