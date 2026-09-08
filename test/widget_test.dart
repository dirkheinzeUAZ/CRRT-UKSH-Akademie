import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('CRRT Trainer app starts and shows header', (WidgetTester tester) async {
    await tester.pumpWidget(const CrrtTrainerApp());
    await tester.pump();

    expect(find.text('CRRT-Simulation – Intensivstation'), findsOneWidget);
  });
}
