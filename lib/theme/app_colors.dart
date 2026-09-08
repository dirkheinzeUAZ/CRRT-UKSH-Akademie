import 'package:flutter/material.dart';

/// Zentrale Farbdefinitionen für die CRRT-Simulation.
/// App-Grundton: Blautöne (wie multiFiltrate-Oberfläche).
/// Medizinische Signalfarben für Leitungen bleiben klinisch korrekt/eindeutig.
class AppColors {
  AppColors._();

  // ---- App-Grundfarben (Blautöne) ----
  static const bgDark      = Color(0xFF0B1526);
  static const bgPanel     = Color(0xFF122238);
  static const bgPanel2    = Color(0xFF0D1B2E);
  static const borderBlue  = Color(0xFF1B3A5C);
  static const accentBlue  = Color(0xFF4FA8E8);
  static const accentBlue2 = Color(0xFF2B6CB0);
  static const textMain    = Color(0xFFE4ECF7);
  static const textDim     = Color(0xFF8FA6C2);
  static const ok          = Color(0xFF3DDC84);
  static const warn        = Color(0xFFFBBF24);
  static const alert       = Color(0xFFEF4444);

  // ---- Gerätegehäuse (multiFiltrate-Look: helles Gehäuse) ----
  static const housing      = Color(0xFFE9EDF3);
  static const housingLight = Color(0xFFF7FAFD);
  static const housingDark  = Color(0xFFC3CCDA);
  static const housingPanel = Color(0xFFFFFFFF);
  static const screenBezel  = Color(0xFF14202E);

  // ---- Leitungs- / Stoff-Farben (klinisch, siehe Vorgabe) ----
  static const blood        = Color(0xFFD41E2C); // Blut (arteriell & durch Filter)
  static const bloodDark    = Color(0xFF9E1420); // Blut, venös/gereinigt (dunkler Rotton)
  static const arterialCap  = Color(0xFFDC2626); // Anschlussstopfen arteriell
  static const venousCap    = Color(0xFF2563EB); // Anschlussstopfen venös
  static const dialysate    = Color(0xFF22C55E); // Dialysat = grün
  static const filtrate     = Color(0xFFA855F7); // Filtrat = lila
  static const effluent     = Color(0xFFEAB308); // Effluat/Abfluss = gelb
  static const substituate  = Color(0xFF06B6D4); // Substituat = cyan/türkis
  static const toxin        = Color(0xFFFBBF24); // Urämietoxine (Diffusion)
  static const clot         = Color(0xFF7C2D12); // Verklottung / Thrombus

  static Color pumpColor(String key) {
    switch (key) {
      case 'blood': return blood;
      case 'dialysate': return dialysate;
      case 'filtrate': return filtrate;
      case 'effluent': return effluent;
      case 'substituate': return substituate;
      default: return accentBlue;
    }
  }
}
