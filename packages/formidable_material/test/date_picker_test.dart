import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';
import 'support/preferences.dart';

/// Seam 2 for the date picker.
void main() {
  late PreferencesForm form;

  Widget app(Widget Function(PreferencesForm form) field) =>
      preferencesApp(field, onCreated: (created) => form = created);

  String iso(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Widget picker(PreferencesForm form, {bool clearable = false}) =>
      FormidableMaterialDatePicker<DateTime>(
        field: form.birthday,
        decoration: const InputDecoration(labelText: 'Birthday'),
        initialDate: DateTime(2024, 5, 10),
        firstDate: DateTime(2024),
        lastDate: DateTime(2024, 12, 31),
        format: iso,
        clearable: clearable,
      );

  group('FormidableMaterialDatePicker', () {
    testWidgets('shows nothing while the Field is Unset', (tester) async {
      await tester.pumpWidget(app(picker));

      expect(find.textContaining('2024-'), findsNothing);
    });

    testWidgets('shows the formatted value, also when set in code', (
      tester,
    ) async {
      await tester.pumpWidget(app(picker));

      form.birthday.setValue(DateTime(2024, 7, 4));
      await tester.pump();

      expect(find.text('2024-07-04'), findsOneWidget);
    });

    testWidgets('formats with the Material localizations by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) =>
              FormidableMaterialDatePicker<DateTime>(field: form.birthday),
        ),
      );

      form.birthday.setValue(DateTime(2024, 7, 4));
      await tester.pump();

      expect(find.textContaining('Jul'), findsOneWidget);
    });

    testWidgets('opens a dialog on tap and sets the picked date', (
      tester,
    ) async {
      await tester.pumpWidget(app(picker));
      expect(form.birthday.state.touched, isFalse);

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(form.birthday.value, DateTime(2024, 5, 15));
      expect(find.text('2024-05-15'), findsOneWidget);
      expect(form.birthday.state.touched, isTrue);
    });

    testWidgets('starts the dialog on the value of the Field', (tester) async {
      await tester.pumpWidget(app(picker));
      form.birthday.setValue(DateTime(2024, 9, 20));
      await tester.pump();

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(form.birthday.value, DateTime(2024, 9, 20));
    });

    testWidgets('cancelling changes nothing but marks the Field touched', (
      tester,
    ) async {
      await tester.pumpWidget(app(picker));

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(form.birthday.isSet, isFalse);
      expect(form.birthday.state.touched, isTrue);
    });

    testWidgets('shows the Validation Message of a touched, Unset Field', (
      tester,
    ) async {
      await tester.pumpWidget(app(picker));
      expect(find.text('This field is required.'), findsNothing);

      form.birthday.markAsTouched();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('a clearable picker can put the Field back to Unset', (
      tester,
    ) async {
      await tester.pumpWidget(app((form) => picker(form, clearable: true)));
      expect(find.byIcon(Icons.clear), findsNothing);

      form.birthday.setValue(DateTime(2024, 7, 4));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(form.birthday.isSet, isFalse);
      expect(form.birthday.state.touched, isTrue);
      expect(find.text('2024-07-04'), findsNothing);
    });
  });
}
