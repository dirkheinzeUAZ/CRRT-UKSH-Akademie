import 'package:flutter/material.dart';
import '../machine_layout.dart';
import '../../theme/app_colors.dart';
import '../../models/crrt_state.dart';
import 'draw_utils.dart';

/// Zeichnet statische Beschriftungen: Pumpennamen, Filtertitel, Anschlussbeschriftungen,
/// Drucksensor-Badges.
void drawLabels(Canvas canvas, CrrtState st) {
  drawText(canvas, '① Abflusspumpe', Offset(ML.p1cx, ML.p1cy + ML.p1r + 22),
      color: AppColors.effluent, fontSize: 11, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  drawText(canvas, '③ Heparinpumpe', Offset(ML.p3x + ML.p3w / 2, ML.p3y + ML.p3h + 24),
      color: AppColors.heparin, fontSize: 10, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  if (st.hasDialysat) {
    drawText(canvas, '④ Dialysatpumpe', Offset(ML.p4cx, ML.p4cy + ML.p4r + 22),
        color: AppColors.dialysate, fontSize: 11, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  }
  if (st.hasSubstPump) {
    drawText(canvas, '⑤ Substitution', Offset(ML.p5cx, ML.p5cy + ML.p5r + 22),
        color: AppColors.substituate, fontSize: 11, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  }
  drawText(canvas, '⑥ Blutpumpe', Offset(ML.p6cx, ML.p6cy + ML.p6r + 26),
      color: AppColors.blood, fontSize: 12, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');

  // Filtertitel
  final filterTitle = st.mode == CrrtMode.scuf
      ? 'HÄMOFILTER (SCUF)'
      : st.mode == CrrtMode.cvvhf
          ? 'HÄMOFILTER (CVVHF)'
          : 'HÄMODIAFILTER (CRRT)';
  drawText(canvas, filterTitle, Offset(ML.fX + ML.fW / 2, ML.fY - 30),
      color: Colors.white.withValues(alpha: 0.85), fontSize: 13, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');

  // Anschlussbeschriftungen
  drawText(canvas, 'Patient – arterieller Zugang', Offset(26, ML.patYArt - 20),
      color: AppColors.arterialCap, fontSize: 10, weight: FontWeight.bold, fontFamily: 'sans-serif');
  drawText(canvas, 'Patient – venöser Rückfluss', Offset(26, ML.patYVen - 20),
      color: AppColors.venousCap, fontSize: 10, weight: FontWeight.bold, fontFamily: 'sans-serif');

  if (st.hasDialysat) {
    drawText(canvas, 'Dialysat-Zufluss ►', Offset(ML.W - 8, ML.p4cy - 18),
        color: AppColors.dialysate, fontSize: 10, weight: FontWeight.bold, align: TextAlign.right, fontFamily: 'sans-serif');
  }
  if (st.hasSubstPump) {
    drawText(canvas, 'Substituat-Zufluss ►', Offset(ML.W - 8, ML.p5cy - 18),
        color: AppColors.substituate, fontSize: 10, weight: FontWeight.bold, align: TextAlign.right, fontFamily: 'sans-serif');
  }

  // Drucksensor-Badges
  _pressureBadge(canvas, 'P-art', Offset(66, ML.patYArt - 46), const Color(0xFFF87171));
  _pressureBadge(canvas, 'P-ven', Offset(ML.p6cx + ML.p6r + 34, ML.p6cy + 40), const Color(0xFFA78BFA));
}

void _pressureBadge(Canvas canvas, String text, Offset pos, Color color) {
  final rect = Rect.fromCenter(center: pos, width: 46, height: 20);
  canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), Paint()..color = color.withValues(alpha: 0.14));
  canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.2);
  drawText(canvas, text, Offset(pos.dx, pos.dy - 4), color: color, fontSize: 9, align: TextAlign.center, fontFamily: 'monospace');
}
