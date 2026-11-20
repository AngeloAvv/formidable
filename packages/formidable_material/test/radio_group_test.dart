import 'dart:ui' show CheckedState;

import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';
import 'support/preferences.dart';

/// Seam 2 for the radio group, including the option that stands for null
/// (ADR-0003: Unset is not null).
void main() {
  late PreferencesForm form;

  Widget app(Widget Function(PreferencesForm form) field) =>
      preferencesApp(field, onCreated: (created) => form = created);

  const plans = [
    FormidableRadioOption(value: Plan.free, title: Text('Free')),
    FormidableRadioOption(value: Plan.plus, title: Text('Plus')),
    FormidableRadioOption(value: Plan.pro, title: Text('Pro')),
  ];

  // Whether the radio next to [label] is shown as selected.
  bool isSelected(WidgetTester tester, String label) =>
      tester
          .getSemantics(find.widgetWithText(ListTile, label))
          .getSemanticsData()
          .flagsCollection
          .isChecked ==
      CheckedState.isTrue;

  group('FormidableRadioGroup', () {
    testWidgets('selects nothing while the Field is Unset', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        app((form) => FormidableRadioGroup(field: form.size, options: plans)),
      );

      expect(
        [
          for (final p in ['Free', 'Plus', 'Pro']) isSelected(tester, p),
        ],
        [false, false, false],
      );
      handle.dispose();
    });

    testWidgets('selects the option of the value, also when set in code', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        app((form) => FormidableRadioGroup(field: form.size, options: plans)),
      );

      form.size.setValue(Plan.plus);
      await tester.pump();

      expect(isSelected(tester, 'Plus'), isTrue);
      expect(isSelected(tester, 'Free'), isFalse);
      handle.dispose();
    });

    testWidgets(
      'sets the Field and marks it touched when an option is tapped',
      (tester) async {
        await tester.pumpWidget(
          app((form) => FormidableRadioGroup(field: form.size, options: plans)),
        );
        expect(form.size.state.touched, isFalse);

        await tester.tap(find.text('Pro'));
        await tester.pump();

        expect(form.size.value, Plan.pro);
        expect(form.size.state.touched, isTrue);
      },
    );

    testWidgets('shows the Validation Message of a touched, Unset Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableRadioGroup(field: form.size, options: plans)),
      );
      expect(find.text('This field is required.'), findsNothing);

      form.size.markAsTouched();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    group('with an option that represents null', () {
      const choices = [
        FormidableRadioOption(value: null, title: Text('No preference')),
        FormidableRadioOption(value: true, title: Text('Yes')),
        FormidableRadioOption(value: false, title: Text('No')),
      ];

      testWidgets('an Unset Field selects no option, not even the null one', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          app(
            (form) =>
                FormidableRadioGroup(field: form.contact, options: choices),
          ),
        );

        expect(isSelected(tester, 'No preference'), isFalse);
        expect(isSelected(tester, 'Yes'), isFalse);
        handle.dispose();
      });

      testWidgets('choosing the null option sets the Field to null', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          app(
            (form) =>
                FormidableRadioGroup(field: form.contact, options: choices),
          ),
        );
        form.contact.markAsTouched();
        await tester.pump();
        expect(find.text('This field is required.'), findsOneWidget);

        await tester.tap(find.text('No preference'));
        await tester.pump();

        expect(form.contact.isSet, isTrue);
        expect(form.contact.value, isNull);
        expect(form.contact.state.errors, isEmpty);
        expect(find.text('This field is required.'), findsNothing);
        expect(isSelected(tester, 'No preference'), isTrue);
        handle.dispose();
      });

      testWidgets('a Field set to null in code selects the null option', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          app(
            (form) =>
                FormidableRadioGroup(field: form.contact, options: choices),
          ),
        );

        form.contact.setValue(null);
        await tester.pump();
        expect(isSelected(tester, 'No preference'), isTrue);

        form.contact.clear();
        await tester.pump();
        expect(isSelected(tester, 'No preference'), isFalse);
        handle.dispose();
      });
    });
  });
}
