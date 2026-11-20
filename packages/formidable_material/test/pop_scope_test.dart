import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'support/sign_up.dart';
import 'support/sign_up.formidable_scope.dart';

/// Seam 2: the pop scope over a real generated Form, driven by the system back
/// gesture.
void main() {
  // A home page that opens the form page, and the form page itself.
  Future<void> openFormPage(
    WidgetTester tester,
    SignUpForm form,
    Future<bool> Function(BuildContext context) confirmLeave,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SignUpFormScope.value(
                  form: form,
                  child: FormidablePopScope<SignUpForm>(
                    confirmLeave: confirmLeave,
                    child: const Text('form page'),
                  ),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('form page'), findsOneWidget);
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('a clean Form can be left without asking', (tester) async {
    final form = SignUpForm(username: 'angelo');
    var asked = 0;
    await openFormPage(tester, form, (context) async {
      asked++;
      return true;
    });

    await back(tester);

    expect(find.text('form page'), findsNothing);
    expect(asked, 0);
  });

  testWidgets('a dirty Form blocks leaving and asks for confirmation', (
    tester,
  ) async {
    final form = SignUpForm(username: 'angelo');
    var asked = 0;
    await openFormPage(tester, form, (context) async {
      asked++;
      return false;
    });
    form.username.setValue('changed');
    await tester.pump();

    await back(tester);

    expect(asked, 1);
    expect(find.text('form page'), findsOneWidget);
  });

  testWidgets('leaves when the confirmation accepts', (tester) async {
    final form = SignUpForm(username: 'angelo');
    await openFormPage(tester, form, (context) async => true);
    form.username.setValue('changed');
    await tester.pump();

    await back(tester);

    expect(find.text('form page'), findsNothing);
  });

  testWidgets('can show a dialog as the confirmation', (tester) async {
    final form = SignUpForm(username: 'angelo');
    await openFormPage(
      tester,
      form,
      (context) async =>
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ) ??
          false,
    );
    form.username.setValue('changed');
    await tester.pump();

    await back(tester);
    expect(find.text('Discard changes?'), findsOneWidget);
    expect(find.text('form page'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('form page'), findsNothing);
  });

  testWidgets('can be left again once the Form is clean', (tester) async {
    final form = SignUpForm(username: 'angelo');
    var asked = 0;
    await openFormPage(tester, form, (context) async {
      asked++;
      return false;
    });
    form.username.setValue('changed');
    await tester.pump();
    form.reset();
    await tester.pump();

    await back(tester);

    expect(find.text('form page'), findsNothing);
    expect(asked, 0);
  });

  testWidgets('can be left after the changes were committed', (tester) async {
    final form = SignUpForm(username: 'angelo');
    await openFormPage(tester, form, (context) async => false);
    form.username.setValue('changed');
    form.commit();
    await tester.pump();

    await back(tester);

    expect(find.text('form page'), findsNothing);
  });

  testWidgets('uses the Form of the closest scope by default', (tester) async {
    final form = SignUpForm(username: 'angelo');
    var asked = 0;
    await openFormPage(tester, form, (context) async {
      asked++;
      return false;
    });

    form.patch(username: 'other');
    await tester.pump();
    await back(tester);

    expect(asked, 1);
  });
}
