import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MonitorCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color valueColor;
  final Color borderColor;
  const MonitorCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor = AppColors.accentBlue,
    this.borderColor = AppColors.borderBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPanel2,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDim), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: valueColor),
              textAlign: TextAlign.center),
          Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.textDim)),
        ],
      ),
    );
  }
}
