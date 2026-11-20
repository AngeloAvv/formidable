import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/trip/trip_cupertino.dart';
import 'package:formidable_example/trip/trip_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

String _text(WidgetTester tester, Finder owner) => tester
    .widget<EditableText>(
      find.descendant(of: owner, matching: find.byType(EditableText)),
    )
    .controller
    .text;

/// The text of every place Field, in screen order.
List<String> _places(WidgetTester tester) {
  final rows = find.byWidgetPredicate(
    (widget) =>
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith('place-'),
  );
  return [
    for (final row in rows.evaluate()) _text(tester, find.byWidget(row.widget)),
  ];
}

void tripFlows({
  required String name,
  required Future<void> Function(WidgetTester) pump,
  required Finder saveButton,
}) {
  group('trip with Field Arrays ($name)', () {
    Future<void> addStop(WidgetTester tester, String place) async {
      await tester.tap(find.text('Add stop'));
      await tester.pump();
      final ids = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('place-'),
      );
      await tester.enterText(ids.last, place);
      await tester.pump();
    }

    testWidgets('a Form with no stop is invalid and says so', (tester) async {
      await pump(tester);
      await tester.enterText(find.byKey(const Key('name')), 'Italy');

      await tester.tap(saveButton);
      await settle(tester);

      expect(find.text('This field is required.'), findsOneWidget);
      expect(find.text('Please fix the errors above.'), findsOneWidget);
    });

    testWidgets('stops are added, filled and saved', (tester) async {
      await pump(tester);
      await tester.enterText(find.byKey(const Key('name')), 'Italy');
      await addStop(tester, 'Rome');
      await addStop(tester, 'Pisa');

      expect(_places(tester), ['Rome', 'Pisa']);

      await tester.tap(saveButton);
      await settle(tester);

      expect(find.text('Saved Italy: Rome, Pisa.'), findsOneWidget);
    });

    testWidgets('moving a stop keeps its text', (tester) async {
      await pump(tester);
      await addStop(tester, 'Rome');
      await addStop(tester, 'Pisa');

      await tester.tap(find.byKey(const Key('move-up-1')));
      await tester.pump();

      expect(_places(tester), ['Pisa', 'Rome']);
    });

    testWidgets('removing a stop keeps the others with their own text', (
      tester,
    ) async {
      await pump(tester);
      await addStop(tester, 'Rome');
      await addStop(tester, 'Pisa');
      await addStop(tester, 'Siena');

      await tester.tap(find.byKey(const Key('remove-0')));
      await tester.pump();

      expect(_places(tester), ['Pisa', 'Siena']);
    });

    testWidgets('the array judges the number of stops', (tester) async {
      await pump(tester);
      for (final place in ['Rome', 'Pisa', 'Siena', 'Turin']) {
        await addStop(tester, place);
      }

      expect(find.text('Must have at most 3 items (got 4).'), findsOneWidget);
    });

    testWidgets('tags are Fields of their own, with their own errors', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.text('Add tag'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('tag-0')), 'x');
      // Leave the Field so that its error shows.
      await tester.tap(find.byKey(const Key('name')));
      await tester.pump();

      expect(
        find.text('Must be at least 2 characters long (got 1).'),
        findsOneWidget,
      );
    });

    testWidgets('a trip with stops and a tag is saved', (tester) async {
      await pump(tester);
      await tester.enterText(find.byKey(const Key('name')), 'Italy');
      await addStop(tester, 'Rome');
      await tester.tap(find.text('Add tag'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('tag-0')), '  food ');

      await tester.tap(saveButton);
      await settle(tester);

      expect(find.text('Saved Italy: Rome.'), findsOneWidget);
    });
  });
}

void main() {
  tripFlows(
    name: 'Material',
    pump: (tester) => pumpMaterial(tester, const TripMaterialPage()),
    saveButton: find.widgetWithText(FilledButton, 'Save trip'),
  );
  tripFlows(
    name: 'Cupertino',
    pump: (tester) => pumpCupertino(tester, const TripCupertinoPage()),
    saveButton: find.widgetWithText(CupertinoButton, 'Save trip'),
  );
}
