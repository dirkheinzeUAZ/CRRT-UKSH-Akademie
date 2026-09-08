import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Kopfzeile der App mit Logo, Titel und "ITS-Lernmodus"-Badge.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F3460), Color(0xFF16213E)]),
        border: const Border(bottom: BorderSide(color: AppColors.accentBlue2, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentBlue2, width: 1.4),
            ),
            child: const Icon(Icons.water_drop, color: AppColors.accentBlue, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('CRRT-Simulation – Intensivstation',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.accentBlue)),
                Text('Interaktive Lernumgebung – Fachweiterbildung Nephrologie & Dialyse / Intensivpflege',
                    style: TextStyle(fontSize: 10.5, color: AppColors.textDim)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentBlue2, borderRadius: BorderRadius.circular(12)),
            child: const Text('ITS-LERNMODUS', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
