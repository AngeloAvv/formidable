import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';

import 'support/harness.dart';
import 'support/profile.dart';

/// Seam 2: the Cupertino text field on a generated Form, driven like a user.
void main() {
  late ProfileForm form;

  Widget app(
    Widget Function(ProfileForm form) field, {
    FormidableCodecs? codecs,
  }) => profileApp(field, onForm: (f) => form = f, codecs: codecs);

  group('FormidableCupertinoTextField', () {
    testWidgets('the keyboard action moves focus to the next Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) => Column(
            children: [
              FormidableCupertinoTextField(
                field: form.username,
                placeholder: 'Username',
              ),
              FormidableCupertinoTextField(field: form.age, placeholder: 'Age'),
            ],
          ),
        ),
      );
      await tester.pump();

      TextInputAction? action(String placeholder) => tester
          .widget<CupertinoTextField>(
            find.widgetWithText(CupertinoTextField, placeholder),
          )
          .textInputAction;
      expect(action('Username'), TextInputAction.next);
      expect(action('Age'), TextInputAction.done);

      await tester.tap(find.widgetWithText(CupertinoTextField, 'Username'));
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      final age = tester.widget<EditableText>(
        find.descendant(
          of: find.widgetWithText(CupertinoTextField, 'Age'),
          matching: find.byType(EditableText),
        ),
      );
      expect(age.focusNode.hasFocus, isTrue);
    });

    testWidgets('shows the value and updates the Field as the user types', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableCupertinoTextField(field: form.username)),
      );
      expect(find.text('angelo'), findsOneWidget);

      await tester.enterText(find.byType(CupertinoTextField).first, 'maria');

      expect(form.username.value, 'maria');
    });

    testWidgets('a field of another type picks its Codec by the Field type', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableCupertinoTextField(field: form.age)),
      );

      await tester.enterText(find.byType(CupertinoTextField).first, '42');
      expect(form.age.value, 42);

      form.age.setValue(7);
      await tester.pump();
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('keeps text that can not be parsed and rejects the Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableCupertinoTextField(field: form.age)),
      );

      await tester.enterText(find.byType(CupertinoTextField).first, '12a');
      await tester.pump();

      expect(find.text('12a'), findsOneWidget);
      expect(form.age.inputError, isA<FormidableNumberParseError>());
      expect(form.age.state.errors, isNotEmpty);
    });

    testWidgets('a codec: on the widget wins over the registry', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          (form) => FormidableCupertinoTextField<int?>(
            field: form.age,
            codec: const _HexCodec(),
          ),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField).first, 'ff');

      expect(form.age.value, 255);
    });

    testWidgets('a Codec in the FormidableConfig is used', (tester) async {
      await tester.pumpWidget(
        app(
          (form) => FormidableCupertinoTextField(field: form.age),
          codecs: FormidableCodecs.defaults.add(const _HexCodec()),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField).first, 'ff');

      expect(form.age.value, 255);
    });

    testWidgets('shows the error once the Field loses focus', (tester) async {
      await tester.pumpWidget(
        app((form) => FormidableCupertinoTextField(field: form.username)),
      );

      await tester.tap(find.byType(CupertinoTextField).first);
      await tester.enterText(find.byType(CupertinoTextField).first, 'ab');
      await tester.pump();
      expect(find.textContaining('at least 4'), findsNothing);

      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();

      expect(form.username.state.touched, isTrue);
      expect(
        find.text('Must be at least 4 characters long (got 2).'),
        findsOneWidget,
      );
    });
  });
}

class _HexCodec extends FormidableCodec<int?, String> {
  const _HexCodec();

  @override
  String format(int? value) => value?.toRadixString(16) ?? '';

  @override
  FormidableParseResult<int?> parse(String input) {
    if (input.isEmpty) return const FormidableParsedUnset();
    final value = int.tryParse(input, radix: 16);
    return value == null
        ? FormidableParseFailure(FormidableNumberParseError(input: input))
        : FormidableParsedValue(value);
  }
}
