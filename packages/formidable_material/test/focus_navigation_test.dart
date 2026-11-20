import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/shipping.dart';
import 'support/shipping.formidable_scope.dart';

/// Seam 2: keyboard actions and focus navigation in Schema declaration order,
/// seen through real widgets over a generated Form.
void main() {
  late ShippingForm form;

  Widget app(Widget Function(BuildContext context) body) => MaterialApp(
    home: Scaffold(
      body: ShippingFormScope(
        create: () => form = ShippingForm(),
        child: Builder(builder: (context) => Column(children: [body(context)])),
      ),
    ),
  );

  Finder input(String label) => find.widgetWithText(TextField, label);

  TextInputAction? actionOf(WidgetTester tester, String label) =>
      tester.widget<TextField>(input(label)).textInputAction;

  Future<void> pumpAll(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pump();
  }

  Widget threeFields() => app(
    (context) => Column(
      children: [
        FormidableTextField<String>(
          field: context.shippingForm.name,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        FormidableTextField<String>(
          field: context.shippingForm.street,
          decoration: const InputDecoration(labelText: 'Street'),
        ),
        FormidableTextField<String>(
          field: context.shippingForm.city,
          decoration: const InputDecoration(labelText: 'City'),
        ),
      ],
    ),
  );

  group('keyboard actions', () {
    testWidgets('are next, and done on the last bound Field', (tester) async {
      await pumpAll(tester, threeFields());

      expect(actionOf(tester, 'Name'), TextInputAction.next);
      expect(actionOf(tester, 'Street'), TextInputAction.next);
      expect(actionOf(tester, 'City'), TextInputAction.done);
    });
  });

  Widget fields(
    List<String> names, {
    FocusNode? Function(String)? focusNodes,
  }) => app((context) {
    final form = context.shippingForm;
    final byName = {
      'Name': form.name,
      'Street': form.street,
      'City': form.city,
    };
    return Column(
      children: [
        for (final name in names)
          FormidableTextField<String>(
            key: Key(name),
            field: byName[name]!,
            focusNode: focusNodes?.call(name),
            decoration: InputDecoration(labelText: name),
          ),
      ],
    );
  });

  bool hasFocus(WidgetTester tester, String label) => tester
      .widget<EditableText>(
        find.descendant(of: input(label), matching: find.byType(EditableText)),
      )
      .focusNode
      .hasFocus;

  Future<void> focus(WidgetTester tester, String label) async {
    await tester.tap(input(label));
    await tester.pump();
  }

  Future<void> press(WidgetTester tester, TextInputAction action) async {
    await tester.testTextInput.receiveAction(action);
    await tester.pump();
  }

  group('moving focus', () {
    testWidgets('next moves to the next Field, done closes the keyboard', (
      tester,
    ) async {
      await pumpAll(tester, threeFields());

      await focus(tester, 'Name');
      await press(tester, TextInputAction.next);
      expect(hasFocus(tester, 'Street'), isTrue);

      await press(tester, TextInputAction.next);
      expect(hasFocus(tester, 'City'), isTrue);

      await press(tester, TextInputAction.done);
      expect(hasFocus(tester, 'City'), isFalse);
    });

    testWidgets('skips Fields that have no widget', (tester) async {
      await pumpAll(tester, fields(['Name', 'City']));

      expect(actionOf(tester, 'Name'), TextInputAction.next);
      await focus(tester, 'Name');
      await press(tester, TextInputAction.next);

      expect(hasFocus(tester, 'City'), isTrue);
    });

    testWidgets('skips disabled Fields', (tester) async {
      await pumpAll(tester, threeFields());
      form.street.disable();
      await tester.pump();

      await focus(tester, 'Name');
      await press(tester, TextInputAction.next);

      expect(hasFocus(tester, 'City'), isTrue);
    });

    testWidgets('the last Field is done again once the one after it goes', (
      tester,
    ) async {
      await pumpAll(tester, threeFields());
      form.city.disable();
      await tester.pump();

      expect(actionOf(tester, 'Street'), TextInputAction.done);
      form.city.enable();
      await tester.pump();
      expect(actionOf(tester, 'Street'), TextInputAction.next);
    });

    testWidgets('follows widgets added and removed later', (tester) async {
      await pumpAll(tester, fields(['Name', 'Street']));
      expect(actionOf(tester, 'Street'), TextInputAction.done);

      await pumpAll(tester, fields(['Name', 'Street', 'City']));
      expect(actionOf(tester, 'Street'), TextInputAction.next);

      await pumpAll(tester, fields(['Name', 'Street']));
      expect(actionOf(tester, 'Street'), TextInputAction.done);
    });
  });

  group('overrides', () {
    testWidgets('a widget can set its own keyboard action', (tester) async {
      await pumpAll(
        tester,
        app(
          (context) => Column(
            children: [
              FormidableTextField<String>(
                field: context.shippingForm.name,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              FormidableTextField<String>(
                field: context.shippingForm.street,
                decoration: const InputDecoration(labelText: 'Street'),
              ),
            ],
          ),
        ),
      );

      expect(actionOf(tester, 'Name'), TextInputAction.search);
      expect(actionOf(tester, 'Street'), TextInputAction.done);
    });

    testWidgets('a widget can replace the focus behaviour', (tester) async {
      var completed = 0;
      await pumpAll(
        tester,
        app(
          (context) => Column(
            children: [
              FormidableTextField<String>(
                field: context.shippingForm.name,
                onEditingComplete: () => completed++,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              FormidableTextField<String>(
                field: context.shippingForm.street,
                decoration: const InputDecoration(labelText: 'Street'),
              ),
            ],
          ),
        ),
      );

      await focus(tester, 'Name');
      await press(tester, TextInputAction.next);

      expect(completed, 1);
      expect(hasFocus(tester, 'Street'), isFalse);
    });
  });

  group('several widgets on one Field', () {
    Widget twoOnName() => app(
      (context) => Column(
        children: [
          FormidableTextField<String>(
            field: context.shippingForm.name,
            decoration: const InputDecoration(labelText: 'First'),
          ),
          FormidableTextField<String>(
            field: context.shippingForm.name,
            decoration: const InputDecoration(labelText: 'Second'),
          ),
          FormidableTextField<String>(
            field: context.shippingForm.street,
            decoration: const InputDecoration(labelText: 'Street'),
          ),
        ],
      ),
    );

    testWidgets('stay in sync', (tester) async {
      await pumpAll(tester, twoOnName());

      await tester.enterText(input('First'), 'Angelo');
      await tester.pump();

      expect(
        tester.widget<TextField>(input('Second')).controller!.text,
        'Angelo',
      );
      expect(form.name.value, 'Angelo');
    });

    testWidgets('give focus to the most recently registered one', (
      tester,
    ) async {
      await pumpAll(tester, twoOnName());

      form.name.focus();
      await tester.pump();

      expect(hasFocus(tester, 'Second'), isTrue);
      expect(hasFocus(tester, 'First'), isFalse);
    });

    testWidgets('only the Field after them is next', (tester) async {
      await pumpAll(tester, twoOnName());

      await focus(tester, 'Second');
      await press(tester, TextInputAction.next);

      expect(hasFocus(tester, 'Street'), isTrue);
    });
  });

  group('ownership', () {
    testWidgets('a passed focus node and controller are never disposed', (
      tester,
    ) async {
      final focusNode = FocusNode();
      final controller = TextEditingController();
      addTearDown(focusNode.dispose);
      addTearDown(controller.dispose);

      await pumpAll(
        tester,
        app(
          (context) => FormidableTextFieldWidget<String>(
            field: context.shippingForm.name,
            focusNode: focusNode,
            textController: controller,
            builder: (context, control) => TextField(
              focusNode: control.focusNode,
              controller: control.textController,
            ),
          ),
        ),
      );
      await tester.pumpWidget(const SizedBox());

      // A disposed notifier throws on addListener.
      focusNode.addListener(() {});
      controller.addListener(() {});
    });

    testWidgets('the widget disposes the ones it created', (tester) async {
      late FormidableTextFieldWidgetState<String> control;
      await pumpAll(
        tester,
        app(
          (context) => FormidableTextFieldWidget<String>(
            field: context.shippingForm.name,
            builder: (context, c) {
              control = c;
              return TextField(
                focusNode: c.focusNode,
                controller: c.textController,
              );
            },
          ),
        ),
      );
      final focusNode = control.focusNode;
      final controller = control.textController;
      await tester.pumpWidget(const SizedBox());

      expect(() => focusNode.addListener(() {}), throwsFlutterError);
      expect(() => controller.addListener(() {}), throwsFlutterError);
    });
  });

  testWidgets('a multiline field keeps its newline key', (tester) async {
    await pumpAll(
      tester,
      app(
        (context) => Column(
          children: [
            FormidableTextField<String>(
              field: context.shippingForm.name,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            FormidableTextField<String>(
              field: context.shippingForm.street,
              decoration: const InputDecoration(labelText: 'Street'),
            ),
          ],
        ),
      ),
    );

    expect(actionOf(tester, 'Name'), isNull);
  });
}
