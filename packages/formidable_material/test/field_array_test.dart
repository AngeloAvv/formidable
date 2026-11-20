import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/trip.dart';
import 'support/trip.formidable_scope.dart';

/// Seam 2: the Field Array Builder over a generated Form, and the keyboard and
/// submit focus order through Nested Forms and Field Array items.
void main() {
  late TripForm form;

  Widget stopRow(StopForm stop, int index) => Row(
    children: [
      Expanded(
        child: FormidableTextField<String>(
          field: stop.place,
          decoration: InputDecoration(labelText: 'Place ${index + 1}'),
        ),
      ),
      Expanded(
        child: FormidableTextField<String?>(
          field: stop.note,
          decoration: InputDecoration(labelText: 'Note ${index + 1}'),
        ),
      ),
    ],
  );

  Widget app({bool all = false}) => MaterialApp(
    home: Scaffold(
      body: TripFormScope(
        create: () => form = TripForm(),
        child: Builder(
          builder: (context) {
            final trip = context.tripForm;
            return SingleChildScrollView(
              child: Column(
                children: [
                  FormidableTextField<String>(
                    field: trip.title,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  FormidableTextField<String>(
                    field: trip.origin.street,
                    decoration: const InputDecoration(labelText: 'Street'),
                  ),
                  FormidableTextField<String>(
                    field: trip.origin.city,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  FormidableFieldArrayBuilder(
                    array: trip.stops,
                    itemBuilder: (context, index, item) =>
                        stopRow(item.node, index),
                    builder: (context, state, items) => Column(
                      children: [
                        Text('stops: ${state.length}'),
                        if (state.errors.isNotEmpty)
                          Text('errors: ${state.errors.length}'),
                        ...items,
                      ],
                    ),
                  ),
                  FormidableTextField<String?>(
                    field: trip.memo,
                    decoration: const InputDecoration(labelText: 'Memo'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );

  Finder input(String label) => find.widgetWithText(TextField, label);

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await tester.pump();
  }

  EditableText editable(WidgetTester tester, String label) =>
      tester.widget<EditableText>(
        find.descendant(of: input(label), matching: find.byType(EditableText)),
      );

  bool hasFocus(WidgetTester tester, String label) =>
      editable(tester, label).focusNode.hasFocus;

  Future<void> press(WidgetTester tester, TextInputAction action) async {
    await tester.testTextInput.receiveAction(action);
    await tester.pump();
  }

  group('FormidableFieldArrayBuilder', () {
    testWidgets('renders the current items without an empty first frame', (
      tester,
    ) async {
      await pumpApp(tester);
      form.stops.add(const Stop(place: 'Rome'));
      await tester.pump();

      expect(find.text('stops: 1'), findsOneWidget);
      expect(input('Place 1'), findsOneWidget);
    });

    testWidgets('adds and removes rows when items come and go', (tester) async {
      await pumpApp(tester);

      form.stops.add();
      form.stops.add();
      await tester.pump();
      expect(find.text('stops: 2'), findsOneWidget);
      expect(input('Place 2'), findsOneWidget);

      form.stops.removeAt(0);
      await tester.pump();
      expect(find.text('stops: 1'), findsOneWidget);
      expect(input('Place 2'), findsNothing);
    });

    testWidgets('rows keep their state and focus when items are moved', (
      tester,
    ) async {
      await pumpApp(tester);
      form.stops
        ..add(const Stop(place: 'Rome'))
        ..add(const Stop(place: 'Milan'));
      await tester.pump();

      await tester.tap(input('Place 1'));
      await tester.pump();
      expect(hasFocus(tester, 'Place 1'), isTrue);

      form.stops.move(0, 1);
      await tester.pump();

      // The row of Rome moved to second place and still has the focus.
      expect(editable(tester, 'Place 1').controller.text, 'Milan');
      expect(editable(tester, 'Place 2').controller.text, 'Rome');
      expect(hasFocus(tester, 'Place 2'), isTrue);
      expect(hasFocus(tester, 'Place 1'), isFalse);
    });

    testWidgets('typing in a row writes to its item', (tester) async {
      await pumpApp(tester);
      form.stops.add();
      form.stops.add();
      await tester.pump();

      await tester.enterText(input('Place 2'), 'Turin');

      expect(form.stops.items[1].node.place.value, 'Turin');
      expect(form.stops.items[0].node.place.isSet, isFalse);
    });

    testWidgets('shows the errors of the array itself', (tester) async {
      await pumpApp(tester);
      // Empty: the array is Unset and required.
      expect(find.text('errors: 1'), findsOneWidget);

      form.stops.add(const Stop(place: 'Rome'));
      await tester.pump();
      // One item: MinItems(2) is not satisfied.
      expect(find.text('errors: 1'), findsOneWidget);

      form.stops.add(const Stop(place: 'Milan'));
      await tester.pump();
      expect(find.text('errors: 1'), findsNothing);
    });
  });

  group('focus order through Nested Forms and Field Array items', () {
    Future<void> fill(WidgetTester tester) async {
      await pumpApp(tester);
      form.stops
        ..add()
        ..add();
      await tester.pump();
      await tester.pump();
    }

    testWidgets('keyboard next follows the tree order', (tester) async {
      await fill(tester);

      final order = [
        'Title',
        'Street',
        'City',
        'Place 1',
        'Note 1',
        'Place 2',
        'Note 2',
        'Memo',
      ];
      await tester.tap(input(order.first));
      await tester.pump();
      for (final label in order.skip(1)) {
        await press(tester, TextInputAction.next);
        expect(hasFocus(tester, label), isTrue, reason: 'next -> $label');
      }
    });

    testWidgets('the last Field in the tree is done, the others next', (
      tester,
    ) async {
      await fill(tester);

      TextInputAction? action(String label) =>
          tester.widget<TextField>(input(label)).textInputAction;

      expect(action('City'), TextInputAction.next);
      expect(action('Note 2'), TextInputAction.next);
      expect(action('Memo'), TextInputAction.done);
    });

    testWidgets('a new item is part of the order', (tester) async {
      await fill(tester);
      form.stops.add();
      await tester.pump();
      await tester.pump();

      await tester.tap(input('Note 2'));
      await tester.pump();
      await press(tester, TextInputAction.next);

      expect(hasFocus(tester, 'Place 3'), isTrue);
    });

    testWidgets('a moved item changes the order with it', (tester) async {
      await fill(tester);
      form.stops.items[0].node.place.setValue('Rome');
      form.stops.move(0, 1);
      await tester.pump();
      await tester.pump();

      await tester.tap(input('Note 1'));
      await tester.pump();
      await press(tester, TextInputAction.next);

      // The item that was first (Rome) is second now.
      expect(editable(tester, 'Place 2').controller.text, 'Rome');
      expect(hasFocus(tester, 'Place 2'), isTrue);
    });

    testWidgets('submit focuses the first invalid Field in tree order', (
      tester,
    ) async {
      await fill(tester);
      form.title.setValue('Trip');
      form.origin.street.setValue('Via Roma');
      form.origin.city.setValue('Rome');
      form.stops.items[0].node.place.setValue('Rome');
      form.stops.items[0].node.note.setValue('x');
      // Item 2 is invalid (its place is Unset), and so is nothing before it.
      form.submit();
      await tester.pump();

      expect(hasFocus(tester, 'Place 2'), isTrue);
    });

    testWidgets('submit focuses a Field of a Nested Form before the array', (
      tester,
    ) async {
      await fill(tester);
      form.title.setValue('Trip');
      form.origin.street.setValue('Via Roma');
      // origin.city, the items' places and nothing else are invalid.
      form.submit();
      await tester.pump();

      expect(hasFocus(tester, 'City'), isTrue);
    });
  });
}
