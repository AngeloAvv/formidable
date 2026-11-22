import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';
import 'support/preferences.dart';

/// Seam 2 for the time picker.
void main() {
  late PreferencesForm form;

  Widget app(Widget Function(PreferencesForm form) field) =>
      preferencesApp(field, onCreated: (created) => form = created);

  Widget picker(PreferencesForm form, {bool clearable = false}) =>
      FormidableMaterialTimePicker<TimeOfDay>(
        field: form.reminder,
        decoration: const InputDecoration(labelText: 'Reminder'),
        initialTime: const TimeOfDay(hour: 9, minute: 30),
        format: (time) => '${time.hour}h${time.minute}',
        clearable: clearable,
      );

  group('FormidableMaterialTimePicker', () {
    testWidgets('shows nothing while the Field is Unset', (tester) async {
      await tester.pumpWidget(app(picker));

      expect(find.textContaining('h'), findsNothing);
    });

    testWidgets('shows the formatted value, also when set in code', (
      tester,
    ) async {
      await tester.pumpWidget(app(picker));

      form.reminder.setValue(const TimeOfDay(hour: 18, minute: 5));
      await tester.pump();

      expect(find.text('18h5'), findsOneWidget);
    });

    testWidgets('formats with the Material localizations by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) =>
              FormidableMaterialTimePicker<TimeOfDay>(field: form.reminder),
        ),
      );

      form.reminder.setValue(const TimeOfDay(hour: 18, minute: 5));
      await tester.pump();

      expect(find.text('6:05 PM'), findsOneWidget);
    });

    testWidgets('opens a dialog on tap and sets the picked time', (
      tester,
    ) async {
      await tester.pumpWidget(app(picker));
      expect(form.reminder.state.touched, isFalse);

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(form.reminder.value, const TimeOfDay(hour: 9, minute: 30));
      expect(find.text('9h30'), findsOneWidget);
      expect(form.reminder.state.touched, isTrue);
    });

    testWidgets('starts the dialog on the value of the Field', (tester) async {
      await tester.pumpWidget(app(picker));
      form.reminder.setValue(const TimeOfDay(hour: 22, minute: 15));
      await tester.pump();

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(form.reminder.value, const TimeOfDay(hour: 22, minute: 15));
    });

    testWidgets('cancelling changes nothing but marks the Field touched', (
      tester,
    ) async {
      await tester.pumpWidget(app(picker));

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(form.reminder.defined, isFalse);
      expect(form.reminder.state.touched, isTrue);
    });

    testWidgets('clearing a nullable Field sets it to null', (tester) async {
      await tester.pumpWidget(
        app(
          (form) => FormidableMaterialTimePicker<TimeOfDay?>(
            field: form.alarm,
            format: (time) => '${time.hour}h${time.minute}',
            clearable: true,
          ),
        ),
      );

      form.alarm.setValue(const TimeOfDay(hour: 18, minute: 5));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(form.alarm.defined, isTrue);
      expect(form.alarm.value, isNull);
      expect(form.alarm.state.dirty, isTrue);
      expect(form.alarm.state.touched, isTrue);
      expect(find.text('18h5'), findsNothing);
    });

    testWidgets('shows the Validation Message of a touched, Unset Field', (
      tester,
    ) async {
      await tester.pumpWidget(app(picker));
      expect(find.text('This field is required.'), findsNothing);

      form.reminder.touch();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('clearing a non-nullable Field puts it back to Unset', (
      tester,
    ) async {
      await tester.pumpWidget(app((form) => picker(form, clearable: true)));

      form.reminder.setValue(const TimeOfDay(hour: 18, minute: 5));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(form.reminder.defined, isFalse);
      expect(form.reminder.state.touched, isTrue);
    });
  });
}
