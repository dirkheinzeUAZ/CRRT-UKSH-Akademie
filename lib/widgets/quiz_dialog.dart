import 'package:flutter/material.dart';
import '../data/quiz_data.dart';
import '../theme/app_colors.dart';

/// Zeigt das Alarm-Quiz als modalen Dialog: Ursachen & Maßnahmen ankreuzen,
/// dann Auswertung mit Punktestand und Erklärung.
Future<void> showQuizDialog(BuildContext context, String alarmKey) {
  final scenario = quizData[alarmKey]!;
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _QuizDialogContent(scenario: scenario),
  );
}

class _QuizDialogContent extends StatefulWidget {
  final QuizScenario scenario;
  const _QuizDialogContent({required this.scenario});

  @override
  State<_QuizDialogContent> createState() => _QuizDialogContentState();
}

class _QuizDialogContentState extends State<_QuizDialogContent> {
  final Set<int> causeSel = {};
  final Set<int> actionSel = {};
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.scenario;
    return Dialog(
      backgroundColor: const Color(0xFF0F1E30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.alert, width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFFC8181))),
                const SizedBox(height: 6),
                Text(q.desc, style: const TextStyle(fontSize: 13, color: Color(0xFFA0C0D8), height: 1.5)),
                const SizedBox(height: 16),
                _sectionHead('Mögliche Ursachen – alle zutreffenden auswählen:'),
                ..._buildOptions(q.causes, causeSel),
                const SizedBox(height: 12),
                _sectionHead('Richtige Maßnahmen – alle zutreffenden auswählen:'),
                ..._buildOptions(q.actions, actionSel),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => submitted = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC73652),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Auswertung anzeigen', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3050),
                        foregroundColor: const Color(0xFFA0C0D8),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Schließen'),
                    ),
                  ],
                ),
                if (submitted) _buildFeedback(q),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHead(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text.toUpperCase(),
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.accentBlue)),
      );

  List<Widget> _buildOptions(List<QuizOption> items, Set<int> selSet) {
    return List.generate(items.length, (i) {
      final item = items[i];
      final checked = selSet.contains(i);
      Color bg = const Color(0xFF0D1B2A);
      Color border = const Color(0xFF1E3A50);
      Color fg = const Color(0xFFC0D0E0);
      if (submitted) {
        if (item.correct) {
          bg = checked ? const Color(0xFF0A2A14) : const Color(0xFF2A0A0A);
          border = checked ? const Color(0xFF22C55E) : const Color(0xFFE94560);
          fg = checked ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5);
        } else if (checked) {
          bg = const Color(0xFF2A0A0A);
          border = const Color(0xFFE94560);
          fg = const Color(0xFFFCA5A5);
        }
      } else if (checked) {
        bg = const Color(0xFF0C2240);
        border = const Color(0xFF60A5FA);
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: InkWell(
          onTap: submitted
              ? null
              : () => setState(() {
                    if (checked) {
                      selSet.remove(i);
                    } else {
                      selSet.add(i);
                    }
                  }),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  checked ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 18,
                  color: submitted ? fg : (checked ? const Color(0xFF60A5FA) : AppColors.textDim),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item.text, style: TextStyle(fontSize: 12.5, color: fg))),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFeedback(QuizScenario q) {
    int causeScore = 0, causeTotal = 0, actionScore = 0, actionTotal = 0;
    for (int i = 0; i < q.causes.length; i++) {
      if (q.causes[i].correct) {
        causeTotal++;
        if (causeSel.contains(i)) causeScore++;
      } else if (causeSel.contains(i)) {
        // wrong extra selection, no score
      }
    }
    for (int i = 0; i < q.actions.length; i++) {
      if (q.actions[i].correct) {
        actionTotal++;
        if (actionSel.contains(i)) actionScore++;
      }
    }
    final total = causeScore + actionScore;
    final max = causeTotal + actionTotal;
    final pct = max > 0 ? (total / max * 100).round() : 0;
    final good = pct >= 70;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: good ? const Color(0xFF0A2A14) : const Color(0xFF2A0A14),
        border: Border.all(color: good ? const Color(0xFF22C55E) : AppColors.alert),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${good ? '✓' : '✗'} $pct% richtig ($total/$max Punkte)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: good ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5))),
          const SizedBox(height: 6),
          Text('Ursachen: $causeScore/$causeTotal   |   Maßnahmen: $actionScore/$actionTotal',
              style: TextStyle(fontSize: 12.5, color: good ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Erklärung: ', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: q.feedback),
              ],
            ),
            style: TextStyle(fontSize: 12.5, color: good ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5), height: 1.5),
          ),
        ],
      ),
    );
  }
}
