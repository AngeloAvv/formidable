import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/login.dart';
import 'support/login.formidable_scope.dart';

final class _Taken extends FormidableValidationError {
  const _Taken();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'Already taken';
}

final class _Down extends FormidableValidationError {
  const _Down();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'Service unavailable';
}

/// Seam 2: submit, focus, the error display policy, disabled Fields and
/// applied errors, seen through real widgets over a generated Form.
void main() {
  const tooShort = 'Must be at least 3 characters long (got 1).';
  const passwordTooShort = 'Must be at least 8 characters long (got 1).';

  late LoginForm form;
  late FocusNode usernameFocus;
  late FocusNode passwordFocus;

  setUp(() {
    usernameFocus = FocusNode();
    passwordFocus = FocusNode();
  });

  tearDown(() {
    usernameFocus.dispose();
    passwordFocus.dispose();
  });

  Widget page({
    FormidableErrorDisplay? scope,
    FormidableErrorDisplay? config,
    LoginForm Function()? create,
  }) {
    Widget body = LoginFormScope(
      create: create ?? () => form = LoginForm(),
      errorDisplay: scope,
      child: Builder(
        builder: (context) => Column(
          children: [
            FormidableTextField(
              field: context.loginForm.username,
              focusNode: usernameFocus,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            FormidableTextField(
              field: context.loginForm.password,
              focusNode: passwordFocus,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const TextField(key: Key('other')),
            FormidableFormBuilder<LoginForm>(
              builder: (context, state) => Text(
                'form:${state.errors.map((e) => e.toString()).join(',')}',
              ),
            ),
          ],
        ),
      ),
    );
    if (config != null) {
      body = FormidableConfig(errorDisplay: config, child: body);
    }
    return MaterialApp(home: Scaffold(body: body));
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  group('submit', () {
    testWidgets('shows the errors of every Field, even untouched ones', (
      tester,
    ) async {
      await tester.pumpWidget(page());
      expect(find.text('This field is required.'), findsNothing);

      form.submit();
      await tester.pump();

      expect(find.text('This field is required.'), findsNWidgets(2));
    });

    testWidgets('focuses the first invalid Field in declaration order', (
      tester,
    ) async {
      await tester.pumpWidget(page());
      await tester.enterText(field('Username'), 'angelo');

      form.submit();
      await tester.pump();

      expect(passwordFocus.hasFocus, isTrue);
      expect(usernameFocus.hasFocus, isFalse);
    });

    testWidgets('focuses the first Field when both are invalid', (
      tester,
    ) async {
      await tester.pumpWidget(page());

      form.submit();
      await tester.pump();

      expect(usernameFocus.hasFocus, isTrue);
    });
  });

  group('error display policy', () {
    testWidgets('defaults to when touched', (tester) async {
      await tester.pumpWidget(page());

      await tester.enterText(field('Username'), 'a');
      await tester.pump();
      expect(find.text(tooShort), findsNothing);

      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();
      expect(find.text(tooShort), findsOneWidget);
    });

    testWidgets('dirty shows the error as soon as the value changes', (
      tester,
    ) async {
      await tester.pumpWidget(page(config: FormidableErrorDisplay.dirty));

      expect(find.text('This field is required.'), findsNothing);
      await tester.enterText(field('Username'), 'a');
      await tester.pump();

      expect(find.text(tooShort), findsOneWidget);
      expect(find.text(passwordTooShort), findsNothing);
    });

    testWidgets('dirty also shows everything after submit', (tester) async {
      await tester.pumpWidget(page(config: FormidableErrorDisplay.dirty));

      form.submit();
      await tester.pump();

      expect(find.text('This field is required.'), findsNWidgets(2));
    });

    testWidgets('submit shows errors only after submit', (tester) async {
      await tester.pumpWidget(page(config: FormidableErrorDisplay.submit));

      await tester.enterText(field('Username'), 'a');
      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();
      expect(find.text(tooShort), findsNothing);

      form.submit();
      await tester.pump();
      expect(find.text(tooShort), findsOneWidget);
    });

    testWidgets('the Form Scope wins over the global config', (tester) async {
      await tester.pumpWidget(
        page(
          config: FormidableErrorDisplay.submit,
          scope: FormidableErrorDisplay.dirty,
        ),
      );

      await tester.enterText(field('Username'), 'a');
      await tester.pump();

      expect(find.text(tooShort), findsOneWidget);
    });

    testWidgets('a changed global policy rebuilds the shown errors', (
      tester,
    ) async {
      await tester.pumpWidget(page(config: FormidableErrorDisplay.submit));
      await tester.enterText(field('Username'), 'a');
      await tester.pump();
      expect(find.text(tooShort), findsNothing);

      await tester.pumpWidget(page(config: FormidableErrorDisplay.dirty));
      await tester.pump();

      expect(find.text(tooShort), findsOneWidget);
    });
  });

  group('disabled Field', () {
    testWidgets('does not accept input and shows no errors', (tester) async {
      await tester.pumpWidget(page());
      await tester.enterText(field('Password'), 'a');
      form.password.markAsTouched();
      await tester.pump();
      expect(find.text(passwordTooShort), findsOneWidget);

      form.password.disable();
      await tester.pump();

      expect(tester.widget<TextField>(field('Password')).enabled, isFalse);
      expect(find.text(passwordTooShort), findsNothing);
    });

    testWidgets('is enabled again after enable()', (tester) async {
      await tester.pumpWidget(page());
      form.password.disable();
      await tester.pump();

      form.password.enable();
      await tester.pump();

      expect(tester.widget<TextField>(field('Password')).enabled, isTrue);
    });

    testWidgets('submit does not focus a disabled Field', (tester) async {
      await tester.pumpWidget(page());
      form.username.disable();
      await tester.pump();

      form.submit();
      await tester.pump();

      expect(usernameFocus.hasFocus, isFalse);
      expect(passwordFocus.hasFocus, isTrue);
    });
  });

  group('applied errors', () {
    testWidgets('show on the Field and clear when the user types', (
      tester,
    ) async {
      await tester.pumpWidget(page());
      await tester.enterText(field('Username'), 'angelo');
      form.username.markAsTouched();
      form.applyErrors(
        fieldErrors: {
          form.username: [const _Taken()],
        },
      );
      await tester.pump();
      expect(find.text('Already taken'), findsOneWidget);

      await tester.enterText(field('Username'), 'angelo2');
      await tester.pump();

      expect(find.text('Already taken'), findsNothing);
    });

    testWidgets('Form errors reach a Form Builder and clear on change', (
      tester,
    ) async {
      await tester.pumpWidget(page());

      form.applyErrors(formErrors: [const _Down()]);
      await tester.pump();
      expect(find.text('form:Service unavailable'), findsOneWidget);

      await tester.enterText(field('Username'), 'angelo');
      await tester.pump();

      expect(find.text('form:'), findsOneWidget);
    });
  });
}
