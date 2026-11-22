import 'dart:ui' show CheckedState;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';

import 'support/harness.dart';
import 'support/profile.dart';

/// Seam 2: the widgets that pick one of a few choices, and the slider. None
/// of them takes focus, so the first interaction touches the Field.
void main() {
  late ProfileForm form;

  Future<void> pump(WidgetTester tester, Widget Function(ProfileForm) field) =>
      tester.pumpWidget(
        profileApp(
          field,
          create: () => ProfileForm(username: 'angelo', plan: 'free'),
          onForm: (f) => form = f,
        ),
      );

  const plans = {
    'free': Text('Free'),
    'pro': Text('Pro'),
    'team': Text('Team'),
  };

  group('FormidableCupertinoSegmentedControl', () {
    testWidgets('shows the value and follows the Field', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoSegmentedControl<String>(
          field: form.plan,
          children: plans,
        ),
      );
      CupertinoSegmentedControl<String> control() =>
          tester.widget<CupertinoSegmentedControl<String>>(
            find.byType(CupertinoSegmentedControl<String>),
          );
      expect(control().groupValue, 'free');

      form.plan.setValue('team');
      await tester.pump();

      expect(control().groupValue, 'team');
    });

    testWidgets('a tap sets the Field and touches it', (tester) async {
      await pump(
        tester,
        (form) => FormidableCupertinoSegmentedControl<String>(
          field: form.plan,
          children: plans,
        ),
      );
      expect(form.plan.state.touched, isFalse);

      await tester.tap(find.text('Pro'));
      await tester.pumpAndSettle();

      expect(form.plan.value, 'pro');
      expect(form.plan.state.touched, isTrue);
    });
  });

  group('FormidableCupertinoSlidingSegmentedControl', () {
    testWidgets('shows the value and a tap sets the Field and touches it', (
      tester,
    ) async {
      await pump(
        tester,
        (form) => FormidableCupertinoSlidingSegmentedControl<String>(
          field: form.plan,
          children: plans,
        ),
      );
      CupertinoSlidingSegmentedControl<String> control() =>
          tester.widget<CupertinoSlidingSegmentedControl<String>>(
            find.byType(CupertinoSlidingSegmentedControl<String>),
          );
      expect(control().groupValue, 'free');

      await tester.tap(find.text('Team'));
      await tester.pumpAndSettle();

      expect(form.plan.value, 'team');
      expect(form.plan.state.touched, isTrue);
      expect(control().groupValue, 'team');
    });
  });

  group('FormidableCupertinoRadioGroup', () {
    Widget radios(ProfileForm form) => FormidableCupertinoRadioGroup<String>(
      field: form.plan,
      child: const Column(
        children: [
          CupertinoRadio<String>(value: 'free'),
          CupertinoRadio<String>(value: 'pro'),
        ],
      ),
    );

    testWidgets('selects the radio of the value and follows the Field', (
      tester,
    ) async {
      await pump(tester, radios);
      final semantics = tester.ensureSemantics();
      bool selected(String value) =>
          tester
              .getSemantics(
                find.byWidgetPredicate(
                  (w) => w is CupertinoRadio<String> && w.value == value,
                ),
              )
              .flagsCollection
              .isChecked ==
          CheckedState.isTrue;
      expect(selected('free'), isTrue);

      form.plan.setValue('pro');
      await tester.pump();

      expect(selected('pro'), isTrue);
      expect(selected('free'), isFalse);
      semantics.dispose();
    });

    testWidgets('a tap sets the Field and touches it', (tester) async {
      await pump(tester, radios);

      await tester.tap(find.byType(CupertinoRadio<String>).last);
      await tester.pumpAndSettle();

      expect(form.plan.value, 'pro');
      expect(form.plan.state.touched, isTrue);
    });
  });

  group('FormidableCupertinoSlider', () {
    Widget slider(ProfileForm form) =>
        FormidableCupertinoSlider(field: form.volume, max: 10);

    CupertinoSlider current(WidgetTester tester) =>
        tester.widget<CupertinoSlider>(find.byType(CupertinoSlider));

    testWidgets('an Unset Field shows the minimum and stays Unset', (
      tester,
    ) async {
      await pump(tester, slider);

      expect(current(tester).value, 0);
      expect(form.volume.defined, isFalse);
    });

    testWidgets('dragging sets the Field and touches it', (tester) async {
      await pump(tester, slider);

      final thumb =
          tester.getCenter(find.byType(CupertinoSlider)) - const Offset(80, 0);
      final gesture = await tester.startGesture(thumb);
      await gesture.moveBy(const Offset(60, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(form.volume.defined, isTrue);
      expect(form.volume.value, greaterThan(0));
      expect(form.volume.state.touched, isTrue);
    });

    testWidgets('follows the Field', (tester) async {
      await pump(tester, slider);

      form.volume.setValue(4);
      await tester.pump();

      expect(current(tester).value, 4);
    });
  });
}
