import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/preferences.dart';
import 'support/harness.dart';

/// Seam 2 for the checkbox: mount a generated Form Scope and drive the widget
/// like a user would.
void main() {
  late PreferencesForm form;

  Widget app(Widget Function(PreferencesForm form) field) =>
      preferencesApp(field, onCreated: (created) => form = created);

  group('FormidableMaterialCheckbox', () {
    testWidgets('shows an Unset Field as unchecked and the value once set', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableMaterialCheckbox(field: form.terms)),
      );
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

      form.terms.setValue(true);
      await tester.pump();

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    });

    testWidgets('sets the Field when tapped', (tester) async {
      await tester.pumpWidget(
        app((form) => FormidableMaterialCheckbox(field: form.terms)),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(form.terms.isSet, isTrue);
      expect(form.terms.value, isTrue);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(form.terms.value, isFalse);
    });

    testWidgets('marks the Field touched on the first interaction', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableMaterialCheckbox(field: form.terms)),
      );
      expect(form.terms.state.touched, isFalse);
      expect(find.text('This field is required.'), findsNothing);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(form.terms.state.touched, isTrue);
    });

    testWidgets('shows the Validation Message of a touched, invalid Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableMaterialCheckbox(field: form.terms)),
      );

      form.terms.markAsTouched();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('with a title, tapping the title toggles the Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) => FormidableMaterialCheckbox(
            field: form.terms,
            title: const Text('Terms'),
          ),
        ),
      );

      await tester.tap(find.text('Terms'));
      await tester.pump();

      expect(form.terms.value, isTrue);
    });

    testWidgets('a tristate checkbox can choose null, which is a value', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) =>
              FormidableMaterialCheckbox(field: form.beta, tristate: true),
        ),
      );

      await tester.tap(find.byType(Checkbox)); // unset shows as false -> true
      await tester.pump();
      await tester.tap(find.byType(Checkbox)); // true -> null
      await tester.pump();

      expect(form.beta.isSet, isTrue);
      expect(form.beta.value, isNull);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isNull);
    });
  });
}
