import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../machine_layout.dart';
import '../../theme/app_colors.dart';
import '../../models/crrt_state.dart';
import 'draw_utils.dart';

/// Zeichnet alle Schlauchleitungen des Kreislaufs, farbcodiert:
///  - Blut (arteriell + durch Filter): ROT
///  - Blut venös (gereinigt) zurück zum Patienten: dunkleres Rot
///  - Filtrat: LILA
///  - Dialysat: GRÜN
///  - Effluat/Abfluss: GELB
///  - Substituat: CYAN, umschaltbar Prä-/Postdilution über Weiche
void drawTubing(Canvas canvas, CrrtState st) {
  const fX = ML.fX, fY = ML.fY, fW = ML.fW, fH = ML.fH;
  final fB = fY + fH;
  final tOffset = st.running ? -(st.machTick * 1.4) : 0.0;

  Paint tubePaint(Color c, {double lw = 5}) => Paint()
    ..color = c
    ..strokeWidth = lw
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void tube(List<Offset> pts, Color c, {double lw = 5, bool dashed = true, double alpha = 1}) {
    final p = tubePaint(c.withValues(alpha: alpha), lw: lw);
    if (dashed) {
      drawDashedPolyline(canvas, pts, p, dash: 9, gap: 6, offset: tOffset);
    } else {
      drawPolyline(canvas, pts, p);
    }
  }

  // ================= BLUTKREISLAUF (links) =================
  // Patient arteriell (roter Anschlussstopfen am Rand) -> Blutpumpe
  drawConnectorCap(canvas, const Offset(6, ML.patYArt), AppColors.arterialCap, r: 13, label: 'art.');
  tube([const Offset(18, ML.patYArt), Offset(ML.p6cx - ML.p6r - 12, ML.p6cy)], AppColors.blood, lw: 6);
  drawArrowHead(canvas, Offset(ML.p6cx - ML.p6r - 30, ML.patYArt), 0, AppColors.blood, size: 9);

  // Blutpumpe -> Filter Bluteinlass (oben links) – Bogen ohne Kreuzung
  tube([
    Offset(ML.p6cx + ML.p6r, ML.p6cy - ML.p6r * 0.3),
    Offset(ML.p6cx + ML.p6r + 40, ML.p6cy - ML.p6r * 0.3),
    Offset(ML.p6cx + ML.p6r + 40, fY - 40),
    Offset(fX + 20, fY - 40),
    Offset(fX + 20, fY - 8),
  ], AppColors.blood, lw: 6);
  drawArrowHead(canvas, Offset(fX + 20, fY - 20), math.pi / 2, AppColors.blood, size: 9);

  // Substituat PRÄ-Filter mündet hier zusätzlich ein (siehe unten, Weiche)

  // Filter Blutauslass (unten links) -> venös -> Patient
  tube([
    Offset(fX + 20, fB + 8),
    Offset(fX + 20, ML.patYVen),
    const Offset(18, ML.patYVen),
  ], AppColors.bloodDark, lw: 6);
  drawArrowHead(canvas, const Offset(24, ML.patYVen), math.pi, AppColors.bloodDark, size: 9);
  drawConnectorCap(canvas, const Offset(6, ML.patYVen), AppColors.venousCap, r: 13, label: 'ven.');

  // ================= SUBSTITUAT (nur HDF / HF) =================
  if (st.hasSubstPump) {
    final substOpacity = st.qs > 0 ? 1.0 : 0.3;
    final weicheCenter = Offset(ML.p5cx - 46, ML.p5cy);

    // Zulauf ⑤ -> Weiche
    tube([Offset(ML.p5cx - ML.p5r, ML.p5cy), weicheCenter], AppColors.substituate, lw: 4, dashed: false, alpha: substOpacity);

    if (st.subMode == SubMode.post) {
      // POST: Weiche -> unten -> venöse Linie (nahe Patient)
      tube([
        weicheCenter,
        Offset(weicheCenter.dx, ML.patYVen + 40),
        Offset(fX + 20, ML.patYVen + 40),
        Offset(fX + 20, ML.patYVen + 6),
      ], AppColors.substituate, lw: 4, alpha: substOpacity);
      if (st.qs > 0) {
        drawArrowHead(canvas, Offset(fX + 20, ML.patYVen + 20), -math.pi / 2, AppColors.substituate, size: 8);
      }
      // gedimmter Prä-Pfad (zur Orientierung)
      tube([
        weicheCenter,
        Offset(weicheCenter.dx, fY - 60),
        Offset(fX + 34, fY - 60),
        Offset(fX + 34, fY - 8),
      ], AppColors.substituate, lw: 2.5, dashed: false, alpha: substOpacity * 0.12);
    } else {
      // PRÄ: Weiche -> oben -> Filter-Bluteinlass
      tube([
        weicheCenter,
        Offset(weicheCenter.dx, fY - 60),
        Offset(fX + 34, fY - 60),
        Offset(fX + 34, fY - 8),
      ], AppColors.substituate, lw: 4, alpha: substOpacity);
      if (st.qs > 0) {
        drawArrowHead(canvas, Offset(fX + 34, fY - 20), -math.pi / 2, AppColors.substituate, size: 8);
      }
      // gedimmter Post-Pfad
      tube([
        weicheCenter,
        Offset(weicheCenter.dx, ML.patYVen + 40),
        Offset(fX + 20, ML.patYVen + 40),
        Offset(fX + 20, ML.patYVen + 6),
      ], AppColors.substituate, lw: 2.5, dashed: false, alpha: substOpacity * 0.12);
    }

    // Weiche-Symbol (Umschaltventil)
    _drawWeiche(canvas, weicheCenter, st.subMode, substOpacity);

    // Substituat-Zufluss von rechts -> Pumpe ⑤
    tube([Offset(ML.W - 4, ML.p5cy), Offset(ML.p5cx + ML.p5r, ML.p5cy)], AppColors.substituate, lw: 4.5, dashed: false, alpha: st.qs > 0 ? 1 : 0.3);
  }

  // ================= DIALYSAT (rechts, nur wenn vorhanden) =================
  if (st.hasDialysat) {
    // Zufluss von rechts -> ④ Dialysatpumpe
    tube([Offset(ML.W - 4, ML.p4cy), Offset(ML.p4cx + ML.p4r, ML.p4cy)], AppColors.dialysate, lw: 4.5, dashed: false);
    drawArrowHead(canvas, Offset(ML.p4cx + ML.p4r + 14, ML.p4cy), math.pi, AppColors.dialysate, size: 8);

    // ④ -> Filter Dialysateinlass unten-rechts
    tube([
      Offset(ML.p4cx - ML.p4r, ML.p4cy),
      Offset(fX + fW - 34, ML.p4cy),
      Offset(fX + fW - 34, fB + 8),
    ], AppColors.dialysate, lw: 5.5);
    drawArrowHead(canvas, Offset(fX + fW - 34, fB + 20), -math.pi / 2, AppColors.dialysate, size: 8);
  }

  // ================= FILTRAT/EFFLUAT -> Abflusspumpe -> Ablauf =================
  // Filter Auslass oben-rechts -> ① Abflusspumpe
  final substCross = st.hasSubstPump && st.subMode == SubMode.pre && st.qs > 0;
  if (substCross) {
    tube([Offset(fX + fW - 20, fY - 8), Offset(fX + fW - 20, fY - 46)], AppColors.filtrate, lw: 5.5);
    // kleine Brücke über die Substituat-Kreuzung
    final bridgeCenter = Offset(fX + fW - 4, fY - 46);
    canvas.drawArc(Rect.fromCircle(center: bridgeCenter, radius: 6), math.pi, math.pi, false,
        Paint()..color = AppColors.filtrate..strokeWidth = 5.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    tube([
      Offset(fX + fW - 4 + 6, fY - 46),
      Offset(ML.p1cx, fY - 46),
      Offset(ML.p1cx, ML.p1cy - ML.p1r - 6),
    ], AppColors.filtrate, lw: 5.5);
  } else {
    tube([
      Offset(fX + fW - 20, fY - 8),
      Offset(fX + fW - 20, fY - 46),
      Offset(ML.p1cx, fY - 46),
      Offset(ML.p1cx, ML.p1cy - ML.p1r - 6),
    ], AppColors.filtrate, lw: 5.5);
  }
  drawArrowHead(canvas, Offset(ML.p1cx - 40, fY - 46), 0, AppColors.filtrate, size: 8);

  // ① Abflusspumpe -> Ablaufbeutel (Effluat: Dialysat+UF+Filtrat gemischt = GELB)
  tube([
    Offset(ML.p1cx, ML.p1cy + ML.p1r + 6),
    Offset(ML.p1cx, ML.drainY - 30),
    Offset(ML.drainX, ML.drainY - 30),
    Offset(ML.drainX, ML.drainY - 8),
  ], AppColors.effluent, lw: 5.5);
  drawArrowHead(canvas, Offset(ML.p1cx, ML.drainY - 60), math.pi / 2, AppColors.effluent, size: 8);

  // Ablaufbeutel
  _drawDrainBag(canvas, Offset(ML.drainX, ML.drainY));
}

void _drawWeiche(Canvas canvas, Offset pos, SubMode mode, double opacity) {
  const r = 15.0;
  canvas.drawCircle(pos, r, Paint()..color = const Color(0xFF0D2030).withValues(alpha: opacity));
  canvas.drawCircle(pos, r, Paint()
    ..color = AppColors.substituate.withValues(alpha: opacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4);

  final active = AppColors.substituate;
  final dim = AppColors.substituate.withValues(alpha: 0.18);

  // Oben (Prä)
  final upPaint = Paint()
    ..color = (mode == SubMode.pre ? active : dim).withValues(alpha: opacity)
    ..strokeWidth = 2.6;
  canvas.drawLine(Offset(pos.dx, pos.dy - 4), Offset(pos.dx, pos.dy - r + 4), upPaint);
  if (mode == SubMode.pre) {
    drawArrowHead(canvas, Offset(pos.dx, pos.dy - r + 3), -math.pi / 2, active.withValues(alpha: opacity), size: 6);
  }
  // Unten (Post)
  final downPaint = Paint()
    ..color = (mode == SubMode.post ? active : dim).withValues(alpha: opacity)
    ..strokeWidth = 2.6;
  canvas.drawLine(Offset(pos.dx, pos.dy + 4), Offset(pos.dx, pos.dy + r - 4), downPaint);
  if (mode == SubMode.post) {
    drawArrowHead(canvas, Offset(pos.dx, pos.dy + r - 3), math.pi / 2, active.withValues(alpha: opacity), size: 6);
  }

  drawText(canvas, 'W', Offset(pos.dx, pos.dy + 4), color: active.withValues(alpha: opacity), fontSize: 10, weight: FontWeight.bold, align: TextAlign.center);
  drawText(canvas, mode == SubMode.pre ? 'Prä' : 'Post', Offset(pos.dx, pos.dy - r - 8),
      color: active.withValues(alpha: opacity), fontSize: 10, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
}

void _drawDrainBag(Canvas canvas, Offset topCenter) {
  final w = 64.0, h = 78.0;
  final rect = Rect.fromLTWH(topCenter.dx - w / 2, topCenter.dy, w, h);
  final path = roundedRectPath(rect.left, rect.top, w, h, 14);
  canvas.drawPath(path, Paint()..color = AppColors.effluent.withValues(alpha: 0.22));
  canvas.drawPath(path, Paint()
    ..color = AppColors.effluent.withValues(alpha: 0.85)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2);
  // Flüssigkeitsfüllstand
  canvas.drawPath(
    roundedRectPath(rect.left + 4, rect.top + h * 0.35, w - 8, h * 0.6, 10),
    Paint()..color = AppColors.effluent.withValues(alpha: 0.45),
  );
  drawText(canvas, 'Effluat', Offset(topCenter.dx, rect.bottom + 14),
      color: AppColors.effluent, fontSize: 10, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
}
