/// Geometrie-Konstanten für die Gerätezeichnung.
/// Referenzgröße: logisches Koordinatensystem 720 x 980 (Hochformat, Tablet-optimiert).
class ML {
  static const double W = 720;
  static const double H = 980;

  // Bildschirm (oben)
  static const double sX = 16, sY = 14, sW = 688, sH = 130;

  // Gehäusekörper
  static const double bX = 10, bY = 168, bW = 700, bH = 760;

  // Filter (zentral)
  static const double fX = 235, fY = 300, fW = 250, fH = 500;
  static double get mX => fX + fW / 2;

  // Pumpen – links: Blutpumpe (groß) + Heparin-Spritzenpumpe
  static const p6cx = 96.0, p6cy = 460.0, p6r = 62.0; // Blutpumpe
  static const p3x = 24.0, p3y = 330.0, p3w = 78.0, p3h = 26.0; // Heparin

  // Pumpen – rechts: Abfluss (oben), Dialysat (mitte), Substituat (unten)
  static const p1cx = 624.0, p1cy = 330.0, p1r = 30.0; // Abflusspumpe
  static const p4cx = 624.0, p4cy = 500.0, p4r = 30.0; // Dialysatpumpe
  static const p5cx = 624.0, p5cy = 660.0, p5r = 30.0; // Substitutionspumpe

  // Patientenanschlüsse (Rand links)
  static const patYArt = 400.0;
  static const patYVen = 820.0;

  // Ablaufbeutel (unten rechts)
  static const drainX = 660.0, drainY = 900.0;
}
