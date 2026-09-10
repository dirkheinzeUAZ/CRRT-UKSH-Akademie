import 'dart:async';
import 'package:flutter/foundation.dart';

enum CrrtMode { cvvhd, cvvhdf, cvvhf, scuf }

enum SubMode { pre, post }

String modeLabel(CrrtMode m) {
  switch (m) {
    case CrrtMode.cvvhd:
      return 'CVVHD';
    case CrrtMode.cvvhdf:
      return 'CVVHDF';
    case CrrtMode.cvvhf:
      return 'CVVHF';
    case CrrtMode.scuf:
      return 'SCUF';
  }
}

/// Zentraler App-State für die CRRT-Simulation.
/// Enthält alle Pumpen-Parameter, den Simulationstakt (1 Hz) sowie
/// abgeleitete klinische Kennwerte (Drücke, TMP, Clearance, Bilanz...).
class CrrtState extends ChangeNotifier {
  // ---------------- Grundzustand ----------------
  bool running = false;
  CrrtMode mode = CrrtMode.cvvhd;
  SubMode subMode = SubMode.post;

  // Pumpen (Einheiten wie am realen Gerät)
  double qb = 150; // Blutpumpe ml/min   [20-300]
  double qd = 1500; // Dialysatpumpe ml/h [0-3000]
  double quf = 500; // Netto-Flüssigkeitsentzug ml/h [0-2500]
  double qs = 0; // Substitutionspumpe ml/h [0-3000]

  // Filter-Eigenschaften – stufenlos einstellbar (Lehrzwecke)
  double filterPermeability = 1.0; // 0..1  (1 = optimal durchlässig)
  double filterClotting = 0.0; // 0..1  (0 = sauber, 1 = vollständig verklottet)

  // Simulationszeit / Verlauf
  int elapsedSec = 0;
  int filterRuntimeMin = 0;
  double ufAccum = 0; // erzielte UF gesamt (ml)
  double bilanz = 0; // kumulative Bilanz (ml)
  double harnstoff = 100; // relative Plasma-Harnstoffkonzentration (%)
  final List<double> hHistory = [100];

  // Animations-Ticker-Werte (werden von der Canvas-Ansicht pro Frame erhöht,
  // KEIN notifyListeners hier -> Performance)
  double machTick = 0;
  final Map<String, double> pumpAngle = {'p1': 0, 'p4': 0, 'p5': 0, 'p6': 0};

  Timer? _simTimer;
  int _autoAlarmCooldown = 0;
  String? activeAutoAlarmKey;
  final List<String> activeAlarms = [];

  // Callback, den die UI setzen kann, um automatisch ein Quiz zu öffnen
  void Function(String alarmKey)? onAutoAlarm;

  CrrtState() {
    _startSimTimer();
  }

  // ---------------- Abgeleitete Modus-Eigenschaften ----------------
  bool get hasDialysat => mode != CrrtMode.cvvhf && mode != CrrtMode.scuf;
  bool get hasSubstPump => mode == CrrtMode.cvvhdf || mode == CrrtMode.cvvhf;

  /// Abflusspumpe (Qeff) – automatisch berechnet, NICHT manuell einstellbar.
  /// Transportiert 100% des verbrauchten Dialysats + Netto-Entzug + 100% des
  /// Substituats. WICHTIG (klinisch korrekt): Das Substituat wird UNABHÄNGIG
  /// von Prä- oder Postdilution vollständig mitgerechnet – egal wo es einge-
  /// speist wird, muss dieses Volumen zusätzlich zum eingestellten Nettoentzug
  /// (QUF) durch die Abflusspumpe entfernt werden, sonst würde die Substitution
  /// die Bilanz verfälschen und der Nettoentzug nicht tatsächlich erreicht.
  double get qEff => qd + quf + qs;

  /// Filtrationsrate = konvektiver Fluss durch die Membran (Netto-UF + Substituat,
  /// unabhängig von Prä-/Postdilution – siehe Erläuterung bei qEff).
  double get filtrationRate => quf + qs;

  /// Kombinierter Verklottungsfaktor: manueller Regler + automatischer Laufzeit-Anteil.
  double get autoClotFactor => (filterRuntimeMin / (24 * 60)).clamp(0, 1);

  double get effectiveClot {
    final auto = autoClotFactor;
    final manual = filterClotting.clamp(0.0, 1.0);
    return (manual + auto * (1 - manual)).clamp(0.0, 1.0);
  }

