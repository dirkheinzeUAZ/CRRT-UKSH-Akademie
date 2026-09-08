import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/control_panel.dart';
import '../widgets/monitor_panel.dart';
import '../widgets/machine_canvas.dart';
import '../widgets/legend_bar.dart';
import '../widgets/ui/panel.dart';
import 'package:provider/provider.dart';
import '../models/crrt_state.dart';

/// Hauptbildschirm der App. Responsives Layout:
///  - Breite Bildschirme (Tablet Landscape / Desktop): 3 Spalten (Steuerung | Gerät | Monitoring)
///  - Schmale Bildschirme (Tablet Portrait / Phone): gestapelt, mit Gerät zuerst
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1100;
                  final medium = constraints.maxWidth >= 760;

                  if (wide) {
                    return _WideLayout();
                  } else if (medium) {
                    return _MediumLayout();
                  } else {
                    return _NarrowLayout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: SingleChildScrollView(child: const ControlPanel()),
          ),
          const SizedBox(width: 10),
          Expanded(child: SingleChildScrollView(child: _MachineSection())),
          const SizedBox(width: 10),
          SizedBox(
            width: 340,
            child: SingleChildScrollView(child: const MonitorPanel()),
          ),
        ],
      ),
    );
  }
}

class _MediumLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _MachineSection(),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: const ControlPanel()),
              const SizedBox(width: 10),
              Expanded(child: const MonitorPanel()),
            ],
          ),
        ],
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _MachineSection(),
          const SizedBox(height: 10),
          const ControlPanel(),
          const SizedBox(height: 10),
          const MonitorPanel(),
        ],
      ),
    );
  }
}

class _MachineSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final st = context.watch<CrrtState>();
    return Panel(
      title: 'CRRT-Gerät (ITS) – Pumpen & Stofftransport',
      child: Column(
        children: [
          MachineCanvas(state: st),
          const SizedBox(height: 10),
          const LegendBar(),
        ],
      ),
    );
  }
}
