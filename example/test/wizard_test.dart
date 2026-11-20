import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/wizard/wizard_cupertino.dart';
import 'package:formidable_example/wizard/wizard_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

void wizardFlows({
  required String name,
  required Future<void> Function(WidgetTester) pump,
  required Finder Function(String) button,
  required Future<void> Function(WidgetTester) acceptTerms,
}) {
  group('wizard ($name)', () {
    Future<void> fillTraveler(WidgetTester tester) async {
      await tester.enterText(find.byKey(const Key('traveler-name')), 'Ada');
      await tester.enterText(
        find.byKey(const Key('traveler-email')),
        'ada@example.com',
      );
    }

    Future<void> fillJourney(WidgetTester tester, {String to = 'Pisa'}) async {
      await tester.enterText(find.byKey(const Key('journey-from')), 'Rome');
      await tester.enterText(find.byKey(const Key('journey-to')), to);
      await tester.enterText(find.byKey(const Key('journey-passengers')), '2');
    }

    testWidgets('starts on the first step', (tester) async {
      await pump(tester);

      expect(find.text('Step 1 of 3: Traveler'), findsOneWidget);
      expect(find.byKey(const Key('journey-from')), findsNothing);
    });

    testWidgets('errors wait for the Next button, not for the Field blur', (
      tester,
    ) async {
      await pump(tester);

      await tester.enterText(find.byKey(const Key('traveler-name')), 'A');
      await tester.tap(find.byKey(const Key('traveler-email')));
      await tester.pump();
      expect(find.textContaining('Must be at least 2'), findsNothing);

      await tester.tap(button('Next'));
      await settle(tester);
      expect(find.textContaining('Must be at least 2'), findsOneWidget);
    });

    testWidgets('an invalid step does not advance and shows its errors', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(button('Next'));
      await settle(tester);

      expect(find.text('Step 1 of 3: Traveler'), findsOneWidget);
      expect(find.text('This field is required.'), findsNWidgets(2));
    });

    testWidgets('a valid step advances and Back keeps what was typed', (
      tester,
    ) async {
      await pump(tester);
      await fillTraveler(tester);

      await tester.tap(button('Next'));
      await settle(tester);
      expect(find.text('Step 2 of 3: Journey'), findsOneWidget);

      await tester.tap(button('Back'));
      await settle(tester);
      expect(find.text('Step 1 of 3: Traveler'), findsOneWidget);
      expect(find.text('Ada'), findsOneWidget);
    });

    testWidgets('a cross-field rule holds a step back', (tester) async {
      await pump(tester);
      await fillTraveler(tester);
      await tester.tap(button('Next'));
      await settle(tester);
      await fillJourney(tester, to: 'Rome');

      await tester.tap(button('Next'));
      await settle(tester);

      expect(find.text('Step 2 of 3: Journey'), findsOneWidget);
      expect(
        find.text('Must be different from the other value.'),
        findsOneWidget,
      );
    });

    testWidgets('the last step books once the terms are accepted', (
      tester,
    ) async {
      await pump(tester);
      await fillTraveler(tester);
      await tester.tap(button('Next'));
      await settle(tester);
      await fillJourney(tester);
      await tester.tap(button('Next'));
      await settle(tester);
      expect(find.text('Step 3 of 3: Confirm'), findsOneWidget);
      expect(find.text('Ada, Rome to Pisa, 2 passengers'), findsOneWidget);

      await tester.tap(button('Book'));
      await settle(tester);
      expect(find.text('Must be accepted.'), findsOneWidget);
      expect(find.text('Booked for Ada: Rome to Pisa.'), findsNothing);

      await acceptTerms(tester);
      await tester.tap(button('Book'));
      await settle(tester);
      expect(find.text('Booked for Ada: Rome to Pisa.'), findsOneWidget);
    });
  });
}

void main() {
  wizardFlows(
    name: 'Material',
    pump: (tester) => pumpMaterial(tester, const WizardMaterialPage()),
    button: (label) => find.widgetWithText(FilledButton, label),
    acceptTerms: (tester) async {
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
    },
  );
  wizardFlows(
    name: 'Cupertino',
    pump: (tester) => pumpCupertino(tester, const WizardCupertinoPage()),
    button: (label) => find.widgetWithText(CupertinoButton, label),
    acceptTerms: (tester) async {
      await tester.tap(find.byType(CupertinoCheckbox));
      await tester.pump();
    },
  );
}
