import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/sign_up.dart';
import 'support/sign_up.formidable_scope.dart';

/// Seam 2: mount a generated Form Scope with the Material widget and a real
/// generated Form, then drive it like a user would.
void main() {
  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  Widget page({SignUpForm Function()? create, List<Widget> after = const []}) =>
      app(
        SignUpFormScope(
          create: create,
          child: Builder(
            builder: (context) => Column(
              children: [
                FormidableMaterialTextField(
                  field: context.signUpForm.username,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const TextField(key: Key('other')),
                ...after,
              ],
            ),
          ),
        ),
      );

  testWidgets('shows the value of the Field', (tester) async {
    await tester.pumpWidget(page(create: () => SignUpForm(username: 'angelo')));

    expect(find.text('angelo'), findsOneWidget);
  });

  testWidgets('updates the Field as the user types', (tester) async {
    late SignUpForm form;
    await tester.pumpWidget(page(create: () => form = SignUpForm()));

    await tester.enterText(find.byType(TextField).first, 'ang');

    expect(form.username.value, 'ang');
    expect(form.username.isSet, isTrue);
  });

  testWidgets('shows the current value again after the Field changes in code', (
    tester,
  ) async {
    late SignUpForm form;
    await tester.pumpWidget(page(create: () => form = SignUpForm()));

    form.username.setValue('programmatic');
    await tester.pump();

    expect(find.text('programmatic'), findsOneWidget);

    form.username.clear();
    await tester.pump();

    expect(find.text('programmatic'), findsNothing);
  });

  testWidgets('a completely empty text leaves the Field Unset', (tester) async {
    late SignUpForm form;
    await tester.pumpWidget(
      page(create: () => form = SignUpForm(username: 'angelo')),
    );

    await tester.enterText(find.byType(TextField).first, '');

    expect(form.username.isSet, isFalse);
  });

  group('error text', () {
    testWidgets('is hidden until the Field is touched', (tester) async {
      await tester.pumpWidget(page());

      await tester.enterText(find.byType(TextField).first, 'ab');
      await tester.pump();

      expect(find.textContaining('at least 4'), findsNothing);
    });

    testWidgets('shows once the Field loses focus', (tester) async {
      late SignUpForm form;
      await tester.pumpWidget(page(create: () => form = SignUpForm()));

      await tester.tap(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, 'ab');
      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();

      expect(form.username.state.touched, isTrue);
      expect(
        find.text('Must be at least 4 characters long (got 2).'),
        findsOneWidget,
      );
    });

    testWidgets('shows the required error for an Unset Field once touched', (
      tester,
    ) async {
      await tester.pumpWidget(page());

      await tester.tap(find.byType(TextField).first);
      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('disappears when the value becomes valid', (tester) async {
      late SignUpForm form;
      await tester.pumpWidget(page(create: () => form = SignUpForm()));
      form.username.markAsTouched();
      await tester.pump();
      expect(find.text('This field is required.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'angelo');
      await tester.pump();

      expect(find.text('This field is required.'), findsNothing);
    });
  });

  group('Form Scope', () {
    testWidgets('creates the Form once and disposes it with the scope', (
      tester,
    ) async {
      var created = 0;
      late SignUpForm form;
      await tester.pumpWidget(
        page(
          create: () {
            created++;
            return form = SignUpForm();
          },
        ),
      );
      await tester.pump();

      expect(created, 1);
      expect(form.isDisposed, isFalse);

      await tester.pumpWidget(app(const SizedBox()));

      expect(form.isDisposed, isTrue);
    });

    testWidgets('looks the Form up from the context', (tester) async {
      late SignUpForm looked;
      late SignUpForm created;
      await tester.pumpWidget(
        app(
          SignUpFormScope(
            create: () => created = SignUpForm(),
            child: Builder(
              builder: (context) {
                looked = context.signUpForm;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(looked, same(created));
    });
  });
}
