import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_cupertino_example/main.dart';

void main() {
  testWidgets('the button is enabled only when the Form is valid', (
    tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    final button = find.widgetWithText(CupertinoButton, 'Sign up');

    expect(tester.widget<CupertinoButton>(button).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('email')), 'ada@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'Str0ngPassword');
    await tester.enterText(
      find.byKey(const Key('confirmation')),
      'Str0ngPassword',
    );
    await tester.tap(find.byKey(const Key('acceptedTerms')));
    await tester.pump();

    expect(tester.widget<CupertinoButton>(button).onPressed, isNotNull);

    await tester.tap(button);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Welcome aboard!'), findsOneWidget);
  });
}