  double get permeabilityFactor => filterPermeability.clamp(0.0, 1.0);

  // ---------------- Drücke / TMP / Clearance ----------------
  int get pArt => -(qb * 0.75 + 20).round();

  int get pVen =>
      (qb * 0.45 + 30 + quf * 0.02 + effectiveClot * 60).round();

  int get tmp => (quf * 0.06 +
          30 +
          qb * 0.1 +
          effectiveClot * 180 +
          (1 - permeabilityFactor) * 110)
      .round();

  int get clearance {
    if (!hasDialysat) return 0;
    final qdMin = qd / 60;
    final koa = 800 * permeabilityFactor * (1 - effectiveClot * 0.85);
    if (koa <= 0) return 0;
    final cl = (qb * qdMin * (koa / 1000)) / (qb + qdMin + koa / 1000);
    return cl.floor();
  }

  // ---------------- Steuerung ----------------
  void setMode(CrrtMode m) {
    mode = m;
    switch (m) {
      case CrrtMode.cvvhdf:
      case CrrtMode.cvvhf:
        if (qs == 0) qs = 1000;
        break;
      default:
        qs = 0;
    }
    if (m == CrrtMode.cvvhf || m == CrrtMode.scuf) {
      qd = 0;
    } else if (qd == 0) {
      qd = 1500;
    }
    if (m == CrrtMode.scuf) {
      if (qb > 150) qb = 80;
      if (quf > 500) quf = 100;
    }
    notifyListeners();
  }

  void setSubMode(SubMode m) {
    subMode = m;
    notifyListeners();
  }

  void setQb(double v) {
    qb = v;
    notifyListeners();
  }

  void setQd(double v) {
    qd = v;
    notifyListeners();
  }

  void setQuf(double v) {
    quf = v;
    notifyListeners();
  }

  void setQs(double v) {
    qs = v;
    notifyListeners();
  }

  void setPermeability(double v) {
    filterPermeability = v;
    notifyListeners();
  }

  void setClotting(double v) {
    filterClotting = v;
    notifyListeners();
  }

  void toggleRunning() {
    running = !running;
    notifyListeners();
  }

  void resetFilter() {
    filterRuntimeMin = 0;
    filterClotting = 0;
    harnstoff = 100;
    hHistory
      ..clear()
      ..add(100);
    notifyListeners();
  }

  // ---------------- Pumpen-Drehzahlen (relativ, 0..1) ----------------
  double get speedBlood => qb / 300;
  double get speedDialysat => qd / 3000;
  double get speedSubst => qs / 3000;

  /// Maximaler Einstellbereich des Netto-Entzugs (QUF) im aktuellen Modus –
  /// entspricht dem `max`-Wert des Sliders in control_panel.dart (500 im
  /// SCUF-Modus, sonst 2500 ml/h).
  double get _qufMaxForMode => mode == CrrtMode.scuf ? 500 : 2500;

  /// Drehgeschwindigkeit der Abflusspumpe (0..1, rein visuelle Skalierung).
  ///
  /// Zwei klinisch wichtige Eigenschaften müssen GLEICHZEITIG erfüllt sein:
  ///  1) Die Abflusspumpe darf NIE langsamer wirken als Dialysat- oder
  ///     Substitutionspumpe allein – sie muss ja beide Zuflüsse abführen.
  ///     → deshalb "floor" = max(speedDialysat, speedSubst) als Untergrenze.
  ///  2) Eine Erhöhung des Netto-Entzugs (QUF) MUSS sich sichtbar in einer
  ///     höheren Drehzahl niederschlagen (mehr Entzug = mehr Ultrafiltrat =
  ///     mehr Abfluss) – und zwar über den GESAMTEN Schieberegler-Bereich,
  ///     nicht nur am Anfang (sonst "hängt" die Anzeige bei höheren Werten).
  ///     → deshalb wird der verbleibende Spielraum bis 100% proportional zum
  ///        QUF-Anteil aufgefüllt: floor + (1 - floor) * qufFraction.
  ///
  /// Ergebnis: Bei QUF=0 ist die Abflussgeschwindigkeit EXAKT gleich der
  /// höheren der beiden Zufluss-Pumpen (korrekt, da dann nur deren Menge
  /// abgeführt werden muss). Steigt QUF, wächst die Geschwindigkeit stetig
  /// bis auf 100% beim Maximalwert des Reglers – unabhängig davon, wie hoch
  /// QD/QS bereits eingestellt sind.
  double get speedEffluent {
    if (qEff <= 0) return 0;
    final floorDialysat = qd / 3000;
    final floorSubst = qs / 3000;
    final floor = floorDialysat > floorSubst ? floorDialysat : floorSubst;
    final qufFraction =
        _qufMaxForMode > 0 ? (quf / _qufMaxForMode).clamp(0.0, 1.0) : 0.0;
    final raw = floor + (1 - floor) * qufFraction;
    return raw.clamp(0.05, 1.0);
  }

