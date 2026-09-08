/// Enthält alle Alarm-Übungs-Szenarien (Ursachen & Maßnahmen) für das Quiz-System.
/// Direkt aus der ursprünglichen HTML-Simulation übernommen und leicht angepasst.
class QuizOption {
  final String text;
  final bool correct;
  const QuizOption(this.text, this.correct);
}

class QuizScenario {
  final String key;
  final String title;
  final String desc;
  final List<QuizOption> causes;
  final List<QuizOption> actions;
  final String feedback;

  const QuizScenario({
    required this.key,
    required this.title,
    required this.desc,
    required this.causes,
    required this.actions,
    required this.feedback,
  });
}

const Map<String, QuizScenario> quizData = {
  'artNeg': QuizScenario(
    key: 'artNeg',
    title: '🚨 ALARM A1 – Zugangsdruck zu negativ (< −200 mmHg)',
    desc:
        'Der arterielle Zugangsdruck fällt unter −200 mmHg. Das System kann nicht ausreichend Blut ansaugen. Das Gerät signalisiert einen Zugangsalarm.',
    causes: [
      QuizOption('Katheter liegt schlecht oder ist an der Gefäßwand verlegt', true),
      QuizOption('Blutfluss QB zu hoch für den gewählten Katheterlumen', true),
      QuizOption('Patient liegt auf dem Katheter (z.B. Oberschenkelkatheter)', true),
      QuizOption('Filtermembran ist verlegt (Clotting)', false),
      QuizOption('Dialysatpumpe zu langsam', false),
    ],
    actions: [
      QuizOption('QB (Blutfluss) schrittweise reduzieren', true),
      QuizOption('Katheterposition überprüfen, Patient umlagern', true),
      QuizOption('Arzt informieren – ggf. Katheterrevision oder Neuplatzierung', true),
      QuizOption('Antikoagulation sofort erhöhen', false),
      QuizOption('QUF erhöhen um Druck auszugleichen', false),
    ],
    feedback:
        'Ein zu negativer Zugangsdruck entsteht, wenn das Gerät nicht genügend Blut ansaugen kann – typischerweise durch Katheterprobleme oder zu hohe QB. Maßnahme: QB reduzieren und Katheterlage prüfen. Antikoagulation ist hier nicht die primäre Maßnahme!',
  ),
  'artPos': QuizScenario(
    key: 'artPos',
    title: '🚨 ALARM A2 – Zugangsdruck zu positiv (Obstruktion arterieller Schenkel)',
    desc:
        'Der arterielle Zugangsdruck nähert sich 0 mmHg oder wird positiv. Es liegt eine Obstruktion im arteriellen Zugangsschenkel vor.',
    causes: [
      QuizOption('Katheter arteriell thrombosiert oder mit Fibrin verlegt', true),
      QuizOption('Abknicken der arteriellen Leitung oder des Katheters', true),
      QuizOption('Klemme an der Leitung versehentlich geschlossen', true),
      QuizOption('QB zu niedrig eingestellt', false),
      QuizOption('TMP zu hoch', false),
    ],
    actions: [
      QuizOption('Leitungen auf Knicke und Klemmen prüfen und beheben', true),
      QuizOption('Gerät stoppen, arteriellen Katheter aspirieren (ärztlich)', true),
      QuizOption('QB erhöhen um den Druck zu normalisieren', false),
      QuizOption('Arzt informieren – Thrombolyse oder Katheterwechsel erwägen', true),
      QuizOption('Antikoagulation sofort reduzieren', false),
    ],
    feedback:
        'Ein zu positiver Zugangsdruck bedeutet eine Obstruktion, bevor das Blut das Gerät erreicht. Häufig sind Knicke oder Thromben die Ursache. QB erhöhen ist FALSCH – das würde den Druck weiter ansteigen lassen!',
  ),
  'venHigh': QuizScenario(
    key: 'venHigh',
    title: '🚨 ALARM A3 – Rückflußdruck zu hoch (> 200 mmHg)',
    desc:
        'Der venöse Rückflußdruck übersteigt 200 mmHg. Es besteht ein erhöhter Widerstand im Rückweg des Blutes zum Patienten.',
    causes: [
      QuizOption('Venöse Leitung abgeknickt oder komprimiert (Patient liegt drauf)', true),
      QuizOption('Venöse Kammer (Blasenfalle) teilweise geronnen', true),
      QuizOption('Katheter-Rücklaufschenkel thrombosiert', true),
      QuizOption('Zugangsdruck zu negativ', false),
      QuizOption('Dialysatfluss zu hoch', false),
    ],
    actions: [
      QuizOption('Venöse Leitungen auf Knicke, Klemmen, Kompression prüfen', true),
      QuizOption('Venöse Kammer und Luftdetektor inspizieren', true),
      QuizOption('Gerät stoppen, venöse Katheterlage überprüfen (Arzt)', true),
      QuizOption('UF-Rate erhöhen um Druck zu reduzieren', false),
      QuizOption('QB reduzieren als Sofortmaßnahme', true),
    ],
    feedback:
        'Ein hoher Rückflußdruck signalisiert einen Widerstand im venösen Rückweg. Priorität: Leitungen auf Knicke prüfen, QB reduzieren. UF erhöhen ist FALSCH und würde die Situation verschlechtern!',
  ),
  'venLow': QuizScenario(
    key: 'venLow',
    title: '🚨 ALARM A4 – Rückflußdruck zu niedrig (< 20 mmHg)',
    desc:
        'Der venöse Druck fällt unter 20 mmHg. Mögliche Leckage, Diskonnektion oder Lufteintritt. LEBENSGEFAHR bei Diskonnektion!',
    causes: [
      QuizOption('Diskonnektion der venösen Leitung (Blutungsrisiko!)', true),
      QuizOption('Luft im venösen Schenkel (Luftdetektor ausgelöst)', true),
      QuizOption('Venöser Katheter liegt nicht richtig (kein Gegendruck)', true),
      QuizOption('Filtermembran defekt', false),
      QuizOption('Zu hoher Blutfluss QB', false),
    ],
    actions: [
      QuizOption('⚠️ SOFORT stoppen! Venöse Leitung auf Diskonnektion prüfen – Blutungsgefahr!', true),
      QuizOption('Venöse Leitung auf Luftblasen prüfen', true),
      QuizOption('Arzt sofort informieren, Patient überwachen (Bewusstsein, Blutdruck)', true),
      QuizOption('QB erhöhen um Druck anzuheben', false),
      QuizOption('Keine Maßnahme – kurz abwarten', false),
    ],
    feedback:
        'Ein zu niedriger venöser Druck ist ein NOTFALL – besonders bei Diskonnektion droht Verblutung! Sofortiges Stoppen und Prüfung der venösen Leitung sind zwingend. QB erhöhen ist absolut KONTRAINDIZIERT!',
  ),
  'tmpHigh': QuizScenario(
    key: 'tmpHigh',
    title: '🚨 ALARM A5 – Transmembrandruck zu hoch (> 300 mmHg)',
    desc:
        'Der Transmembrandruck (TMP) übersteigt 300 mmHg. Die Filtermembran verliert ihre Permeabilität – Clotting! Filterwechsel wird notwendig.',
    causes: [
      QuizOption('Filtermembran durch Thromben verlegt (Clotting)', true),
      QuizOption('Unzureichende Antikoagulation (Heparin/Citrat zu niedrig dosiert)', true),
      QuizOption('Hoher Hämatokrit oder hyperviskoses Blut', true),
      QuizOption('Zugangsdruck zu hoch', false),
      QuizOption('Dialysatfluss zu niedrig', false),
    ],
    actions: [
      QuizOption('Antikoagulation überprüfen (ACT oder Anti-Xa messen)', true),
      QuizOption('Filter-Laufzeit und Filterleistung beurteilen → Filterwechsel planen', true),
      QuizOption('QB reduzieren um Druck auf Membran zu verringern', true),
      QuizOption('QD (Dialysatfluss) erhöhen um Filter freizuspülen', false),
      QuizOption('Antikoagulation stoppen', false),
    ],
    feedback:
        'Ein hoher TMP zeigt Clotting der Filtermembran an. Ursache: meist unzureichende Antikoagulation. Maßnahmen: Antikoagulation prüfen, QB reduzieren, Filter wechseln. QD erhöhen hilft bei Clotting nicht – die Ursache liegt im Blutkompartiment!',
  ),
};
