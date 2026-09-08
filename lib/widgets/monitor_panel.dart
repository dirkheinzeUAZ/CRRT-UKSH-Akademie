import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crrt_state.dart';
import '../theme/app_colors.dart';
import 'ui/panel.dart';
import 'ui/monitor_card.dart';
import 'ui/qeff_bar_row.dart';
import 'quiz_dialog.dart';
import 'harnstoff_chart.dart';

/// Rechtes Panel: Live-Messwerte, Bilanz, Alarm-Box, Alarm-Quiz-Übungen,
/// Abflusspumpen-Berechnung (Kommunikation der Pumpen), Pumpendrehzahlvergleich,
/// Harnstoff-Verlauf, Info-Tabs.
class MonitorPanel extends StatefulWidget {
  const MonitorPanel({super.key});

  @override
  State<MonitorPanel> createState() => _MonitorPanelState();
}

class _MonitorPanelState extends State<MonitorPanel> {
  int _tabIndex = 0;
  String? _lastAutoAlarm;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<CrrtState>();

    // Automatisches Öffnen des Quiz bei neuem Alarm (einmalig pro Trigger)
    if (st.activeAutoAlarmKey != null && st.activeAutoAlarmKey != _lastAutoAlarm) {
      _lastAutoAlarm = st.activeAutoAlarmKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showQuizDialog(context, st.activeAutoAlarmKey!);
      });
    }
    if (st.activeAutoAlarmKey == null) {
      _lastAutoAlarm = null;
    }

    final pArt = st.pArt, pVen = st.pVen, tmp = st.tmp;
    final bilanzH = st.bilanzPerHour;
    final pctB = (50 + bilanzH / 20).clamp(0.0, 100.0);

    return Panel(
      title: 'Monitoring & Alarme',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.55,
            children: [
              MonitorCard(
                label: 'Zugangsdruck', value: '$pArt', unit: 'mmHg',
                valueColor: (pArt < -200 || pArt > -20) ? AppColors.alert : AppColors.accentBlue,
                borderColor: (pArt < -200 || pArt > -20) ? AppColors.alert : AppColors.borderBlue,
              ),
              MonitorCard(
                label: 'Rückflußdruck', value: '$pVen', unit: 'mmHg',
                valueColor: (pVen > 200 || pVen < 20) ? AppColors.alert : AppColors.accentBlue,
                borderColor: (pVen > 200 || pVen < 20) ? AppColors.alert : AppColors.borderBlue,
              ),
              MonitorCard(
                label: 'TMP', value: '$tmp', unit: 'mmHg',
                valueColor: tmp > 300 ? AppColors.alert : (tmp > 200 ? AppColors.warn : AppColors.accentBlue),
                borderColor: tmp > 300 ? AppColors.alert : (tmp > 200 ? AppColors.warn : AppColors.borderBlue),
              ),
              MonitorCard(label: 'Effluent', value: '${st.qEff.round()}', unit: 'ml/h', valueColor: AppColors.effluent),
              MonitorCard(
                label: 'Filter-Laufzeit',
                value: '${(st.filterRuntimeMin ~/ 60).toString().padLeft(2, '0')}:${(st.filterRuntimeMin % 60).toString().padLeft(2, '0')}',
                unit: 'hh:mm',
              ),
              MonitorCard(label: 'Bilanz', value: '${st.bilanz.round()}', unit: 'ml kumulativ'),
              MonitorCard(label: 'UF erzielt', value: '${st.ufAccum.round()}', unit: 'ml gesamt', valueColor: AppColors.ok),
              MonitorCard(label: 'Clearance', value: st.clearance > 0 ? '${st.clearance}' : '--', unit: 'ml/min'),
            ],
          ),

          const SizedBox(height: 10),
          const Text('Flüssigkeitsbilanz (stündlich):', style: TextStyle(fontSize: 11, color: AppColors.textDim)),
          const SizedBox(height: 4),
          Container(
            height: 18,
            decoration: BoxDecoration(color: AppColors.bgPanel2, borderRadius: BorderRadius.circular(5)),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: pctB / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: bilanzH < -200
                          ? [const Color(0xFFE94560), const Color(0xFFC53030)]
                          : [AppColors.accentBlue, const Color(0xFF4299E1)]),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text('${bilanzH >= 0 ? '+' : ''}${bilanzH.toStringAsFixed(0)} ml/h',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: st.activeAlarms.isEmpty ? const Color(0xFF1B2D1B) : const Color(0xFF2D1B1B),
              border: Border.all(color: st.activeAlarms.isEmpty ? AppColors.ok : AppColors.alert),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              st.activeAlarms.isEmpty ? '● Alle Parameter im Normbereich' : st.activeAlarms.map((a) => '🚨 $a').join('\n'),
              style: TextStyle(fontSize: 11.5, color: st.activeAlarms.isEmpty ? AppColors.ok : const Color(0xFFFC8181)),
            ),
          ),

          const SizedBox(height: 10),
          _buildAlarmQuizBox(st),

          const SizedBox(height: 10),
          _buildQeffBox(st),

          const SizedBox(height: 10),
          _buildSpeedBox(st),

          const SizedBox(height: 12),
          const Divider(color: AppColors.borderBlue),
          const SizedBox(height: 8),
          HarnstoffChart(state: st),
          const SizedBox(height: 4),
          const Text('Harnstoffkonzentration Plasmaverlauf',
              style: TextStyle(fontSize: 10, color: AppColors.textDim), textAlign: TextAlign.center),

          const SizedBox(height: 10),
          _buildInfoTabs(),
        ],
      ),
    );
  }

  Widget _buildAlarmQuizBox(CrrtState st) {
    final entries = [
      ('A1', 'artNeg', 'Zugangsdruck zu negativ (< −200 mmHg)'),
      ('A2', 'artPos', 'Zugangsdruck zu positiv (Obstruktion)'),
      ('A3', 'venHigh', 'Rückflußdruck zu hoch (> 200 mmHg)'),
      ('A4', 'venLow', 'Rückflußdruck zu niedrig (< 20 mmHg)'),
      ('A5', 'tmpHigh', 'Transmembrandruck zu hoch (> 300 mmHg)'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1620),
        border: Border.all(color: const Color(0xFF1E4060)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠ Alarm-Übungen (Quiz)', style: TextStyle(fontSize: 12, color: AppColors.warn, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Klicken um ein Alarm-Szenario zu analysieren und die richtige Reaktion zu üben:',
              style: TextStyle(fontSize: 10.5, color: AppColors.textDim)),
          const SizedBox(height: 8),
          ...entries.map((e) {
            final active = st.activeAutoAlarmKey == e.$2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: InkWell(
                onTap: () => showQuizDialog(context, e.$2),
                borderRadius: BorderRadius.circular(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF2D0A0A) : const Color(0xFF1A0F0F),
                    border: Border.all(color: active ? AppColors.alert : const Color(0xFF7F1D1D), width: active ? 2 : 1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF7F1D1D), borderRadius: BorderRadius.circular(4)),
                        child: Text(e.$1, style: const TextStyle(fontSize: 10, color: Color(0xFFFCA5A5))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.$3, style: const TextStyle(fontSize: 11.5, color: Color(0xFFFCA5A5)))),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQeffBox(CrrtState st) {
    const maxRef = 6000.0;
    final showQS = st.qs > 0 && st.subMode == SubMode.pre;
    final qdLabel = st.hasDialysat ? 'QD + ' : '';
    final qsNote = showQS ? '' : (st.qs > 0 ? ' (Post→Patient)' : '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1620),
        border: Border.all(color: const Color(0xFF1E4060)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('① Abflusspumpe – Automatische Berechnung', style: TextStyle(fontSize: 12, color: AppColors.warn, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 10.5, color: AppColors.textDim),
              children: [
                TextSpan(text: 'Die Abflusspumpe transportiert '),
                TextSpan(text: '100%', style: TextStyle(color: AppColors.warn, fontWeight: FontWeight.bold)),
                TextSpan(text: ' des Dialysats + den eingestellten Flüssigkeitsentzug in den Ablaufbeutel.'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (st.hasDialysat)
            QeffBarRow(name: 'Dialysat', color: AppColors.dialysate, fraction: st.qd / maxRef, valueText: '${st.qd.round()} ml/h', nameColor: AppColors.dialysate),
          QeffBarRow(name: '+ Entzug', color: const Color(0xFFE94560), fraction: st.quf / maxRef, valueText: '${st.quf.round()} ml/h', nameColor: const Color(0xFFE94560)),
          if (showQS)
            QeffBarRow(name: '+ Substituat', color: AppColors.substituate, fraction: st.qs / maxRef, valueText: '${st.qs.round()} ml/h', nameColor: AppColors.substituate),
          const Divider(height: 12, color: Color(0xFF1E4060)),
          QeffBarRow(name: '= Abflusspumpe', color: AppColors.warn, fraction: st.qEff / maxRef, valueText: '${st.qEff.round()} ml/h', nameColor: AppColors.warn),
          const SizedBox(height: 6),
          Text(
            'Qeff = ${qdLabel}QUF${showQS ? ' + QS(Prä)' : qsNote}\nQeff = ${st.hasDialysat ? '${st.qd.round()} + ' : ''}${st.quf.round()}${showQS ? ' + ${st.qs.round()}' : ''} = ${st.qEff.round()} ml/h',
            style: const TextStyle(fontSize: 10.5, color: AppColors.textDim, fontFamily: 'monospace', height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedBox(CrrtState st) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1620),
        border: Border.all(color: const Color(0xFF1E4060)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pumpendrehzahlen (relativ zur Maximalleistung)', style: TextStyle(fontSize: 12, color: AppColors.warn, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          QeffBarRow(name: '⑥ Blutpumpe', color: AppColors.blood, fraction: st.speedBlood, valueText: '${(st.speedBlood * 100).round()}%', nameColor: AppColors.blood),
          if (st.hasDialysat)
            QeffBarRow(name: '④ Dialysatpumpe', color: AppColors.dialysate, fraction: st.speedDialysat, valueText: '${(st.speedDialysat * 100).round()}%', nameColor: AppColors.dialysate),
          if (st.hasSubstPump)
            QeffBarRow(name: '⑤ Substitution', color: AppColors.substituate, fraction: st.speedSubst, valueText: '${(st.speedSubst * 100).round()}%', nameColor: AppColors.substituate),
          QeffBarRow(name: '① Abflusspumpe', color: AppColors.warn, fraction: st.speedEffluent, valueText: '${(st.speedEffluent * 100).round()}%', nameColor: AppColors.warn),
          const SizedBox(height: 4),
          const Text('■ QD-Anteil   ■ Entzug-Anteil  →  Abflusspumpe dreht schneller wenn QD↑ oder Entzug↑',
              style: TextStyle(fontSize: 9.5, color: AppColors.textDim)),
        ],
      ),
    );
  }

  Widget _buildInfoTabs() {
    final tabs = ['Info', 'Physik', 'Klinik'];
    final content = [
      const [
        _InfoLine('Zugangsdruck:', 'Normal −80 bis −150 mmHg. Abhängig von QB und Katheterlage.'),
        _InfoLine('Rückflußdruck:', 'Normal 50–150 mmHg. Erhöhung = Widerstand im venösen Schenkel.'),
        _InfoLine('TMP:', 'Normal <150 mmHg. Anstieg = Filtermembran verlegt (Clotting).'),
      ],
      const [
        _InfoLine('TMP = P_Blut − P_Filtrat', 'treibt Ultrafiltration.'),
        _InfoLine('TMP↑ bei:', 'QB↑, QUF↑, Clotting, hohem Hämatokrit.'),
      ],
      const [
        _InfoLine('Filterlaufzeit:', 'Ziel ≥ 24 h (Heparin) bzw. ≥ 72 h (Citrat).'),
        _InfoLine('Dosis:', 'Effluent ≥ 20 ml/kg/h laut KDIGO-Leitlinie ITS.'),
        _InfoLine('Bilanz:', 'Max. −100 bis −200 ml/h auf der ITS – engmaschig kontrollieren!'),
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
