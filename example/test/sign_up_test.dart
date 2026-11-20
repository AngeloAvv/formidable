import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/sign_up/sign_up_cupertino.dart';
import 'package:formidable_example/sign_up/sign_up_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

/// One flow, run against both design systems.
void signUpFlows({
  required String name,
  required Future<void> Function(WidgetTester) pump,
  required Finder submitButton,
  required Finder companyOption,
}) {
  group('sign-up ($name)', () {
    Future<void> fill(
      WidgetTester tester, {
      String username = 'angelo',
      String password = 'secret123',
      String confirmation = 'secret123',
    }) async {
      await tester.enterText(find.byKey(const Key('username')), username);
      await tester.enterText(find.byKey(const Key('password')), password);
      await tester.enterText(
        find.byKey(const Key('confirmation')),
        confirmation,
      );
    }

    testWidgets('submitting an empty form asks to fix the errors', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(submitButton);
      await settle(tester);

      expect(find.text('Please fix the errors above.'), findsOneWidget);
    });

    testWidgets('a valid form welcomes the user', (tester) async {
      await pump(tester);
      await fill(tester);

      await tester.tap(submitButton);
      await settle(tester);

      expect(find.text('Welcome, angelo!'), findsOneWidget);
    });

    testWidgets('a confirmation that differs from the password is an error', (
      tester,
    ) async {
      await pump(tester);
      await fill(tester, confirmation: 'other-secret');

      await tester.tap(submitButton);
      await settle(tester);

      expect(find.text('The values do not match.'), findsOneWidget);
      expect(find.text('Please fix the errors above.'), findsOneWidget);
    });

    testWidgets('a taken username is reported by the asynchronous check', (
      tester,
    ) async {
      await pump(tester);

      await tester.enterText(find.byKey(const Key('username')), 'admin');
      // Errors show once the user has left the Field.
      await tester.tap(find.byKey(const Key('password')));
      await settle(tester);

      expect(find.text('"admin" is already taken.'), findsOneWidget);
    });

    testWidgets('the Field shows progress while the check runs', (
      tester,
    ) async {
      await pump(tester);

      await tester.enterText(find.byKey(const Key('username')), 'angelo');
      // The debounce has passed, the service has not answered yet.
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Checking username…'), findsOneWidget);

      await settle(tester);
      expect(find.text('Checking username…'), findsNothing);
    });

    testWidgets('submit moves the focus to the first invalid Field', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(submitButton);
      await settle(tester);

      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(
        find.descendant(
          of: find.byKey(const Key('username')),
          matching: find.byWidget(focused.widget),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a password that contains the username is rejected', (
      tester,
    ) async {
      await pump(tester);
      await fill(tester, password: 'angelo1234', confirmation: 'angelo1234');

      await tester.tap(submitButton);
      await settle(tester);

      expect(
        find.text('The password must not contain the username.'),
        findsOneWidget,
      );
      expect(find.text('Please fix the errors above.'), findsOneWidget);
    });

    testWidgets('the VAT Field is only available to companies', (tester) async {
      await pump(tester);

      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.byKey(const Key('vat')),
                matching: find.byType(EditableText),
              ),
            )
            .readOnly,
        isTrue,
      );

      await tester.tap(companyOption);
      await tester.pump();

      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.byKey(const Key('vat')),
                matching: find.byType(EditableText),
              ),
            )
            .readOnly,
        isFalse,
      );
    });

    testWidgets('the VAT number is required for a company only', (
      tester,
    ) async {
      await pump(tester);
      await fill(tester);

      await tester.tap(submitButton);
      await settle(tester);
      expect(find.text('Welcome, angelo!'), findsOneWidget);

      await tester.tap(companyOption);
      await tester.pump();
      await tester.tap(submitButton);
      await settle(tester);

      expect(find.text('This field is required.'), findsOneWidget);
      expect(find.text('Please fix the errors above.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('vat')), 'IT123');
      await tester.tap(submitButton);
      await settle(tester);

      expect(find.text('Welcome, angelo!'), findsOneWidget);
    });
  });
}

void main() {
  signUpFlows(
    name: 'Material',
    pump: (tester) => pumpMaterial(tester, const SignUpMaterialPage()),
    submitButton: find.widgetWithText(FilledButton, 'Sign up'),
    companyOption: find.text('Company'),
  );
  signUpFlows(
    name: 'Cupertino',
    pump: (tester) => pumpCupertino(tester, const SignUpCupertinoPage()),
    submitButton: find.widgetWithText(CupertinoButton, 'Sign up'),
    companyOption: find.text('Company'),
  );
}
