import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';
import 'support/preferences.dart';

/// Seam 2 for the switch.
void main() {
  late PreferencesForm form;

  Widget app(Widget Function(PreferencesForm form) field) =>
      preferencesApp(field, onCreated: (created) => form = created);

  group('FormidableMaterialSwitch', () {
    testWidgets('shows an Unset Field as off and the value once set', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableMaterialSwitch(field: form.notifications)),
      );
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      form.notifications.setValue(true);
      await tester.pump();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('sets the Field when tapped and marks it touched', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableMaterialSwitch(field: form.notifications)),
      );
      expect(form.notifications.state.touched, isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(form.notifications.value, isTrue);
      expect(form.notifications.state.touched, isTrue);
    });

    testWidgets('shows the Validation Message of a touched, invalid Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableMaterialSwitch(field: form.notifications)),
      );
      expect(find.text('This field is required.'), findsNothing);

      form.notifications.markAsTouched();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('with a title, tapping the title toggles the Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) => FormidableMaterialSwitch(
            field: form.notifications,
            title: const Text('Notify me'),
          ),
        ),
      );

      await tester.tap(find.text('Notify me'));
      await tester.pump();

      expect(form.notifications.value, isTrue);
    });
  });
}
