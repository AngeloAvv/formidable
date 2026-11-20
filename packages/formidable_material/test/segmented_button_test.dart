import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';
import 'support/preferences.dart';

/// Seam 2 for the segmented control.
void main() {
  late PreferencesForm form;

  Widget app(Widget Function(PreferencesForm form) field) =>
      preferencesApp(field, onCreated: (created) => form = created);

  const segments = [
    ButtonSegment(value: Plan.free, label: Text('Free')),
    ButtonSegment(value: Plan.plus, label: Text('Plus')),
    ButtonSegment(value: Plan.pro, label: Text('Pro')),
  ];

  // The values the control shows as selected.
  Set<Plan> selected(WidgetTester tester) => tester
      .widget<SegmentedButton<(Plan,)>>(find.byType(SegmentedButton<(Plan,)>))
      .selected
      .map((choice) => choice.$1)
      .toSet();

  group('FormidableSegmentedButton', () {
    testWidgets('selects nothing while the Field is Unset', (tester) async {
      await tester.pumpWidget(
        app(
          (form) =>
              FormidableSegmentedButton(field: form.layout, segments: segments),
        ),
      );

      expect(selected(tester), isEmpty);
    });

    testWidgets('selects the segment of the value, also when set in code', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) =>
              FormidableSegmentedButton(field: form.layout, segments: segments),
        ),
      );

      form.layout.setValue(Plan.plus);
      await tester.pump();

      expect(selected(tester), {Plan.plus});
    });

    testWidgets(
      'sets the Field and marks it touched when a segment is tapped',
      (tester) async {
        await tester.pumpWidget(
          app(
            (form) => FormidableSegmentedButton(
              field: form.layout,
              segments: segments,
            ),
          ),
        );
        expect(form.layout.state.touched, isFalse);

        await tester.tap(find.text('Pro'));
        await tester.pump();

        expect(form.layout.value, Plan.pro);
        expect(form.layout.state.touched, isTrue);
        expect(selected(tester), {Plan.pro});
      },
    );

    testWidgets('tapping the selected segment keeps it by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) =>
              FormidableSegmentedButton(field: form.layout, segments: segments),
        ),
      );
      form.layout.setValue(Plan.pro);
      await tester.pump();

      await tester.tap(find.text('Pro'));
      await tester.pump();

      expect(form.layout.value, Plan.pro);
      expect(selected(tester), {Plan.pro});
    });

    testWidgets('allowDeselect puts the Field back to Unset', (tester) async {
      await tester.pumpWidget(
        app(
          (form) => FormidableSegmentedButton(
            field: form.layout,
            segments: segments,
            allowDeselect: true,
          ),
        ),
      );
      form.layout.setValue(Plan.pro);
      await tester.pump();

      await tester.tap(find.text('Pro'));
      await tester.pump();

      expect(form.layout.isSet, isFalse);
      expect(form.layout.state.touched, isTrue);
      expect(selected(tester), isEmpty);
    });

    testWidgets('shows the Validation Message of a touched, Unset Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) =>
              FormidableSegmentedButton(field: form.layout, segments: segments),
        ),
      );
      expect(find.text('This field is required.'), findsNothing);

      form.layout.markAsTouched();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('a segment whose value is null is a choice, not Unset', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) => FormidableSegmentedButton(
            field: form.contact,
            segments: const [
              ButtonSegment(value: null, label: Text('Any')),
              ButtonSegment(value: true, label: Text('Yes')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Any'));
      await tester.pump();

      expect(form.contact.isSet, isTrue);
      expect(form.contact.value, isNull);
    });
  });
}
