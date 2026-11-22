import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

/// Seam 2: the widgets that take an `InputDecoration` also take a
/// `decorationBuilder`, which sees the control of the widget. Its result is
/// merged like `decoration`, so Formidable still adds the Validation Message.
void main() {
  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('FormidableMaterialTextField.decorationBuilder', () {
    late FormidableField<String> name;

    setUp(() {
      name = FormidableField<String>(
        required: true,
        validators: const [MinLength(3)],
      );
      addTearDown(name.dispose);
    });

    Widget field() => FormidableMaterialTextField<String>(
      field: name,
      decorationBuilder: (context, control) => InputDecoration(
        labelText: 'Name',
        suffixIcon: (control.value ?? '').isEmpty
            ? null
            : IconButton(
                key: const Key('clear'),
                icon: const Icon(Icons.clear),
                onPressed: control.clear,
              ),
      ),
    );

    testWidgets('shows a clear button only while there is text', (
      tester,
    ) async {
      await tester.pumpWidget(app(field()));
      expect(find.byKey(const Key('clear')), findsNothing);
      expect(find.text('Name'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.byKey(const Key('clear')), findsOneWidget);

      await tester.tap(find.byKey(const Key('clear')));
      await tester.pump();

      expect(name.defined, isFalse);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
      expect(find.byKey(const Key('clear')), findsNothing);
    });

    testWidgets('still gets the Validation Message', (tester) async {
      await tester.pumpWidget(app(field()));

      await tester.enterText(find.byType(TextField), 'ab');
      name.touch();
      await tester.pump();

      expect(find.text('Name'), findsOneWidget);
      expect(find.textContaining('3'), findsOneWidget);
    });

    testWidgets('keeps an errorText of its own', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            decorationBuilder: (context, control) =>
                const InputDecoration(errorText: 'Mine'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ab');
      name.touch();
      await tester.pump();

      expect(find.text('Mine'), findsOneWidget);
    });

    testWidgets('can not be combined with decoration', (tester) async {
      expect(
        () => FormidableMaterialTextField<String>(
          field: name,
          decoration: const InputDecoration(labelText: 'Name'),
          decorationBuilder: (context, control) => const InputDecoration(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('is readable', (tester) async {
      InputDecoration build(BuildContext context, control) =>
          const InputDecoration();
      final widget = FormidableMaterialTextField<String>(
        field: name,
        decorationBuilder: build,
      );

      expect(widget.decorationBuilder, same(build));
    });
  });

  group('FormidableMaterialDropdown.decorationBuilder', () {
    late FormidableField<String> country;

    setUp(() {
      country = FormidableField<String>(required: true);
      addTearDown(country.dispose);
    });

    Widget dropdown() => FormidableMaterialDropdown<String>(
      field: country,
      items: const [
        DropdownMenuItem(value: 'it', child: Text('Italy')),
        DropdownMenuItem(value: 'fr', child: Text('France')),
      ],
      decorationBuilder: (context, control) => InputDecoration(
        labelText: control.value == null ? 'Pick one' : 'Picked',
        suffixIcon: control.value == null
            ? null
            : IconButton(
                key: const Key('clear'),
                icon: const Icon(Icons.clear),
                onPressed: control.clear,
              ),
      ),
    );

    testWidgets('follows the value and clears it', (tester) async {
      await tester.pumpWidget(app(dropdown()));
      expect(find.text('Pick one'), findsOneWidget);

      country.setValue('fr');
      await tester.pump();
      expect(find.text('Picked'), findsOneWidget);
      expect(find.byKey(const Key('clear')), findsOneWidget);

      await tester.tap(find.byKey(const Key('clear')));
      await tester.pump();

      expect(country.defined, isFalse);
      expect(find.text('Pick one'), findsOneWidget);
    });

    testWidgets('still gets the Validation Message', (tester) async {
      await tester.pumpWidget(app(dropdown()));

      country.touch();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('can not be combined with decoration', (tester) async {
      expect(
        () => FormidableMaterialDropdown<String>(
          field: country,
          items: const [],
          decoration: const InputDecoration(labelText: 'Country'),
          decorationBuilder: (context, control) => const InputDecoration(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('FormidableMaterialDatePicker.decorationBuilder', () {
    late FormidableField<DateTime> birthday;

    setUp(() {
      birthday = FormidableField<DateTime>(required: true);
      addTearDown(birthday.dispose);
    });

    testWidgets('builds the decoration from the control', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialDatePicker<DateTime>(
            field: birthday,
            format: (date) => '${date.year}',
            decorationBuilder: (context, control) => InputDecoration(
              labelText: control.value == null ? 'No date' : 'Has a date',
            ),
          ),
        ),
      );
      expect(find.text('No date'), findsOneWidget);

      birthday.setValue(DateTime(2024, 7, 4));
      await tester.pump();

      expect(find.text('Has a date'), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);
    });

    testWidgets('still gets the Validation Message', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialDatePicker<DateTime>(
            field: birthday,
            decorationBuilder: (context, control) =>
                const InputDecoration(labelText: 'Birthday'),
          ),
        ),
      );

      birthday.touch();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('can not be combined with decoration', (tester) async {
      expect(
        () => FormidableMaterialDatePicker<DateTime>(
          field: birthday,
          decoration: const InputDecoration(labelText: 'Birthday'),
          decorationBuilder: (context, control) => const InputDecoration(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('FormidableMaterialTimePicker.decorationBuilder', () {
    late FormidableField<TimeOfDay> reminder;

    setUp(() {
      reminder = FormidableField<TimeOfDay>(required: true);
      addTearDown(reminder.dispose);
    });

    testWidgets('builds the decoration from the control', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialTimePicker<TimeOfDay>(
            field: reminder,
            format: (time) => '${time.hour}h',
            decorationBuilder: (context, control) => InputDecoration(
              labelText: control.value == null ? 'No time' : 'Has a time',
            ),
          ),
        ),
      );
      expect(find.text('No time'), findsOneWidget);

      reminder.setValue(const TimeOfDay(hour: 7, minute: 0));
      await tester.pump();

      expect(find.text('Has a time'), findsOneWidget);
      expect(find.text('7h'), findsOneWidget);
    });

    testWidgets('can not be combined with decoration', (tester) async {
      expect(
        () => FormidableMaterialTimePicker<TimeOfDay>(
          field: reminder,
          decoration: const InputDecoration(labelText: 'Reminder'),
          decorationBuilder: (context, control) => const InputDecoration(),
        ),
        throwsAssertionError,
      );
    });
  });
}
