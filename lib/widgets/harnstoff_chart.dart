import 'package:flutter/material.dart';
import '../models/crrt_state.dart';
import '../theme/app_colors.dart';

/// Kleines Verlaufsdiagramm der relativen Plasma-Harnstoffkonzentration.
class HarnstoffChart extends StatelessWidget {
  final CrrtState state;
  const HarnstoffChart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.bgPanel2, borderRadius: BorderRadius.circular(6)),
      child: CustomPaint(painter: _ChartPainter(state)),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final CrrtState st;
  _ChartPainter(this.st);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (st.hHistory.length < 2) {
      final tp = TextPainter(
        text: const TextSpan(text: 'Startet bei Dialysebeginn', style: TextStyle(color: Color(0xFF4A6080), fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2));
      return;
    }
    final gridPaint = Paint()..color = AppColors.accentBlue.withValues(alpha: 0.2)..strokeWidth = 0.6;
    for (final v in [25, 50, 75, 100]) {
      final y = h - 4 - v * (h - 10) / 100;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final pts = st.hHistory;
    final maxP = pts.length < 60 ? pts.length : 60;
    final start = pts.length - maxP > 0 ? pts.length - maxP : 0;
    final path = Path();
    for (int i = 0; i < maxP; i++) {
      final v = pts[start + i];
      final x = 4 + i * (w - 8) / (maxP - 1 == 0 ? 1 : maxP - 1);
      final y = h - 4 - v * (h - 10) / 100;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, Paint()..color = AppColors.warn..strokeWidth = 2..style = PaintingStyle.stroke);

    final lv = pts.last;
    final lx = w - 4;
    final ly = h - 4 - lv * (h - 10) / 100;
    canvas.drawCircle(Offset(lx, ly), 4, Paint()..color = AppColors.warn);

    final tp = TextPainter(
      text: TextSpan(text: '${lv.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.warn, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(lx - tp.width, ly - 16));
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
