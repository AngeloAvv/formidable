import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';
import 'support/preferences.dart';

/// Seam 2 for the dropdown.
void main() {
  late PreferencesForm form;

  Widget app(Widget Function(PreferencesForm form) field) =>
      preferencesApp(field, onCreated: (created) => form = created);

  const items = [
    DropdownMenuItem(value: 'IT', child: Text('Italy')),
    DropdownMenuItem(value: 'FR', child: Text('France')),
  ];

  Widget dropdown(PreferencesForm form) => FormidableDropdown<String>(
    field: form.country,
    items: items,
    decoration: const InputDecoration(labelText: 'Country'),
    hint: const Text('Pick one'),
  );

  group('FormidableDropdown', () {
    testWidgets('shows the hint while the Field is Unset', (tester) async {
      await tester.pumpWidget(app(dropdown));

      expect(find.text('Pick one'), findsOneWidget);
      expect(find.text('Italy'), findsNothing);
    });

    testWidgets('shows the item of the value, also when set in code', (
      tester,
    ) async {
      await tester.pumpWidget(app(dropdown));

      form.country.setValue('FR');
      await tester.pump();

      expect(find.text('France'), findsOneWidget);
      expect(find.text('Pick one'), findsNothing);

      form.country.clear();
      await tester.pump();

      expect(find.text('Pick one'), findsOneWidget);
    });

    testWidgets('sets the Field and marks it touched when an item is picked', (
      tester,
    ) async {
      await tester.pumpWidget(app(dropdown));
      expect(form.country.state.touched, isFalse);

      await tester.tap(find.byType(DropdownButton<(String,)>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Italy').last);
      await tester.pumpAndSettle();

      expect(form.country.value, 'IT');
      expect(form.country.state.touched, isTrue);
    });

    testWidgets('shows the Validation Message of a touched, Unset Field', (
      tester,
    ) async {
      await tester.pumpWidget(app(dropdown));
      expect(find.text('This field is required.'), findsNothing);

      form.country.markAsTouched();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });
  });
}
