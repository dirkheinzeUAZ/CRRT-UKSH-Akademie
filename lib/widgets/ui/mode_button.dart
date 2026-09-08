import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ModeButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const ModeButton({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 4),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? AppColors.accentBlue2 : AppColors.bgPanel2,
          foregroundColor: active ? Colors.white : AppColors.textDim,
          side: BorderSide(color: active ? AppColors.accentBlue2 : AppColors.borderBlue),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}
