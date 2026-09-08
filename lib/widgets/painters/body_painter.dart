import 'package:flutter/material.dart';
import '../machine_layout.dart';
import '../../theme/app_colors.dart';
import 'draw_utils.dart';

/// Zeichnet das Gehäuse im multiFiltrate-Look: helles Kunststoffgehäuse,
/// Frontpanel, "Halsstück" zum Bildschirm, Rollen unten.
void drawBody(Canvas canvas) {
  const bX = ML.bX, bY = ML.bY, bW = ML.bW, bH = ML.bH;
  final nX = ML.W / 2 - 110, nW = 220.0;

  // Schatten
  final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.30);
  canvas.drawPath(roundedRectPath(bX + 6, bY + 8, bW, bH, 26), shadowPaint);

  // Körper – heller Gradient (weiß -> hellgrau)
  final bodyRect = Rect.fromLTWH(bX, bY, bW, bH);
  final bodyPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [AppColors.housingDark, AppColors.housingLight, AppColors.housing],
      stops: const [0, 0.35, 1],
    ).createShader(bodyRect);
  canvas.drawPath(roundedRectPath(bX, bY, bW, bH, 26), bodyPaint);

  // Glanzlicht links / oben
  canvas.drawPath(
    roundedRectPath(bX, bY, 10, bH - 40, 6),
    Paint()..color = Colors.white.withValues(alpha: 0.5),
  );
  canvas.drawPath(
    roundedRectPath(bX + 10, bY, bW - 30, 8, 4),
    Paint()..color = Colors.white.withValues(alpha: 0.55),
  );

  // Frontpanel (etwas dunkler, wo die Pumpen sitzen)
  canvas.drawPath(
    roundedRectPath(bX + 18, bY + 20, bW - 36, bH - 40, 20),
    Paint()..color = AppColors.housingPanel,
  );
  canvas.drawPath(
    roundedRectPath(bX + 18, bY + 20, bW - 36, bH - 40, 20),
    Paint()
      ..color = AppColors.housingDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4,
  );

  // Hals zum Bildschirm
  final neckPaint = Paint()..color = AppColors.housingDark.withValues(alpha: 0.9);
  canvas.drawRect(Rect.fromLTWH(nX, ML.sY + ML.sH, nW, bY - (ML.sY + ML.sH) + 12), neckPaint);

  // Rollen
  final wheelDark = Paint()..color = const Color(0xFF394252);
  final wheelLight = Paint()..color = const Color(0xFF4B5568);
  for (final wx in [bX + 70, bX + bW - 70]) {
    canvas.drawOval(Rect.fromCenter(center: Offset(wx, bY + bH + 10), width: 46, height: 22), wheelDark);
    canvas.drawOval(Rect.fromCenter(center: Offset(wx, bY + bH + 7), width: 38, height: 18), wheelLight);
  }
  canvas.drawPath(
    roundedRectPath(bX + 30, bY + bH, bW - 60, 20, 10),
    Paint()..color = const Color(0xFF5B6478),
  );

  // Typenschild
  drawText(canvas, 'multiFiltrate-Sim  •  CE  •  ITS-Lernmodus', Offset(bX + bW / 2, bY + bH - 10),
      color: AppColors.textDim, fontSize: 9, align: TextAlign.center, fontFamily: 'sans-serif');
}
