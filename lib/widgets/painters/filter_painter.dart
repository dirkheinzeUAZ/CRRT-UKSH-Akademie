import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../machine_layout.dart';
import '../../theme/app_colors.dart';
import '../../models/crrt_state.dart';
import 'draw_utils.dart';

/// Zeichnet den zentralen Hämofilter mit sichtbaren Kapillar-Lamellen,
/// Blutseite (rot) und Dialysat-/Filtratseite (grün/lila), inkl.
/// Partikelanimation für Diffusion, Konvektion und Verklottung.
void drawFilter(Canvas canvas, CrrtState st) {
  const fX = ML.fX, fY = ML.fY, fW = ML.fW, fH = ML.fH;
  final mX = ML.mX;
  final bW = mX - fX, dW = fX + fW - mX;
  final hF = (st.harnstoff / 100).clamp(0.0, 2.0);
  final clot = st.effectiveClot;
  final perm = st.permeabilityFactor;

  // ---- Außengehäuse (Filterkapsel) ----
  canvas.drawPath(roundedRectPath(fX - 10, fY - 10, fW + 20, fH + 20, 20),
      Paint()..color = const Color(0xFF7C8BAA));
  canvas.drawPath(roundedRectPath(fX - 4, fY - 4, fW + 8, fH + 8, 17),
      Paint()
        ..color = const Color(0xFF9AA8C4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);

  // ---- Blutseiten-Hintergrund (rot, Sättigung je nach Harnstoffkonzentration) ----
  final bloodBgRect = Rect.fromLTWH(fX, fY, bW, fH);
  final bloodBg = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.blood.withValues(alpha: 0.30 + hF * 0.40),
        AppColors.blood.withValues(alpha: 0.14 + hF * 0.18),
        AppColors.bloodDark.withValues(alpha: 0.10),
      ],
    ).createShader(bloodBgRect);
  canvas.drawRect(bloodBgRect, bloodBg);

  // ---- Dialysat-/Filtratseiten-Hintergrund ----
  if (st.hasDialysat) {
    final dRect = Rect.fromLTWH(mX, fY, dW, fH);
    final dBg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          AppColors.dialysate.withValues(alpha: 0.22),
          AppColors.dialysate.withValues(alpha: 0.10 + hF * 0.12),
          AppColors.filtrate.withValues(alpha: 0.10 + hF * 0.16),
        ],
      ).createShader(dRect);
    canvas.drawRect(dRect, dBg);
  } else {
    // Nur Filtratseite (CVVHF / SCUF) – lila
    final dRect = Rect.fromLTWH(mX, fY, dW, fH);
    canvas.drawRect(dRect, Paint()..color = AppColors.filtrate.withValues(alpha: 0.14 + hF * 0.10));
  }

  // ---- Kapillar-Lamellen (Blutseite) – Hohlfaser-Bündel ----
  const nF = 11;
  final fGap = bW / (nF + 1);
  for (int i = 1; i <= nF; i++) {
    final fx = fX + i * fGap;
    final lamellaRect = Rect.fromLTWH(fx - 2.6, fY + 14, 5.2, fH - 28);
    final clogged = clot > 0.15 && (i % 3 == 0 || i % 4 == 0);
    final baseColor = clogged
        ? Color.lerp(AppColors.blood, AppColors.clot, clot)!
        : AppColors.blood;
    final lamellaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          baseColor.withValues(alpha: 0.90),
          baseColor.withValues(alpha: 0.45),
          AppColors.bloodDark.withValues(alpha: 0.30),
        ],
      ).createShader(lamellaRect);
    canvas.drawRRect(RRect.fromRectAndRadius(lamellaRect, const Radius.circular(3)), lamellaPaint);

    // Verklottungs-Marker (dunkle Pfropfen in der Faser)
    if (clot > 0.1) {
      final nClots = (clot * 4).round();
      for (int c = 0; c < nClots; c++) {
        final cy = fY + 30 + (c * (fH - 60) / 4) + (i % 3) * 10;
        if (cy > fY + fH - 20) continue;
        canvas.drawCircle(Offset(fx, cy), 3.2 + clot * 2,
            Paint()..color = AppColors.clot.withValues(alpha: 0.55 + clot * 0.35));
      }
    }
  }

  // ---- Dialysat-/Filtrat-Kanäle (rechte Seite) ----
  if (st.hasDialysat) {
    const nD = 7;
    final dGap = dW / (nD + 1);
    for (int i = 1; i <= nD; i++) {
      final dx = mX + i * dGap;
      final chRect = Rect.fromLTWH(dx - 2, fY + 14, 4, fH - 28);
      canvas.drawRRect(
        RRect.fromRectAndRadius(chRect, const Radius.circular(2)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.dialysate.withValues(alpha: 0.55),
              AppColors.filtrate.withValues(alpha: 0.10 + hF * 0.25),
            ],
          ).createShader(chRect),
      );
    }
  }

  // ---- Membran (gestrichelte Mittellinie) ----
  final membranePaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.55)
    ..strokeWidth = 2;
  drawDashedPolyline(canvas, [Offset(mX, fY + 2), Offset(mX, fY + fH - 2)], membranePaint, dash: 7, gap: 5);

  // ---- Partikelanimation ----
  if (st.running) {
    _drawAnimParticles(canvas, st, hF, clot, perm);
  } else {
    _drawStaticParticles(canvas, hF);
  }

  // ---- Filterrahmen ----
  canvas.drawPath(roundedRectPath(fX, fY, fW, fH, 10),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6);

  // ---- Endkappen (4 Anschlüsse) ----
  final capPaint = Paint()..color = const Color(0xFF7C8BAA);
  canvas.drawPath(roundedRectPath(fX - 10, fY - 16, bW + 8, 16, 6), capPaint); // Bluteinlass oben-links
  canvas.drawPath(roundedRectPath(fX - 10, fY + fH, bW + 8, 16, 6), capPaint); // Blutauslass unten-links
  canvas.drawPath(roundedRectPath(mX + 2, fY - 16, dW + 8, 16, 6), capPaint); // Dialysat/Filtrat Auslass oben-rechts
  canvas.drawPath(roundedRectPath(mX + 2, fY + fH, dW + 8, 16, 6), capPaint); // Dialysat Einlass unten-rechts

  // ---- Flussrichtungs-Labels ----
  drawText(canvas, '↓ Blut  QB=${st.qb.round()} ml/min', Offset(fX + bW / 2, fY + 26),
      color: AppColors.blood, fontSize: 11, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  drawText(canvas, '← gereinigtes Blut', Offset(fX + bW / 2, fY + fH - 8),
      color: AppColors.bloodDark, fontSize: 10, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');

  if (st.hasDialysat) {
    drawText(canvas, '↑ Dialysat  QD=${st.qd.round()} ml/h', Offset(mX + dW / 2, fY + fH - 8),
        color: AppColors.dialysate, fontSize: 10, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
    drawText(canvas, '→ verbr. Dialysat + Filtrat', Offset(mX + dW / 2, fY + 26),
        color: AppColors.effluent, fontSize: 9, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  } else {
    drawText(canvas, '← Filtrat (UF)', Offset(mX + dW / 2, fY + 26),
        color: AppColors.filtrate, fontSize: 10, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  }

  // ---- Transport-Labels (Diffusion / Konvektion) ----
  final midY = fY + fH * 0.40;
  drawText(canvas, 'Diffusion', Offset(mX, midY - 14), color: AppColors.toxin, fontSize: 11, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  final diffLinePaint = Paint()..color = AppColors.toxin.withValues(alpha: 0.75)..strokeWidth = 1.6;
  drawDashedPolyline(canvas, [Offset(mX - 26, midY), Offset(mX + 26, midY)], diffLinePaint, dash: 3, gap: 3);
  drawArrowHead(canvas, Offset(mX + 26, midY), 0, AppColors.toxin.withValues(alpha: 0.8), size: 7);

  if (st.quf > 0) {
    final cY = fY + fH * 0.62;
    drawText(canvas, 'Konvektion', Offset(mX, cY - 14), color: AppColors.filtrate, fontSize: 11, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
    canvas.drawLine(Offset(mX - 18, cY), Offset(mX + 18, cY), Paint()..color = AppColors.filtrate.withValues(alpha: 0.8)..strokeWidth = 1.6);
    drawArrowHead(canvas, Offset(mX + 18, cY), 0, AppColors.filtrate.withValues(alpha: 0.8), size: 7);
  }

  // ---- Membran-Label (rotiert) ----
  canvas.save();
  canvas.translate(mX + 14, fY + fH / 2);
  canvas.rotate(-math.pi / 2);
  drawText(canvas, 'semipermeable Membran', Offset.zero, color: Colors.white.withValues(alpha: 0.65), fontSize: 10, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'sans-serif');
  canvas.restore();

  // ---- Konzentrationsgradient-Hinweis ----
  drawText(canvas, '▼ urämisch', Offset(fX - 8, fY + 20), color: AppColors.blood.withValues(alpha: 0.85), fontSize: 9, align: TextAlign.right, fontFamily: 'monospace');
  drawText(canvas, '▼ gereinigt', Offset(fX - 8, fY + fH - 6), color: AppColors.bloodDark.withValues(alpha: 0.75), fontSize: 9, align: TextAlign.right, fontFamily: 'monospace');
  drawText(canvas, 'Harnstoff: ${st.harnstoff.toStringAsFixed(0)}% → ${(st.harnstoff * (0.35 + (1 - perm) * 0.3 + clot * 0.3)).toStringAsFixed(0)}%',
      Offset(fX + fW / 2, fY + fH + 34), color: AppColors.toxin.withValues(alpha: 0.85), fontSize: 9, align: TextAlign.center, fontFamily: 'monospace');

  // ---- Permeabilität / Clotting Status-Badge unter Filter ----
  final badgeY = fY + fH + 50;
  drawText(canvas, 'Permeabilität: ${(perm * 100).toStringAsFixed(0)}%', Offset(fX + fW * 0.28, badgeY),
      color: perm < 0.4 ? AppColors.alert : AppColors.ok, fontSize: 9, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'monospace');
  drawText(canvas, 'Verklottung: ${(clot * 100).toStringAsFixed(0)}%', Offset(fX + fW * 0.72, badgeY),
      color: clot > 0.5 ? AppColors.alert : (clot > 0.2 ? AppColors.warn : AppColors.textDim), fontSize: 9, weight: FontWeight.bold, align: TextAlign.center, fontFamily: 'monospace');
}

void _drawStaticParticles(Canvas canvas, double hF) {
  const fX = ML.fX, fY = ML.fY;
  final bW = ML.mX - fX;
  for (int i = 0; i < 20; i++) {
    final px = fX + 10 + (i % 7) * (bW - 18) / 6;
    final py = fY + 30 + (i ~/ 7) * 70 + (i % 3) * 18;
    canvas.drawCircle(Offset(px, py), 2.6, Paint()..color = AppColors.toxin.withValues(alpha: 0.4));
  }
}

void _drawAnimParticles(Canvas canvas, CrrtState st, double hF, double clot, double perm) {
  const fX = ML.fX, fY = ML.fY, fW = ML.fW, fH = ML.fH;
  final mX = ML.mX;
  final bW = mX - fX, dW = fX + fW - mX;
  final t = st.machTick;
  final bloodSpeed = math.max(0.5, st.qb / 100) * (1 - clot * 0.6);
  final dialysateSpeed = math.max(0.3, st.qd / 150);

  // Blutzellen (rot, fließen abwärts) – langsamer bei Verklottung
  for (int i = 0; i < 24; i++) {
    final py = fY + ((t * bloodSpeed * 0.6 + i * (fH / 24)) % fH);
    canvas.drawCircle(
      Offset(fX + 10 + (i % 8) * (bW - 18) / 7, py),
      3.2,
      Paint()..color = AppColors.blood.withValues(alpha: 0.62),
    );
  }

  // Urämietoxine (gelb) – Konzentration nimmt entlang der Blutseite ab
  for (int i = 0; i < 34; i++) {
    final py = fY + ((t * bloodSpeed * 0.6 + i * (fH / 34)) % fH);
    final frac = (py - fY) / fH;
    final conc = hF * math.max(0.0, 1 - frac * 0.78) * perm;
    if (conc > 0.04) {
      canvas.drawCircle(
        Offset(fX + 8 + (i % 9) * (bW - 14) / 8, py),
        2.6,
        Paint()..color = AppColors.toxin.withValues(alpha: (conc * 0.9).clamp(0.0, 1.0)),
      );
    }
  }

  // Diffusion: Toxine überqueren Membran (nur mit Dialysat, gebremst durch Clotting/Permeabilität)
  final diffR = st.hasDialysat && st.qd > 0
      ? math.min(1.0, st.qd / 500) * hF * perm * (1 - clot * 0.85)
      : 0.0;
  if (diffR > 0) {
    for (int i = 0; i < 18; i++) {
      final ph = (t * 0.36 + i * 40) % 80;
      if (ph > 60) continue;
      final py = fY + 26 + (i * (fH - 52) / 18);
      final cx2 = mX - 30 + (ph / 60) * 60;
      final al = (0.88 * diffR * math.sin(ph / 60 * math.pi)).clamp(0.0, 1.0);
      if (al < 0.05) continue;
      canvas.drawCircle(Offset(cx2, py), 3.2, Paint()..color = AppColors.toxin.withValues(alpha: al));
    }
    // Abgeführte Toxine auf der Dialysatseite (nach oben zum Auslass)
    for (int i = 0; i < 16; i++) {
      final py = fY + fH - ((t * dialysateSpeed * 0.5 + i * (fH / 16)) % fH);
      canvas.drawCircle(
        Offset(mX + 10 + (i % 6) * (dW - 14) / 5, py),
        2.2,
        Paint()..color = AppColors.effluent.withValues(alpha: diffR * 0.6),
      );
    }
    // Dialysat (grün, aufwärts – Gegenstromprinzip)
    for (int i = 0; i < 22; i++) {
      final py = fY + fH - ((t * dialysateSpeed * 0.5 + i * (fH / 22)) % fH);
      canvas.drawCircle(
        Offset(mX + 8 + (i % 7) * (dW - 14) / 6, py),
        3.2,
        Paint()..color = AppColors.dialysate.withValues(alpha: 0.55),
      );
    }
  } else if (!st.hasDialysat) {
    // Reines Filtrat (lila) bewegt sich Richtung Auslass
    for (int i = 0; i < 18; i++) {
      final py = fY + fH - ((t * 0.6 + i * (fH / 18)) % fH);
      canvas.drawCircle(
        Offset(mX + 8 + (i % 6) * (dW - 14) / 5, py),
        3.0,
        Paint()..color = AppColors.filtrate.withValues(alpha: 0.5 * perm),
      );
    }
  }

  // Konvektion / UF (lila, quer über die Membran) – gebremst durch Clotting
  final ufR = (st.quf / 2000) * perm * (1 - clot * 0.7);
  for (int i = 0; i < 14; i++) {
    final ph2 = (t * 0.44 + i * 50) % 72;
    if (ph2 > 50) continue;
    final py = fY + 34 + (i * (fH - 68) / 14);
    final cx3 = mX - 20 + (ph2 / 50) * 40;
    final al2 = (ufR * 0.9 * math.sin(ph2 / 50 * math.pi)).clamp(0.0, 1.0);
    if (al2 < 0.04) continue;
    canvas.drawCircle(Offset(cx3, py), 3.6, Paint()..color = AppColors.filtrate.withValues(alpha: al2));
  }

  // Substituat (cyan) – nur sichtbar bei Prädilution direkt am Filtereingang
  if (st.qs > 0 && st.subMode == SubMode.pre) {
    final sR = st.qs / 3000;
    for (int i = 0; i < 8; i++) {
      final py = fY + 10 + i * 6 + ((t * 1.4) % 20);
      canvas.drawCircle(Offset(fX + 6, py), 2.2, Paint()..color = AppColors.substituate.withValues(alpha: sR * 0.7));
    }
  }

  // Heparin (orange, winzig, oberer Blutbereich)
  if (st.qSyringe > 0) {
    for (int i = 0; i < 5; i++) {
      final py = fY + 16 + i * 26 + ((t * 0.5) % 26);
      if (py > fY + fH) continue;
      canvas.drawCircle(Offset(fX + 6, py), 1.8, Paint()..color = AppColors.heparin.withValues(alpha: 0.55));
    }
  }
}
