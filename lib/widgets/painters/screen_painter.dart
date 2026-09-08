import 'package:flutter/material.dart';
import '../machine_layout.dart';
import '../../theme/app_colors.dart';
import '../../models/crrt_state.dart';
import 'draw_utils.dart';

/// Zeichnet das Touchscreen-Display des Geräts (dunkel, wie am realen Gerät)
/// mit Pumpenbalken, Filter-Laufzeit und Statuszeile (Drücke, TMP, Qeff).
void drawScreen(Canvas canvas, CrrtState st) {
  const sX = ML.sX, sY = ML.sY, sW = ML.sW, sH = ML.sH, W = ML.W;

  canvas.drawPath(roundedRectPath(sX, sY, sW, sH, 14), Paint()..color = AppColors.screenBezel);
  canvas.drawPath(roundedRectPath(sX, sY, sW, sH, 14),
      Paint()..color = const Color(0xFF3A4658)..style = PaintingStyle.stroke..strokeWidth = 2);

  // LED-Leiste
  canvas.drawPath(roundedRectPath(sX, sY, sW, 11, 6), Paint()..color = AppColors.ok);
  canvas.drawCircle(Offset(sX + sW - 10, sY + 5.5), 4, Paint()..color = const Color(0xFF16A34A));

  final dY = sY + 11;
  final displayRect = Rect.fromLTWH(sX + 5, dY, sW - 10, sH - 16);
  canvas.drawRRect(
    RRect.fromRectAndRadius(displayRect, const Radius.circular(8)),
    Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: const [Color(0xFF071322), Color(0xFF0C1E32)]).createShader(displayRect),
  );

  // Titelzeile
  canvas.drawRect(Rect.fromLTWH(sX + 5, dY, sW - 10, 20), Paint()..color = const Color(0xFF0D2646));
  drawText(canvas, 'CRRT-SIM  ITS  –  ${modeLabel(st.mode)}', Offset(W / 2, dY + 14),
      color: AppColors.accentBlue, fontSize: 12, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'monospace');

  // Pumpenbalken
  final qEff = st.qEff;
  final allBars = <_BarSpec>[
    _BarSpec('ABFL', st.speedEffluent.clamp(0, 1), AppColors.effluent, '${qEff.round()} ml/h', true),
    _BarSpec('HEP', st.qSyringe / 20, AppColors.heparin, '${st.qSyringe.toStringAsFixed(1)}ml/h', true),
    _BarSpec('DIAL', st.qd / 3000, AppColors.dialysate, '${st.qd.round()}ml/h', st.hasDialysat),
    _BarSpec('SUB', st.qs / 3000, AppColors.substituate, '${st.qs.round()}ml/h', st.hasSubstPump),
    _BarSpec('BLUT', st.qb / 300, AppColors.blood, '${st.qb.round()}ml/m', true),
  ];
  final bars = allBars.where((b) => b.visible).toList();
  const bW2 = 92.0, bH = 15.0;
  final bY2 = dY + 32;
  final totalGap = (sW - 10 - bars.length * bW2);
  final bGap = bars.isEmpty ? 0 : totalGap / (bars.length + 1);
  for (int i = 0; i < bars.length; i++) {
    final b = bars[i];
    final bx = sX + 5 + bGap + (bW2 + bGap) * i;
    canvas.drawRect(Rect.fromLTWH(bx, bY2, bW2, bH), Paint()..color = const Color(0xFF0A1420));
    final fillW = (b.value * bW2).clamp(2.0, bW2);
    canvas.drawRect(Rect.fromLTWH(bx, bY2, fillW, bH), Paint()..color = b.color);
    drawText(canvas, b.label, Offset(bx + bW2 / 2, bY2 - 4), color: b.color, fontSize: 9, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'monospace');
    drawText(canvas, b.unit, Offset(bx + bW2 / 2, bY2 + bH + 12), color: const Color(0xFFC0C8D8), fontSize: 9, align: TextAlign.center, fontFamily: 'monospace');
  }

  // Filter-Laufzeit (große Anzeige)
  final fh = (st.filterRuntimeMin ~/ 60).toString().padLeft(2, '0');
  final fm = (st.filterRuntimeMin % 60).toString().padLeft(2, '0');
  drawText(canvas, '$fh:$fm', Offset(W / 2, dY + 78), color: Colors.white, fontSize: 26, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'monospace');
  drawText(canvas, 'Filter-Laufzeit', Offset(W / 2, dY + 94), color: AppColors.textDim, fontSize: 10, align: TextAlign.center, fontFamily: 'monospace');

  // Statuszeile unten
  final statusY = dY + sH - 32;
  canvas.drawRect(Rect.fromLTWH(sX + 5, statusY, sW - 10, 24), Paint()..color = const Color(0xFF06101E));
  final pArt = st.pArt, pVen = st.pVen, tmp = st.tmp;

  final col = sW - 10;
  final positions = [sX + 14, sX + 14 + col * 0.22, sX + 14 + col * 0.42, sX + 14 + col * 0.62, sX + 14 + col * 0.80];

  drawText(canvas, 'P-art: $pArt', Offset(positions[0], statusY + 15),
      color: (pArt < -220 || pArt > -20) ? AppColors.alert : const Color(0xFFF87171), fontSize: 10, fontFamily: 'monospace');
  drawText(canvas, 'P-ven: $pVen', Offset(positions[1], statusY + 15),
      color: (pVen > 200 || pVen < 20) ? AppColors.alert : const Color(0xFFA78BFA), fontSize: 10, fontFamily: 'monospace');
  drawText(canvas, 'TMP: $tmp', Offset(positions[2], statusY + 15),
      color: tmp > 300 ? AppColors.alert : (tmp > 200 ? AppColors.warn : AppColors.accentBlue), fontSize: 10, fontFamily: 'monospace');
  drawText(canvas, st.running ? '● LÄUFT' : (st.filterRuntimeMin > 0 ? '⏸ PAUSE' : '● BEREIT'),
      Offset(positions[3], statusY + 15), color: st.running ? AppColors.ok : AppColors.textDim, fontSize: 10, fontFamily: 'monospace');
  drawText(canvas, 'Qeff: ${qEff.round()}', Offset(positions[4], statusY + 15), color: AppColors.effluent, fontSize: 10, fontFamily: 'monospace');
}

class _BarSpec {
  final String label;
  final double value;
  final Color color;
  final String unit;
  final bool visible;
  _BarSpec(this.label, this.value, this.color, this.unit, this.visible);
}
