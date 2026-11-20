import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

/// Seam 2: `FormidableMaterialTextField` takes the whole API of `TextField`, except
/// what Formidable owns, and merges the decoration instead of replacing it.
void main() {
  late FormidableField<String> name;

  setUp(() {
    name = FormidableField<String>(
      required: true,
      validators: const [MinLength(3)],
    );
    addTearDown(name.dispose);
  });

  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  TextField textField(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField));

  group('parameters of TextField', () {
    testWidgets('are handed to the TextField', (tester) async {
      final formatter = FilteringTextInputFormatter.digitsOnly;
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      var tapped = 0;
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            style: const TextStyle(fontSize: 31),
            textAlign: TextAlign.end,
            textAlignVertical: TextAlignVertical.bottom,
            textDirection: TextDirection.ltr,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.number,
            readOnly: true,
            showCursor: true,
            obscuringCharacter: '*',
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            maxLength: 12,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            inputFormatters: [formatter],
            cursorColor: Colors.red,
            cursorWidth: 4,
            scrollController: scroll,
            dragStartBehavior: DragStartBehavior.down,
            autofillHints: const [AutofillHints.name],
            restorationId: 'name',
            onTap: () => tapped++,
            canRequestFocus: true,
            enableInteractiveSelection: false,
            mouseCursor: SystemMouseCursors.help,
          ),
        ),
      );

      final field = textField(tester);
      expect(field.style?.fontSize, 31);
      expect(field.textAlign, TextAlign.end);
      expect(field.textAlignVertical, TextAlignVertical.bottom);
      expect(field.textDirection, TextDirection.ltr);
      expect(field.textCapitalization, TextCapitalization.words);
      expect(field.keyboardType, TextInputType.number);
      expect(field.readOnly, isTrue);
      expect(field.showCursor, isTrue);
      expect(field.obscuringCharacter, '*');
      expect(field.obscureText, isTrue);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.maxLength, 12);
      expect(field.maxLengthEnforcement, MaxLengthEnforcement.none);
      expect(field.inputFormatters, [formatter]);
      expect(field.cursorColor, Colors.red);
      expect(field.cursorWidth, 4);
      expect(field.scrollController, same(scroll));
      expect(field.dragStartBehavior, DragStartBehavior.down);
      expect(field.autofillHints, [AutofillHints.name]);
      expect(field.restorationId, 'name');
      expect(field.enableInteractiveSelection, isFalse);
      expect(field.mouseCursor, SystemMouseCursors.help);

      await tester.tap(find.byType(TextField));
      expect(tapped, 1);
    });

    testWidgets('keep the defaults of TextField when left out', (tester) async {
      await tester.pumpWidget(
        app(FormidableMaterialTextField<String>(field: name)),
      );

      final field = textField(tester);
      const defaults = TextField();
      expect(field.textCapitalization, defaults.textCapitalization);
      expect(field.textAlign, defaults.textAlign);
      expect(field.maxLines, 1);
      expect(field.obscuringCharacter, defaults.obscuringCharacter);
      expect(field.cursorWidth, defaults.cursorWidth);
      expect(field.scrollPadding, defaults.scrollPadding);
      expect(field.clipBehavior, defaults.clipBehavior);
      expect(field.canRequestFocus, isTrue);
      expect(field.contextMenuBuilder, isNotNull);
      expect(field.stylusHandwritingEnabled, defaults.stylusHandwritingEnabled);
      expect(field.smartDashesType, defaults.smartDashesType);
      expect(field.enableInteractiveSelection, isTrue);
    });

    testWidgets('the text length limit really limits what is typed', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(FormidableMaterialTextField<String>(field: name, maxLength: 4)),
      );

      await tester.enterText(find.byType(TextField), 'abcdefgh');

      expect(name.value, 'abcd');
    });

    testWidgets('an input formatter shapes what reaches the Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'a1b2c3');

      expect(name.value, '123');
    });

    testWidgets('the Field says whether the field is enabled', (tester) async {
      await tester.pumpWidget(
        app(FormidableMaterialTextField<String>(field: name)),
      );
      expect(textField(tester).enabled, isTrue);

      name.disable();
      await tester.pump();

      expect(textField(tester).enabled, isFalse);
    });

    testWidgets('onSubmitted is called with the text', (tester) async {
      String? submitted;
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            onSubmitted: (text) => submitted = text,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submitted, 'abc');
    });

    testWidgets('onEditingComplete replaces the move to the next Field', (
      tester,
    ) async {
      var completed = 0;
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            onEditingComplete: () => completed++,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(completed, 1);
    });

    testWidgets('textInputAction can be chosen', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            textInputAction: TextInputAction.search,
          ),
        ),
      );

      expect(textField(tester).textInputAction, TextInputAction.search);
    });
  });

  group('decoration', () {
    testWidgets('keeps what the caller set and adds the error', (tester) async {
      name.markAsTouched();
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Your name',
              helperText: 'As on your ID',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      );

      final decoration = textField(tester).decoration!;
      expect(decoration.labelText, 'Name');
      expect(decoration.hintText, 'Your name');
      expect(decoration.helperText, 'As on your ID');
      expect(decoration.prefixIcon, isA<Icon>());
      expect(decoration.border, isA<OutlineInputBorder>());
      expect(decoration.errorText, isNotNull);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('an errorText of the caller wins over the Field', (
      tester,
    ) async {
      name.markAsTouched();
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            decoration: const InputDecoration(errorText: 'Taken already'),
          ),
        ),
      );

      expect(find.text('Taken already'), findsOneWidget);
      expect(textField(tester).decoration!.errorText, 'Taken already');
    });

    testWidgets('has no error while the Field has none to show', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
        ),
      );

      expect(textField(tester).decoration!.errorText, isNull);
    });

    testWidgets('a suffix icon can depend on the value', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableFieldBuilder<String>(
            field: name,
            builder: (context, state) => FormidableMaterialTextField<String>(
              field: name,
              decoration: InputDecoration(
                suffixIcon: state.isSet
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: name.clear,
                      )
                    : null,
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.clear), findsNothing);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(name.isSet, isFalse);
      expect(find.byIcon(Icons.clear), findsNothing);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
    });

    testWidgets('a null decoration draws none, and no error', (tester) async {
      name.markAsTouched();
      await tester.pumpWidget(
        app(FormidableMaterialTextField<String>(field: name, decoration: null)),
      );

      expect(textField(tester).decoration, isNull);
      expect(find.byType(InputDecorator), findsNothing);
    });
  });

  group('keeps the behaviour', () {
    testWidgets('typing a space that @Trim removes keeps the space on screen', (
      tester,
    ) async {
      final trimmed = FormidableField<String>(normalizers: const [Trim()]);
      addTearDown(trimmed.dispose);
      await tester.pumpWidget(
        app(FormidableMaterialTextField<String>(field: trimmed)),
      );

      await tester.enterText(find.byType(TextField), 'New ');

      expect(trimmed.value, 'New');
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'New ',
      );
    });
  });
}
