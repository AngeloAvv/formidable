import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';

import 'support/harness.dart';
import 'support/profile.dart';

/// Seam 2: the date, time and timer pickers. Wheels can't take focus, so the
/// first change touches the Field.
void main() {
  late ProfileForm form;

  Future<void> pump(
    WidgetTester tester,
    Widget Function(ProfileForm) field, {
    DateTime? born,
    Duration? alarm,
  }) => tester.pumpWidget(
    profileApp(
      field,
      create: () => ProfileForm(username: 'angelo', born: born, alarm: alarm),
      onForm: (f) => form = f,
    ),
  );

  group('FormidableCupertinoDatePicker', () {
    Widget picker(ProfileForm form) => FormidableCupertinoDatePicker(
      field: form.born,
      mode: CupertinoDatePickerMode.date,
    );

    CupertinoDatePicker current(WidgetTester tester) =>
        tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));

    testWidgets('starts on the value of the Field', (tester) async {
      await pump(tester, picker, born: DateTime(2000, 5, 17));

      expect(current(tester).initialDateTime, DateTime(2000, 5, 17));
    });

    testWidgets('an Unset Field stays Unset until the user picks a date', (
      tester,
    ) async {
      await pump(tester, picker);

      expect(form.born.defined, isFalse);
      expect(form.born.state.touched, isFalse);

      await tester.drag(find.byType(CupertinoDatePicker), const Offset(0, -60));
      await tester.pumpAndSettle();

      expect(form.born.defined, isTrue);
      expect(form.born.state.touched, isTrue);
    });

    testWidgets('shows again a value set in code', (tester) async {
      await pump(tester, picker, born: DateTime(2000, 5, 17));

      form.born.setValue(DateTime(2010, 1, 2));
      await tester.pump();

      expect(current(tester).initialDateTime, DateTime(2010, 1, 2));
      expect(find.text('2010'), findsOneWidget);
    });

    testWidgets('the time mode reads and writes a time of the day', (
      tester,
    ) async {
      await pump(
        tester,
        (form) => FormidableCupertinoDatePicker(
          field: form.born,
          mode: CupertinoDatePickerMode.time,
        ),
        born: DateTime(2000, 1, 1, 9, 30),
      );
      expect(current(tester).mode, CupertinoDatePickerMode.time);

      await tester.drag(find.byType(CupertinoDatePicker), const Offset(0, -60));
      await tester.pumpAndSettle();

      expect(form.born.value, isNot(DateTime(2000, 1, 1, 9, 30)));
      expect(form.born.state.touched, isTrue);
    });
  });

  group('FormidableCupertinoTimerPicker', () {
    Widget picker(ProfileForm form) =>
        FormidableCupertinoTimerPicker(field: form.alarm);

    testWidgets('starts on the value of the Field', (tester) async {
      await pump(tester, picker, alarm: const Duration(hours: 1, minutes: 5));

      expect(
        tester
            .widget<CupertinoTimerPicker>(find.byType(CupertinoTimerPicker))
            .initialTimerDuration,
        const Duration(hours: 1, minutes: 5),
      );
    });

    testWidgets('a change sets the Field and touches it', (tester) async {
      await pump(tester, picker);
      expect(form.alarm.defined, isFalse);

      await tester.drag(
        find.byType(CupertinoTimerPicker),
        const Offset(-100, -60),
      );
      await tester.pumpAndSettle();

      expect(form.alarm.defined, isTrue);
      expect(form.alarm.state.touched, isTrue);
    });
  });
}
