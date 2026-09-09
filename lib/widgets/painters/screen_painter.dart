import 'package:flutter/material.dart';
import '../machine_layout.dart';
import '../../theme/app_colors.dart';
import '../../models/crrt_state.dart';
import 'draw_utils.dart';

/// Zeichnet das Touchscreen-Display des Geräts (dunkel, wie am realen Gerät).
/// Bewusst reduziert auf das Wesentliche: Titel + große Filter-Laufzeit-Anzeige
/// mit Lauf-Status. Alle übrigen Messwerte (Drücke, TMP, Qeff, Pumpenraten)
/// werden bereits im Monitoring-Panel angezeigt – eine Doppelanzeige hier wäre
/// redundant und auf der kleinen Displayfläche schwer lesbar.
void drawScreen(Canvas canvas, CrrtState st) {
  const sX = ML.sX, sY = ML.sY, sW = ML.sW, sH = ML.sH, W = ML.W;

  canvas.drawPath(roundedRectPath(sX, sY, sW, sH, 14), Paint()..color = AppColors.screenBezel);
  canvas.drawPath(roundedRectPath(sX, sY, sW, sH, 14),
      Paint()..color = const Color(0xFF3A4658)..style = PaintingStyle.stroke..strokeWidth = 2);

  // LED-Leiste
  canvas.drawPath(roundedRectPath(sX, sY, sW, 11, 6), Paint()..color = AppColors.ok);
  canvas.drawCircle(Offset(sX + sW - 10, sY + 5.5), 4, Paint()..color = const Color(0xFF16A34A));

  final dY = sY + 11;
  final displayH = sH - 22; // etwas Rand zum Gehäuse-Übergang lassen (Überlappung vermeiden)
  final displayRect = Rect.fromLTWH(sX + 5, dY, sW - 10, displayH);
  canvas.drawRRect(
    RRect.fromRectAndRadius(displayRect, const Radius.circular(8)),
    Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: const [Color(0xFF071322), Color(0xFF0C1E32)]).createShader(displayRect),
  );

  // Titelzeile (Balkenhöhe 22px, Text oben-bündig innerhalb des Balkens platziert)
  const titleBarH = 22.0;
  canvas.drawRect(Rect.fromLTWH(sX + 5, dY, sW - 10, titleBarH), Paint()..color = const Color(0xFF0D2646));
  drawText(canvas, 'CRRT-SIM  ITS  –  ${modeLabel(st.mode)}', Offset(W / 2, dY + 4),
      color: AppColors.accentBlue, fontSize: 13, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'monospace');

  // Filter-Laufzeit (große, zentrale Anzeige – das einzige, was hier zählt)
  // Hinweis: drawText() positioniert an der TOP-Kante des Textes (kein vertikales
  // Zentrieren). Die Y-Offsets sind daher explizit so gestaffelt, dass jede Zeile
  // erst beginnt, wo die vorherige (inkl. Zeilenhöhe) bereits geendet hat.
  final fh = (st.filterRuntimeMin ~/ 60).toString().padLeft(2, '0');
  final fm = (st.filterRuntimeMin % 60).toString().padLeft(2, '0');
  final clockY = dY + titleBarH + 10; // Abstand zur Titelleiste
  drawText(canvas, '$fh:$fm', Offset(W / 2, clockY), color: Colors.white, fontSize: 32, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'monospace');

  final labelY = clockY + 40; // Uhr-Zeilenhöhe (~38px bei fontSize 32) + Puffer
  drawText(canvas, 'FILTER-LAUFZEIT', Offset(W / 2, labelY), color: AppColors.textDim, fontSize: 11, align: TextAlign.center, fontFamily: 'monospace');

  final statusY = labelY + 16; // Label-Zeilenhöhe (~14px bei fontSize 11) + Puffer
  final statusText = st.running ? '●  LÄUFT' : (st.filterRuntimeMin > 0 ? '⏸  PAUSE' : '●  BEREIT');
  final statusColor = st.running ? AppColors.ok : AppColors.textDim;
  drawText(canvas, statusText, Offset(W / 2, statusY), color: statusColor, fontSize: 11, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'monospace');
}
