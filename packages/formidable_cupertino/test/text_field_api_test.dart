import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';

/// Seam 2: `FormidableCupertinoTextField` takes the whole API of
/// `CupertinoTextField`, except what Formidable owns.
void main() {
  late FormidableField<String> name;

  setUp(() {
    name = FormidableField<String>(
      required: true,
      validators: const [MinLength(3)],
    );
    addTearDown(name.dispose);
  });

  Widget app(Widget child) => CupertinoApp(
    home: CupertinoPageScaffold(child: SafeArea(child: child)),
  );

  CupertinoTextField textField(WidgetTester tester) =>
      tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));

  testWidgets('parameters are handed to the CupertinoTextField', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      app(
        FormidableCupertinoTextField<String>(
          field: name,
          style: const TextStyle(fontSize: 31),
          placeholder: 'Name',
          placeholderStyle: const TextStyle(fontSize: 9),
          padding: const EdgeInsets.all(20),
          prefix: const Icon(CupertinoIcons.person),
          prefixMode: OverlayVisibilityMode.editing,
          suffix: const Icon(CupertinoIcons.check_mark),
          suffixMode: OverlayVisibilityMode.notEditing,
          clearButtonMode: OverlayVisibilityMode.always,
          clearButtonSemanticLabel: 'Clear',
          crossAxisAlignment: CrossAxisAlignment.start,
          textAlign: TextAlign.end,
          textAlignVertical: TextAlignVertical.bottom,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.number,
          readOnly: true,
          obscureText: true,
          autocorrect: false,
          maxLength: 12,
          cursorColor: CupertinoColors.activeOrange,
          cursorRadius: const Radius.circular(9),
          keyboardAppearance: Brightness.dark,
          autofillHints: const [AutofillHints.name],
          restorationId: 'name',
          onTap: () => tapped++,
        ),
      ),
    );

    final field = textField(tester);
    expect(field.style?.fontSize, 31);
    expect(field.placeholder, 'Name');
    expect(field.placeholderStyle?.fontSize, 9);
    expect(field.padding, const EdgeInsets.all(20));
    expect(field.prefixMode, OverlayVisibilityMode.editing);
    expect(field.suffixMode, OverlayVisibilityMode.notEditing);
    expect(field.clearButtonMode, OverlayVisibilityMode.always);
    expect(field.clearButtonSemanticLabel, 'Clear');
    expect(field.crossAxisAlignment, CrossAxisAlignment.start);
    expect(field.textAlign, TextAlign.end);
    expect(field.textAlignVertical, TextAlignVertical.bottom);
    expect(field.textCapitalization, TextCapitalization.words);
    expect(field.keyboardType, TextInputType.number);
    expect(field.readOnly, isTrue);
    expect(field.obscureText, isTrue);
    expect(field.autocorrect, isFalse);
    expect(field.maxLength, 12);
    expect(field.cursorColor, CupertinoColors.activeOrange);
    expect(field.cursorRadius, const Radius.circular(9));
    expect(field.keyboardAppearance, Brightness.dark);
    expect(field.autofillHints, [AutofillHints.name]);
    expect(field.restorationId, 'name');

    await tester.tap(find.byType(CupertinoTextField));
    expect(tapped, 1);
  });

  testWidgets('keeps the defaults of CupertinoTextField when left out', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(FormidableCupertinoTextField<String>(field: name)),
    );

    final field = textField(tester);
    const defaults = CupertinoTextField();
    expect(field.decoration, isNotNull);
    expect(field.decoration, defaults.decoration);
    expect(field.padding, defaults.padding);
    expect(field.placeholderStyle, defaults.placeholderStyle);
    expect(field.clearButtonMode, defaults.clearButtonMode);
    expect(field.cursorRadius, defaults.cursorRadius);
    expect(field.contextMenuBuilder, isNotNull);
    expect(field.maxLines, 1);
  });

  testWidgets('an empty BoxDecoration removes the box', (tester) async {
    await tester.pumpWidget(
      app(
        FormidableCupertinoTextField<String>(
          field: name,
          decoration: const BoxDecoration(),
        ),
      ),
    );

    expect(textField(tester).decoration, const BoxDecoration());
  });

  testWidgets('the Field says whether the field is enabled', (tester) async {
    await tester.pumpWidget(
      app(FormidableCupertinoTextField<String>(field: name)),
    );
    expect(textField(tester).enabled, isTrue);

    name.disable();
    await tester.pump();

    expect(textField(tester).enabled, isFalse);
  });

  testWidgets('input formatters shape what reaches the Field', (tester) async {
    await tester.pumpWidget(
      app(
        FormidableCupertinoTextField<String>(
          field: name,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
    );

    await tester.enterText(find.byType(CupertinoTextField), 'a1b2c3');

    expect(name.value, '123');
  });

  testWidgets('onSubmitted is called with the text', (tester) async {
    String? submitted;
    await tester.pumpWidget(
      app(
        FormidableCupertinoTextField<String>(
          field: name,
          onSubmitted: (text) => submitted = text,
        ),
      ),
    );

    await tester.enterText(find.byType(CupertinoTextField), 'abc');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(submitted, 'abc');
  });

  testWidgets('shows the error in a caption once the Field is touched', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(FormidableCupertinoTextField<String>(field: name)),
    );
    await tester.enterText(find.byType(CupertinoTextField), 'ab');
    await tester.pump();
    expect(find.byType(FormidableCupertinoErrorCaption), findsOneWidget);
    expect(
      tester
          .widget<FormidableCupertinoErrorCaption>(
            find.byType(FormidableCupertinoErrorCaption),
          )
          .errorText,
      isNull,
    );

    name.markAsTouched();
    await tester.pump();

    expect(
      tester
          .widget<FormidableCupertinoErrorCaption>(
            find.byType(FormidableCupertinoErrorCaption),
          )
          .errorText,
      isNotNull,
    );
  });
}
