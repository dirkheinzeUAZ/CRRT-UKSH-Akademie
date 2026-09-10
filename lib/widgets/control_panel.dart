import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crrt_state.dart';
import '../theme/app_colors.dart';
import 'ui/panel.dart';
import 'ui/param_slider.dart';
import 'ui/mode_button.dart';

/// Linkes Panel: Modus-Auswahl, alle Pumpen-Regler, Filter-Regler (Permeabilität/Verklottung),
/// Prä-/Postdilution-Umschalter, Start/Pause-Button, Info-Tabs.
class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<CrrtState>();

    return Panel(
      title: 'Parametersteuerung',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CRRT-Modus:', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
          const SizedBox(height: 6),
          Wrap(
            children: [
              ModeButton(label: 'CVVHD', active: st.mode == CrrtMode.cvvhd, onTap: () => st.setMode(CrrtMode.cvvhd)),
              ModeButton(label: 'CVVHDF', active: st.mode == CrrtMode.cvvhdf, onTap: () => st.setMode(CrrtMode.cvvhdf)),
              ModeButton(label: 'CVVHF', active: st.mode == CrrtMode.cvvhf, onTap: () => st.setMode(CrrtMode.cvvhf)),
              ModeButton(label: 'SCUF', active: st.mode == CrrtMode.scuf, onTap: () => st.setMode(CrrtMode.scuf)),
            ],
          ),
          const Divider(height: 20, color: AppColors.borderBlue),

          // ⑥ Blutpumpe
          ParamSlider(
            label: '⑥ Blutpumpe (QB)',
            valueText: '${st.qb.round()} ml/min',
            value: st.qb,
            min: 20,
            max: st.mode == CrrtMode.scuf ? 150 : 300,
            accent: AppColors.blood,
            onChanged: st.setQb,
            indicator: _pumpIndicatorRow(AppColors.blood, 'Arterieller Kreislauf'),
          ),

          const Divider(height: 16, color: AppColors.borderBlue),

          // ④ Dialysatpumpe
          ParamSlider(
            label: '④ Dialysatpumpe (QD)',
            valueText: '${st.qd.round()} ml/h',
            value: st.qd,
            min: 0,
            max: 3000,
            divisions: 60,
            accent: AppColors.dialysate,
            disabled: !st.hasDialysat,
            onChanged: st.setQd,
          ),

          // ⑤ Substitutionspumpe
          ParamSlider(
            label: '⑤ Substitutionspumpe (QS)',
            valueText: '${st.qs.round()} ml/h',
            value: st.qs,
            min: 0,
            max: 3000,
            divisions: 60,
            accent: AppColors.substituate,
            disabled: !st.hasSubstPump,
            onChanged: st.setQs,
            indicator: st.hasSubstPump
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: ModeButton(
                            label: 'Post-Filter',
                            active: st.subMode == SubMode.post,
                            onTap: () => st.setSubMode(SubMode.post),
                          ),
                        ),
                        Expanded(
                          child: ModeButton(
                            label: 'Prä-Filter',
                            active: st.subMode == SubMode.pre,
                            onTap: () => st.setSubMode(SubMode.pre),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          const Divider(height: 16, color: AppColors.borderBlue),

          // Netto-Entzug (UF)
          ParamSlider(
            label: 'Netto-Entzug (QUF)',
            valueText: '${st.quf.round()} ml/h',
            value: st.quf,
            min: 0,
            max: st.mode == CrrtMode.scuf ? 500 : 2500,
            divisions: 50,
            accent: AppColors.textMain,
            onChanged: st.setQuf,
            indicator: _pumpIndicatorRow(AppColors.warn, 'Nettoflüssigkeitsentzug'),
          ),

          // ① Abflusspumpe – automatisch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.bgPanel2,
              border: Border.all(color: const Color(0xFF4A6020)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('① Abflusspumpe (Qeff)', style: TextStyle(fontSize: 12.5, color: AppColors.effluent, fontWeight: FontWeight.w600)),
                    Text('${st.qEff.round()} ml/h', style: const TextStyle(fontSize: 12.5, color: AppColors.warn, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('⚙ Automatisch berechnet – nicht manuell einstellbar',
                    style: TextStyle(fontSize: 10, color: AppColors.warn)),
                Text(
                  'Qeff = ${st.hasDialysat ? 'QD + ' : ''}QUF${st.qs > 0 ? ' + QS' : ''} = ${st.qEff.round()} ml/h',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.warn, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: AppColors.borderBlue),

          // ---- FILTER-EIGENSCHAFTEN (Lernübung) ----
          const Text('Filter-Eigenschaften (Übung):', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
          const SizedBox(height: 6),
          ParamSlider(
            label: 'Membran-Permeabilität',
            valueText: '${(st.filterPermeability * 100).round()}%',
            value: st.filterPermeability,
            min: 0,
            max: 1,
            divisions: 100,
            accent: AppColors.ok,
            onChanged: st.setPermeability,
          ),
          ParamSlider(
            label: 'Verklottung (manuell)',
            valueText: '${(st.filterClotting * 100).round()}%',
            value: st.filterClotting,
            min: 0,
            max: 1,
            divisions: 100,
            accent: AppColors.alert,
            onChanged: st.setClotting,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: st.resetFilter,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Filter zurücksetzen', style: TextStyle(fontSize: 11.5, color: AppColors.accentBlue)),
            ),
          ),
          const Divider(height: 16, color: AppColors.borderBlue),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: st.toggleRunning,
              style: ElevatedButton.styleFrom(
                backgroundColor: st.running ? const Color(0xFF2F855A) : const Color(0xFFC73652),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              ),
              child: Text(
                st.running ? '⏸ CRRT PAUSIEREN' : (st.filterRuntimeMin > 0 ? '▶ CRRT FORTSETZEN' : '▶ CRRT STARTEN'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const Divider(height: 20, color: AppColors.borderBlue),

          _buildInfoTabs(),
        ],
      ),
    );
  }

  Widget _pumpIndicatorRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          _PumpDot(color: color),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 10.5, color: AppColors.textDim)),
        ],
      ),
    );
  }

  Widget _buildInfoTabs() {
    final tabs = ['Info', 'Physik', 'Klinik'];
    final content = [
      const [
        _InfoLine('CVVHD:', 'Kontinuierliche vv-Hämodialyse. Nur Diffusion, kein Substituat.'),
        _InfoLine('CVVHDF:', 'Diffusion + Konvektion. Substitutionspumpe nötig.'),
        _InfoLine('CVVHF:', 'Nur Konvektion (Hämofiltration). Kein Dialysat.'),
        _InfoLine('SCUF:', 'Langsamer reiner Flüssigkeitsentzug. Niedriger QB.'),
      ],
      const [
        _InfoLine('Diffusion:', 'J = D·A·ΔC/d – Konzentrationsgradient treibt Toxine durch Membran.'),
        _InfoLine('Konvektion:', 'TMP treibt Wasser + mittelmolekulare Toxine durch Membran.'),
        _InfoLine('Dosis:', 'Effluent ≥ 20–25 ml/kg/h – KDIGO-Empfehlung ITS.'),
      ],
      const [
        _InfoLine('TMP-Alarm:', '>300 mmHg → Clottinggefahr → Filter wechseln!'),
        _InfoLine('Filterlaufzeit:', 'Ziel ≥ 24 h. Antikoagulation (Heparin/Citrat) entscheidend.'),
        _InfoLine('Bilanz:', 'Stündliche Überwachung! Zuviel Entzug → Hypovolämie → Schock.'),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(tabs.length, (i) {
            final active = _tabIndex == i;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => setState(() => _tabIndex = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accentBlue2 : AppColors.bgPanel2,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(tabs[i], style: TextStyle(fontSize: 11.5, color: active ? Colors.white : AppColors.textDim)),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        ...content[_tabIndex],
      ],
    );
  }
}

class _PumpDot extends StatefulWidget {
  final Color color;
  const _PumpDot({required this.color});
  @override
  State<_PumpDot> createState() => _PumpDotState();
}

class _PumpDotState extends State<_PumpDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.4).animate(_c),
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String title;
  final String text;
  const _InfoLine(this.title, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11.5, color: AppColors.textDim, height: 1.4),
          children: [
            TextSpan(text: '$title ', style: const TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold)),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
