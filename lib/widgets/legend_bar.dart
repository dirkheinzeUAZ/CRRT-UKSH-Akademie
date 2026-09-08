import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Farblegende der Leitungen/Stoffe, analog zur Original-Web-App.
class LegendBar extends StatelessWidget {
  const LegendBar({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (AppColors.blood, 'Blut (arteriell)'),
      (AppColors.bloodDark, 'Blut (venös, gereinigt)'),
      (AppColors.dialysate, 'Dialysat'),
      (AppColors.toxin, 'Urämietoxine (Diffusion)'),
      (AppColors.filtrate, 'Filtrat (Konvektion)'),
      (AppColors.substituate, 'Substituat'),
      (AppColors.effluent, 'Effluat/Abfluss'),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items.map((it) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: it.$1, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(it.$2, style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
          ],
        );
      }).toList(),
    );
  }
}
