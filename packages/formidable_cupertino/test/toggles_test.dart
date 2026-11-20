import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';

import 'support/harness.dart';
import 'support/profile.dart';

/// Seam 2: the switch and the checkbox. They can't take focus, so the Field
/// becomes touched on the first interaction.
void main() {
  late ProfileForm form;

  Future<void> pump(WidgetTester tester, Widget Function(ProfileForm) field) =>
      tester.pumpWidget(
        profileApp(
          field,
          create: () => ProfileForm(username: 'angelo', terms: false),
          onForm: (f) => form = f,
        ),
      );

  group('FormidableCupertinoSwitch', () {
    testWidgets('shows the value and follows the Field', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoSwitch(field: form.terms),
      );
      expect(
        tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).value,
        isFalse,
      );

      form.terms.setValue(true);
      await tester.pump();

      expect(
        tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).value,
        isTrue,
      );
    });

    testWidgets('a tap sets the Field and touches it', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoSwitch(field: form.terms),
      );
      expect(form.terms.state.touched, isFalse);

      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();

      expect(form.terms.value, isTrue);
      expect(form.terms.state.touched, isTrue);
    });

    testWidgets('shows the error once touched', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoSwitch(field: form.terms),
      );
      expect(find.text('Must be on.'), findsNothing);

      await tester.tap(find.byType(CupertinoSwitch)); // on
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoSwitch)); // off again
      await tester.pumpAndSettle();

      expect(find.text('Must be on.'), findsOneWidget);
    });

    testWidgets('two widgets on the same Field stay in sync', (tester) async {
      await pump(
        tester,
        (form) => Column(
          children: [
            FormidableCupertinoSwitch(field: form.terms),
            FormidableCupertinoCheckbox(field: form.terms),
          ],
        ),
      );

      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();

      expect(
        tester.widget<CupertinoCheckbox>(find.byType(CupertinoCheckbox)).value,
        isTrue,
      );
    });
  });

  group('FormidableCupertinoCheckbox', () {
    testWidgets('a tap sets the Field and touches it', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoCheckbox(field: form.terms),
      );

      await tester.tap(find.byType(CupertinoCheckbox));
      await tester.pumpAndSettle();

      expect(form.terms.value, isTrue);
      expect(form.terms.state.touched, isTrue);
    });
  });
}
