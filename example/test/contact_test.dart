import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/contact/contact_cupertino.dart';
import 'package:formidable_example/contact/contact_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

String _textOf(WidgetTester tester, String key) {
  final editable = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(EditableText),
  );
  return tester.widget<EditableText>(editable).controller.text;
}

void contactFlows({
  required String name,
  required Future<void> Function(WidgetTester) pump,
  required Finder saveButton,
  required Finder discardChoice,
  required Future<void> Function(WidgetTester) back,
}) {
  group('edit contact ($name)', () {
    Future<void> openEditor(WidgetTester tester) async {
      await pump(tester);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
    }

    bool saveEnabled(WidgetTester tester) {
      final button = tester.widget(saveButton);
      return switch (button) {
        FilledButton(:final onPressed) => onPressed != null,
        CupertinoButton(:final onPressed) => onPressed != null,
        _ => throw StateError('not a button'),
      };
    }

    testWidgets('the summary shows the saved contact', (tester) async {
      await pump(tester);

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('1 Main St, RM, IT'), findsOneWidget);
    });

    testWidgets('the editor starts from the saved contact with Save off', (
      tester,
    ) async {
      await openEditor(tester);

      expect(_textOf(tester, 'name'), 'Ada Lovelace');
      expect(_textOf(tester, 'street'), '1 Main St');
      expect(_textOf(tester, 'province'), 'RM');
      expect(saveEnabled(tester), isFalse);
    });

    testWidgets('Save is on while the Form is valid and has changes', (
      tester,
    ) async {
      await openEditor(tester);

      await tester.enterText(find.byKey(const Key('name')), 'Ada King');
      await tester.pump();
      expect(saveEnabled(tester), isTrue);

      await tester.enterText(find.byKey(const Key('name')), 'A');
      await tester.pump();
      expect(saveEnabled(tester), isFalse);
    });

    testWidgets('saving commits: the Form is clean and the summary updates', (
      tester,
    ) async {
      await openEditor(tester);
      await tester.enterText(find.byKey(const Key('name')), 'Ada King');
      await tester.pump();

      await tester.tap(saveButton);
      await tester.pump();

      expect(saveEnabled(tester), isFalse);
      expect(find.text('Saved.'), findsOneWidget);

      // Clean: the screen is left without asking.
      await back(tester);
      await tester.pumpAndSettle();
      expect(find.text('Ada King'), findsOneWidget);
    });

    testWidgets('changing the country clears the province', (tester) async {
      await openEditor(tester);

      await tester.tap(find.text('France'));
      await tester.pump();

      expect(_textOf(tester, 'province'), isEmpty);
    });

    testWidgets('a service error is applied to the Field it belongs to', (
      tester,
    ) async {
      await openEditor(tester);

      await tester.enterText(
        find.byKey(const Key('email')),
        'taken@example.com',
      );
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('That email is already registered.'), findsOneWidget);
      expect(saveEnabled(tester), isFalse);

      // The applied error clears with the next change to the Field.
      await tester.enterText(
        find.byKey(const Key('email')),
        'free@example.com',
      );
      await tester.pump();
      expect(find.text('That email is already registered.'), findsNothing);
      expect(saveEnabled(tester), isTrue);
    });

    testWidgets('patch writes only the Fields it is given', (tester) async {
      await openEditor(tester);

      await tester.tap(find.text('Use a sample name'));
      await tester.pump();

      expect(_textOf(tester, 'name'), 'Grace Hopper');
      expect(_textOf(tester, 'street'), '1 Main St');
      expect(saveEnabled(tester), isTrue);
    });

    testWidgets('a Passthrough Field travels with the contact untouched', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Contact #7'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('name')), 'Ada King');
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();
      await back(tester);
      await tester.pumpAndSettle();

      expect(find.text('Contact #7'), findsOneWidget);
      expect(find.text('Ada King'), findsOneWidget);
    });

    testWidgets('reset brings back the saved values', (tester) async {
      await openEditor(tester);
      await tester.enterText(find.byKey(const Key('name')), 'Ada King');
      await tester.pump();

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(_textOf(tester, 'name'), 'Ada Lovelace');
      expect(saveEnabled(tester), isFalse);
    });

    testWidgets('leaving with unsaved changes asks first', (tester) async {
      await openEditor(tester);
      await tester.enterText(find.byKey(const Key('name')), 'Ada King');
      await tester.pump();

      await back(tester);
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.byKey(const Key('name')), findsOneWidget);

      await back(tester);
      await tester.pumpAndSettle();
      await tester.tap(discardChoice);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('name')), findsNothing);
      expect(find.text('Ada Lovelace'), findsOneWidget);
    });
  });
}

void main() {
  contactFlows(
    name: 'Material',
    pump: (tester) => pumpMaterial(tester, const ContactMaterialPage()),
    saveButton: find.widgetWithText(FilledButton, 'Save'),
    discardChoice: find.widgetWithText(TextButton, 'Discard'),
    back: (tester) => tester.pageBack(),
  );
  contactFlows(
    name: 'Cupertino',
    pump: (tester) => pumpCupertino(tester, const ContactCupertinoPage()),
    saveButton: find.widgetWithText(CupertinoButton, 'Save'),
    discardChoice: find.widgetWithText(CupertinoDialogAction, 'Discard'),
    // `pageBack` knows only the back button of the framework's own Cupertino
    // library, not the one of `cupertino_ui`.
    back: (tester) => tester.tap(find.byType(CupertinoNavigationBarBackButton)),
  );
}
