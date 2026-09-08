import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Standard-Panel-Container mit Titel, wie in den drei Spalten des Lernprogramms.
class Panel extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets? padding;
  const Panel({super.key, required this.title, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderBlue),
      ),
      padding: padding ?? const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderBlue)),
              ),
              padding: const EdgeInsets.only(bottom: 6),
              width: double.infinity,
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
