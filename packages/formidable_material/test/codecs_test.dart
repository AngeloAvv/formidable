import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/measurements.dart';
import 'support/measurements.formidable_scope.dart';

/// Seam 2: a text field that shows a Field whose type is not `String`, through
/// a Codec chosen by the registry, by the config or by the widget.
void main() {
  Widget app({
    Locale locale = const Locale('en'),
    FormidableCodecs? codecs,
    required Widget child,
  }) {
    final home = MaterialApp(
      locale: locale,
      supportedLocales: FormidableLocalizations.supportedLocales,
      localizationsDelegates: [
        FormidableLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Scaffold(body: child),
    );
    return codecs == null
        ? home
        : FormidableConfig(codecs: codecs, child: home);
  }

  late MeasurementsForm form;

  Widget page({
    required Widget Function(MeasurementsForm form) field,
    MeasurementsForm Function()? create,
    FormidableCodecs? codecs,
    Locale locale = const Locale('en'),
  }) => app(
    locale: locale,
    codecs: codecs,
    child: MeasurementsFormScope(
      create: () => form = (create ?? () => MeasurementsForm(age: 30))(),
      child: Builder(
        builder: (context) => Column(
          children: [field(context.measurementsForm), const TextField()],
        ),
      ),
    ),
  );

  Widget age(MeasurementsForm form) =>
      FormidableMaterialTextField(field: form.age);
  Widget weight(MeasurementsForm form) =>
      FormidableMaterialTextField(field: form.weight);

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).first, text);
    await tester.pump();
  }

  Future<void> blur(WidgetTester tester) async {
    await tester.tap(find.byType(TextField).last);
    await tester.pump();
  }

  group('a non-String Field', () {
    testWidgets('shows the formatted value', (tester) async {
      await tester.pumpWidget(page(field: age));

      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('parses what the user types into the Field', (tester) async {
      await tester.pumpWidget(page(field: age));

      await type(tester, '42');

      expect(form.age.value, 42);
    });

    testWidgets('shows a value set in code', (tester) async {
      await tester.pumpWidget(page(field: age));

      form.age.setValue(7);
      await tester.pump();

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('blank text leaves an optional Field Unset', (tester) async {
      await tester.pumpWidget(
        page(field: weight, create: () => MeasurementsForm(age: 1, weight: 2)),
      );

      await type(tester, '');

      expect(form.weight.isSet, isFalse);
      expect(form.weight.state.errors, isEmpty);
    });

    testWidgets('blank text makes a required Field fail with required', (
      tester,
    ) async {
      await tester.pumpWidget(page(field: age));

      await type(tester, '');

      expect(form.age.state.errors, [isA<FormidableRequiredError>()]);
    });

    testWidgets('works with a nullable String Field', (tester) async {
      await tester.pumpWidget(
        page(
          field: (form) => FormidableMaterialTextField(field: form.nickname),
        ),
      );

      await type(tester, 'angelo');
      expect(form.nickname.value, 'angelo');

      await type(tester, '');
      expect(form.nickname.isSet, isFalse);
    });

    testWidgets('works with a DateTime Field', (tester) async {
      await tester.pumpWidget(
        page(
          field: (form) => FormidableMaterialTextField(field: form.born),
          create: () => MeasurementsForm(age: 1, born: DateTime(2000, 5, 17)),
        ),
      );
      expect(find.text('2000-05-17'), findsOneWidget);

      await type(tester, '2001-02-03');

      expect(form.born.value, DateTime(2001, 2, 3));
    });
  });

  group('input that cannot be parsed', () {
    testWidgets('stays visible', (tester) async {
      await tester.pumpWidget(page(field: weight));

      await type(tester, '12a');

      expect(find.text('12a'), findsOneWidget);
    });

    testWidgets('makes an optional Field invalid with a typed error', (
      tester,
    ) async {
      await tester.pumpWidget(page(field: weight));

      await type(tester, '12a');

      expect(form.weight.isSet, isFalse);
      expect(form.weight.state.errors, [
        const FormidableNumberParseError(input: '12a'),
      ]);
      final result = await form.submit();
      expect(result, isA<FormidableSubmitInvalid<Measurements>>());
    });

    testWidgets('shows the message once the Field is touched', (tester) async {
      await tester.pumpWidget(page(field: weight));

      await type(tester, '12a');
      expect(find.text('Enter a valid number.'), findsNothing);

      await blur(tester);
      expect(find.text('Enter a valid number.'), findsOneWidget);
      expect(find.text('12a'), findsOneWidget);
    });

    testWidgets('is replaced by a good input, which lifts the error', (
      tester,
    ) async {
      await tester.pumpWidget(page(field: weight));
      await type(tester, '12a');

      await type(tester, '12');

      expect(form.weight.value, 12);
      expect(form.weight.state.errors, isEmpty);
    });

    testWidgets('is replaced by a value set in code', (tester) async {
      await tester.pumpWidget(page(field: weight));
      await type(tester, '12a');

      form.weight.setValue(3.5);
      await tester.pump();

      expect(find.text('12a'), findsNothing);
      expect(find.text('3.5'), findsOneWidget);
      expect(form.weight.state.errors, isEmpty);
    });

    testWidgets('is wiped when the Field is cleared in code', (tester) async {
      await tester.pumpWidget(page(field: weight));
      await type(tester, '12a');

      form.weight.clear();
      await tester.pump();

      expect(find.text('12a'), findsNothing);
      expect(form.weight.state.errors, isEmpty);
    });

    testWidgets('a date that cannot be parsed has a date message', (
      tester,
    ) async {
      await tester.pumpWidget(
        page(field: (form) => FormidableMaterialTextField(field: form.born)),
      );

      await type(tester, '31/01/2024');
      await blur(tester);

      expect(find.text('Enter a valid date.'), findsOneWidget);
    });

    const number = {
      'en': 'Enter a valid number.',
      'it': 'Inserisci un numero valido.',
      'es': 'Introduce un número válido.',
      'fr': 'Saisissez un nombre valide.',
      'de': 'Geben Sie eine gültige Zahl ein.',
    };
    const date = {
      'en': 'Enter a valid date.',
      'it': 'Inserisci una data valida.',
      'es': 'Introduce una fecha válida.',
      'fr': 'Saisissez une date valide.',
      'de': 'Geben Sie ein gültiges Datum ein.',
    };
    for (final language in number.keys) {
      testWidgets('is explained in $language', (tester) async {
        await tester.pumpWidget(
          page(
            locale: Locale(language),
            field: (form) => Column(
              children: [
                SizedBox(height: 100, child: weight(form)),
                SizedBox(
                  height: 100,
                  child: FormidableMaterialTextField(field: form.born),
                ),
              ],
            ),
          ),
        );

        await tester.enterText(find.byType(TextField).at(0), 'x');
        await tester.enterText(find.byType(TextField).at(1), 'y');
        form.weight.markAsTouched();
        form.born.markAsTouched();
        await tester.pump();

        expect(find.text(number[language]!), findsOneWidget);
        expect(find.text(date[language]!), findsOneWidget);
      });
    }
  });

  group('Codec precedence', () {
    testWidgets('a Codec passed to the widget replaces the built-in one', (
      tester,
    ) async {
      await tester.pumpWidget(
        page(
          field: (form) => FormidableMaterialTextField(
            field: form.price,
            codec: const MoneyTextCodec(prefix: '€'),
          ),
          create: () => MeasurementsForm(age: 1, price: const Money(1250)),
        ),
      );

      expect(find.text('€12.50'), findsOneWidget);

      await type(tester, '€3.10');
      expect(form.price.value, const Money(310));
    });

    testWidgets('the config registry adds Codecs for custom types', (
      tester,
    ) async {
      await tester.pumpWidget(
        page(
          codecs: FormidableCodecs.defaults.add(const MoneyTextCodec()),
          field: (form) => FormidableMaterialTextField(field: form.price),
          create: () => MeasurementsForm(age: 1, price: const Money(1250)),
        ),
      );

      expect(find.text('12.50'), findsOneWidget);
    });

    testWidgets('the config registry can replace a built-in Codec', (
      tester,
    ) async {
      await tester.pumpWidget(
        page(
          codecs: FormidableCodecs.defaults.add(const _ShoutingIntCodec()),
          field: age,
        ),
      );

      expect(find.text('30!'), findsOneWidget);
    });

    testWidgets('the widget Codec wins over the config registry', (
      tester,
    ) async {
      await tester.pumpWidget(
        page(
          codecs: FormidableCodecs.defaults.add(const _ShoutingIntCodec()),
          field: (form) => FormidableMaterialTextField(
            field: form.age,
            codec: const _PlainInt(),
          ),
        ),
      );

      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('changing the config registry reformats the text', (
      tester,
    ) async {
      await tester.pumpWidget(
        page(codecs: FormidableCodecs.defaults, field: age),
      );
      expect(find.text('30'), findsOneWidget);

      await tester.pumpWidget(
        page(
          codecs: FormidableCodecs.defaults.add(const _ShoutingIntCodec()),
          field: age,
        ),
      );

      expect(find.text('30!'), findsOneWidget);
    });
  });
}

class _ShoutingIntCodec extends FormidableCodec<int, String> {
  const _ShoutingIntCodec();

  @override
  String format(int value) => '$value!';

  @override
  FormidableParseResult<int> parse(String input) {
    final value = int.tryParse(input.replaceAll('!', ''));
    return value == null
        ? const FormidableParsedUnset()
        : FormidableParsedValue(value);
  }
}

class _PlainInt extends FormidableCodec<int, String> {
  const _PlainInt();

  @override
  String format(int value) => '$value';

  @override
  FormidableParseResult<int> parse(String input) {
    final value = int.tryParse(input);
    return value == null
        ? const FormidableParsedUnset()
        : FormidableParsedValue(value);
  }
}
