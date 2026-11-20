import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/survey/survey_cupertino.dart';
import 'package:formidable_example/survey/survey_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

void surveyFlows({
  required String name,
  required Future<void> Function(WidgetTester) pump,
  required Finder Function(String) button,
}) {
  group('survey with a Dynamic Form ($name)', () {
    testWidgets('has no answer Field until the questions arrive', (
      tester,
    ) async {
      await pump(tester);

      expect(find.byKey(const Key('answer-age')), findsNothing);

      await tester.tap(button('Load questions'));
      await tester.pump();

      expect(find.byKey(const Key('answer-age')), findsOneWidget);
      expect(find.byKey(const Key('answer-nickname')), findsOneWidget);
      expect(find.byKey(const Key('answer-newsletter')), findsOneWidget);
    });

    testWidgets('a required registered Field blocks the submit', (
      tester,
    ) async {
      await pump(tester);
      await tester.enterText(find.byKey(const Key('title')), 'Pets');
      await tester.tap(button('Load questions'));
      await tester.pump();

      await tester.tap(button('Save survey'));
      await settle(tester);

      expect(find.text('Please fix the errors above.'), findsOneWidget);
    });

    testWidgets('registered Fields validate like declared ones', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(button('Load questions'));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('answer-age')), '-1');
      await tester.tap(find.byKey(const Key('title')));
      await tester.pump();

      expect(find.text('Must be at least 0.'), findsOneWidget);
    });

    testWidgets('the answers are part of the output, by key', (tester) async {
      await pump(tester);
      await tester.enterText(find.byKey(const Key('title')), 'Pets');
      await tester.tap(button('Load questions'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('answer-age')), '7');

      await tester.tap(button('Save survey'));
      await settle(tester);

      expect(
        find.text('Thanks, Pets: {age: 7, nickname: null, newsletter: false}'),
        findsOneWidget,
      );
    });

    testWidgets('another questionnaire replaces the registered Fields', (
      tester,
    ) async {
      await pump(tester);
      await tester.enterText(find.byKey(const Key('title')), 'Pets');
      await tester.tap(button('Load questions'));
      await tester.pump();

      await tester.tap(button('Switch questionnaire'));
      await tester.pump();

      expect(find.byKey(const Key('answer-age')), findsNothing);
      expect(find.byKey(const Key('answer-city')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('answer-city')), 'Rome');
      await tester.tap(button('Save survey'));
      await settle(tester);

      expect(
        find.text('Thanks, Pets: {city: Rome, pets: false}'),
        findsOneWidget,
      );
    });
  });
}

void main() {
  surveyFlows(
    name: 'Material',
    pump: (tester) => pumpMaterial(tester, const SurveyMaterialPage()),
    button: (label) => find.widgetWithText(FilledButton, label),
  );
  surveyFlows(
    name: 'Cupertino',
    pump: (tester) => pumpCupertino(tester, const SurveyCupertinoPage()),
    button: (label) => find.widgetWithText(CupertinoButton, label),
  );
}
