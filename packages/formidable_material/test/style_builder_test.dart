import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

/// Seam 2: the text field takes a `styleBuilder` next to `style`, which sees
/// the control of the widget and runs again whenever the Field changes.
void main() {
  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('FormidableMaterialTextField.styleBuilder', () {
    late FormidableField<String> name;

    setUp(() {
      name = FormidableField<String>(
        required: true,
        validators: const [MinLength(3)],
      );
      addTearDown(name.dispose);
    });

    TextStyle? style(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField)).style;

    testWidgets('turns the text red while the Field has an error', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            styleBuilder: (context, control) => control.errorText == null
                ? null
                : const TextStyle(color: Colors.red),
          ),
        ),
      );
      expect(style(tester), isNull);

      await tester.enterText(find.byType(TextField), 'ab');
      name.touch();
      await tester.pump();
      expect(style(tester)?.color, Colors.red);

      await tester.enterText(find.byType(TextField), 'abcd');
      await tester.pump();
      expect(style(tester), isNull);
    });

    testWidgets('sees the value of the control', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            styleBuilder: (context, control) => TextStyle(
              fontSize: (control.value ?? '').length.toDouble() + 10,
            ),
          ),
        ),
      );
      expect(style(tester)?.fontSize, 10);

      await tester.enterText(find.byType(TextField), 'abcd');
      await tester.pump();

      expect(style(tester)?.fontSize, 14);
    });

    testWidgets('a static style still works', (tester) async {
      await tester.pumpWidget(
        app(
          FormidableMaterialTextField<String>(
            field: name,
            style: const TextStyle(fontSize: 22),
          ),
        ),
      );

      expect(style(tester)?.fontSize, 22);
    });

    testWidgets('can not be combined with style', (tester) async {
      expect(
        () => FormidableMaterialTextField<String>(
          field: name,
          style: const TextStyle(fontSize: 22),
          styleBuilder: (context, control) => null,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('is readable', (tester) async {
      TextStyle? build(BuildContext context, control) => null;
      final widget = FormidableMaterialTextField<String>(
        field: name,
        styleBuilder: build,
      );

      expect(widget.styleBuilder, same(build));
    });
  });
}
