import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'machine_layout.dart';
import '../models/crrt_state.dart';
import 'painters/body_painter.dart';
import 'painters/tubing_painter.dart';
import 'painters/filter_painter.dart';
import 'painters/pump_painter.dart';
import 'painters/screen_painter.dart';
import 'painters/labels_painter.dart';
import 'painters/effluent_indicator_painter.dart';

/// Haupt-Widget, das das gesamte CRRT-Gerät zeichnet.
/// Nutzt einen AnimationController für flüssige 60fps-Animation
/// (Pumpenrotation, Partikelfluss), ohne bei jedem Frame den ganzen
/// App-State über notifyListeners() neu zu bauen.
class MachineCanvas extends StatefulWidget {
  final CrrtState state;
  const MachineCanvas({super.key, required this.state});

  @override
  State<MachineCanvas> createState() => _MachineCanvasState();
}

class _MachineCanvasState extends State<MachineCanvas> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.25) return;
    widget.state.animTick(dt);
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ML.W / ML.H,
      child: CustomPaint(
        painter: _MachinePainter(widget.state),
        size: Size.infinite,
      ),
    );
  }
}

class _MachinePainter extends CustomPainter {
  final CrrtState st;
  _MachinePainter(this.st);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / ML.W;
    canvas.save();
    canvas.scale(scale, scale);

    // Hintergrund
    canvas.drawRect(Rect.fromLTWH(0, 0, ML.W, ML.H), Paint()..color = const Color(0xFF0D1B2A));

    drawBody(canvas);
    drawTubing(canvas, st);
    drawFilter(canvas, st);

    drawPeristalticPump(
      canvas,
      center: const Offset(ML.p1cx, ML.p1cy),
      r: ML.p1r,
      color: const Color(0xFFF59E0B),
      angle: st.pumpAngle['p1']!,
      active: st.running && st.qEff > 0,
      label: '① Abflusspumpe',
    );
    drawEffluentIndicator(canvas, st);

    drawSyringePump(
      canvas,
      rect: const Rect.fromLTWH(ML.p3x, ML.p3y, ML.p3w, ML.p3h),
      color: const Color(0xFFF97316),
      active: st.running && st.qSyringe > 0,
      machTick: st.machTick,
    );

    if (st.hasDialysat) {
      drawPeristalticPump(
        canvas,
        center: const Offset(ML.p4cx, ML.p4cy),
        r: ML.p4r,
        color: const Color(0xFF22C55E),
        angle: st.pumpAngle['p4']!,
        active: st.running && st.qd > 0,
        label: '④ Dialysatpumpe',
      );
    }
    if (st.hasSubstPump) {
      drawPeristalticPump(
        canvas,
        center: const Offset(ML.p5cx, ML.p5cy),
        r: ML.p5r,
        color: const Color(0xFF06B6D4),
        angle: st.pumpAngle['p5']!,
        active: st.running && st.qs > 0,
        label: '⑤ Substitution',
      );
    }
    drawPeristalticPump(
      canvas,
      center: const Offset(ML.p6cx, ML.p6cy),
      r: ML.p6r,
      color: const Color(0xFFD41E2C),
      angle: st.pumpAngle['p6']!,
      active: st.running && st.qb > 0,
      label: '⑥ Blutpumpe',
    );

    drawScreen(canvas, st);
    drawLabels(canvas, st);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MachinePainter oldDelegate) => true;
}