  // ---------------- Animation Tick (60fps, kein notifyListeners) ----------------
  void animTick(double dtSeconds) {
    if (!running) return;
    machTick += dtSeconds * 60;
    const d = 0.048 * 60; // Basis-Winkelgeschwindigkeit (rad/s Skalierung wie Original *60fps)
    pumpAngle['p6'] = (pumpAngle['p6']! + dtSeconds * d * speedBlood * 3) % 1000;
    pumpAngle['p1'] = (pumpAngle['p1']! + dtSeconds * d * speedEffluent * 4) % 1000;
    pumpAngle['p4'] = (pumpAngle['p4']! + dtSeconds * d * speedDialysat * 4) % 1000;
    pumpAngle['p5'] = (pumpAngle['p5']! + dtSeconds * d * speedSubst * 4) % 1000;
  }

  // ---------------- 1Hz Simulationslogik ----------------
  void _startSimTimer() {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!running) return;
    elapsedSec++;
    filterRuntimeMin++;

    final ufPerMin = quf / 60;
    final qsPerMin = (subMode == SubMode.post ? qs : 0) / 60;
    ufAccum += ufPerMin;
    bilanz -= (ufPerMin - qsPerMin);

    // Harnstoff-Clearance (vereinfachtes 1-Kompartiment-Modell)
    final kd = hasDialysat
        ? (qb < qd / 60 ? qb : qd / 60) *
            0.85 *
            permeabilityFactor *
            (1 - effectiveClot * 0.9)
        : quf / 60 * 0.5 * permeabilityFactor * (1 - effectiveClot * 0.9);
    const v = 35000.0;
    harnstoff = (harnstoff * (1 - kd / v)).clamp(5.0, 200.0);
    hHistory.add(double.parse(harnstoff.toStringAsFixed(1)));
    if (hHistory.length > 120) hHistory.removeAt(0);

    _checkAlarms();
    notifyListeners();
  }

  void _checkAlarms() {
    activeAlarms.clear();
    String? autoTrigger;
    final pa = pArt, pv = pVen, t = tmp;

    if (pa < -230) {
      activeAlarms.add('Zugangsdruck zu negativ ($pa mmHg)');
      autoTrigger = 'artNeg';
    }
    if (pa > -20) {
      activeAlarms.add('Zugangsdruck zu positiv ($pa mmHg)');
      autoTrigger ??= 'artPos';
    }
    if (pv > 200) {
      activeAlarms.add('Rückflußdruck zu hoch ($pv mmHg)');
      autoTrigger ??= 'venHigh';
    }
    if (pv < 20 && running) {
      activeAlarms.add('Rückflußdruck zu niedrig ($pv mmHg)');
      autoTrigger ??= 'venLow';
    }
    if (t > 300) {
      activeAlarms.add('TMP zu hoch ($t mmHg) – Clotting!');
      autoTrigger ??= 'tmpHigh';
    }
    if (mode == CrrtMode.cvvhdf && qs == 0) {
      activeAlarms.add('CVVHDF ohne Substituat!');
    }
    if (mode == CrrtMode.cvvhf && qs == 0) {
      activeAlarms.add('CVVHF ohne Substituat!');
    }
    if (bilanz < -3000) {
      activeAlarms.add('Flüssigkeitsentzug > 3 L kumulativ');
    }

    activeAutoAlarmKey = null;
    if (autoTrigger != null && _autoAlarmCooldown <= 0 && running) {
      activeAutoAlarmKey = autoTrigger;
      _autoAlarmCooldown = 30;
      onAutoAlarm?.call(autoTrigger);
    }
    if (_autoAlarmCooldown > 0) _autoAlarmCooldown--;
  }

  double get bilanzPerHour =>
      elapsedSec > 0 ? bilanz / (elapsedSec / 3600.0) : 0;

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }
}
