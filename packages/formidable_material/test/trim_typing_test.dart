import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/trimmed.dart';
import 'support/trimmed.formidable_scope.dart';

/// Seam 2: a Normalizer rewrites the Field, but never what the user is typing.
void main() {
  late TrimmedForm form;

  Future<void> mount(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TrimmedFormScope(
          create: () => form = TrimmedForm(),
          child: Builder(
            builder: (context) =>
                FormidableMaterialTextField(field: context.trimmedForm.city),
          ),
        ),
      ),
    ),
  );

  String shown(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('keeps the space the user types, the Field holds it trimmed', (
    tester,
  ) async {
    await mount(tester);

    for (final text in ['N', 'Ne', 'New', 'New ', 'New Y', 'New York']) {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
      expect(shown(tester), text);
    }

    expect(form.city.value, 'New York');
  });

  testWidgets('keeps the space when the first text that arrives ends with it', (
    tester,
  ) async {
    await mount(tester);

    await tester.enterText(find.byType(TextField), 'New ');
    await tester.pump();
    expect(shown(tester), 'New ');
    expect(form.city.value, 'New');

    await tester.enterText(find.byType(TextField), 'New York');
    await tester.pump();
    expect(shown(tester), 'New York');
    expect(form.city.value, 'New York');
  });

  testWidgets('keeps text that is only whitespace while the Field is Unset', (
    tester,
  ) async {
    await mount(tester);

    await tester.enterText(find.byType(TextField), '  ');
    await tester.pump();

    expect(shown(tester), '  ');
    expect(form.city.isSet, isFalse);
  });

  testWidgets('shows a value written in code, after the user typed', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField), 'New ');
    await tester.pump();

    form.city.setValue('Rome');
    await tester.pump();

    expect(shown(tester), 'Rome');
  });

  testWidgets('shows the initial value again after reset', (tester) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField), 'New ');
    await tester.pump();

    form.reset();
    await tester.pump();

    expect(shown(tester), '');
  });
}
