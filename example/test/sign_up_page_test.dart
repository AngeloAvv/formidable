import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/sign_up_page.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) =>
      tester.pumpWidget(const MaterialApp(home: SignUpPage()));

  testWidgets('submitting an empty form asks to fix the errors', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pump();

    expect(find.text('Please fix the errors above.'), findsOneWidget);
  });

  testWidgets('a valid username is welcomed', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'angelo');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pump();

    expect(find.text('Welcome, angelo!'), findsOneWidget);
  });
}
