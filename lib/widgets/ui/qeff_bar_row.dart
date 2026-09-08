import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Zeigt eine Zeile in der "Abflusspumpen-Berechnung"-Box: Name, Balken, Wert.
class QeffBarRow extends StatelessWidget {
  final String name;
  final Color color;
  final double fraction; // 0..1
  final String valueText;
  final Color nameColor;

  const QeffBarRow({
    super.key,
    required this.name,
    required this.color,
    required this.fraction,
    required this.valueText,
    this.nameColor = AppColors.textDim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(name, textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: nameColor)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(color: AppColors.bgPanel2, borderRadius: BorderRadius.circular(3)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 62,
            child: Text(valueText, style: TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}
