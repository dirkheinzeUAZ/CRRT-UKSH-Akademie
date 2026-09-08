import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Ein beschrifteter Schieberegler mit farbigem "Pumpen-Indikator"-Punkt,
/// analog zur ursprünglichen Web-Oberfläche.
class ParamSlider extends StatelessWidget {
  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final Color accent;
  final ValueChanged<double> onChanged;
  final bool disabled;
  final Widget? indicator;

  const ParamSlider({
    super.key,
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.accent,
    required this.onChanged,
    this.divisions,
    this.disabled = false,
    this.indicator,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontSize: 12.5, color: accent, fontWeight: FontWeight.w600)),
                Text(valueText,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.ok, fontWeight: FontWeight.bold)),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: accent,
                inactiveTrackColor: AppColors.borderBlue,
                thumbColor: accent,
                overlayColor: accent.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: disabled ? null : onChanged,
              ),
            ),
            if (indicator != null) indicator!,
          ],
        ),
      ),
    );
  }
}
