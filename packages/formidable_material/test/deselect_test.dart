import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

/// Seam 2: deselecting is a choice. When the user deselects and the type of
/// the Field admits null, null is written as a chosen value, so the Field is
/// set and dirty. When it does not, null cannot be written and the Field falls
/// back to Unset (still touched).
void main() {
  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('FormidableMaterialRadioGroup with toggleable', () {
    List<FormidableMaterialRadioOption<T>> options<T>() => [
      FormidableMaterialRadioOption<T>(
        value: 'free' as T,
        title: const Text('Free'),
      ),
      FormidableMaterialRadioOption<T>(
        value: 'pro' as T,
        title: const Text('Pro'),
      ),
    ];

    testWidgets('a nullable Field chooses null, which is dirty', (
      tester,
    ) async {
      final plan = FormidableField<String?>();
      addTearDown(plan.dispose);
      await tester.pumpWidget(
        app(
          FormidableMaterialRadioGroup<String?>(
            field: plan,
            options: options<String?>(),
            toggleable: true,
          ),
        ),
      );

      await tester.tap(find.text('Pro'));
      await tester.pump();
      await tester.tap(find.text('Pro'));
      await tester.pump();

      expect(plan.isSet, isTrue);
      expect(plan.value, isNull);
      expect(plan.state.dirty, isTrue);
      expect(plan.state.touched, isTrue);
    });

    testWidgets('a nullable Field with an initial value is dirty too', (
      tester,
    ) async {
      final plan = FormidableField<String?>(initial: (value: 'pro'));
      addTearDown(plan.dispose);
      await tester.pumpWidget(
        app(
          FormidableMaterialRadioGroup<String?>(
            field: plan,
            options: options<String?>(),
            toggleable: true,
          ),
        ),
      );
      expect(plan.state.dirty, isFalse);

      await tester.tap(find.text('Pro'));
      await tester.pump();

      expect(plan.isSet, isTrue);
      expect(plan.value, isNull);
      expect(plan.state.dirty, isTrue);
    });

    testWidgets('a non-nullable Field falls back to Unset, touched', (
      tester,
    ) async {
      final plan = FormidableField<String>();
      addTearDown(plan.dispose);
      await tester.pumpWidget(
        app(
          FormidableMaterialRadioGroup<String>(
            field: plan,
            options: options<String>(),
            toggleable: true,
          ),
        ),
      );

      await tester.tap(find.text('Pro'));
      await tester.pump();
      await tester.tap(find.text('Pro'));
      await tester.pump();

      expect(plan.isSet, isFalse);
      expect(plan.state.touched, isTrue);
    });
  });

  group('FormidableMaterialSegmentedButton with allowDeselect', () {
    List<ButtonSegment<T>> segments<T>() => [
      ButtonSegment<T>(value: 'free' as T, label: const Text('Free')),
      ButtonSegment<T>(value: 'pro' as T, label: const Text('Pro')),
    ];

    testWidgets('a nullable Field chooses null, which is dirty', (
      tester,
    ) async {
      final plan = FormidableField<String?>();
      addTearDown(plan.dispose);
      await tester.pumpWidget(
        app(
          FormidableMaterialSegmentedButton<String?>(
            field: plan,
            segments: segments<String?>(),
            allowDeselect: true,
          ),
        ),
      );

      await tester.tap(find.text('Pro'));
      await tester.pump();
      await tester.tap(find.text('Pro'));
      await tester.pump();

      expect(plan.isSet, isTrue);
      expect(plan.value, isNull);
      expect(plan.state.dirty, isTrue);
      expect(plan.state.touched, isTrue);
    });

    testWidgets('a non-nullable Field falls back to Unset, touched', (
      tester,
    ) async {
      final plan = FormidableField<String>();
      addTearDown(plan.dispose);
      await tester.pumpWidget(
        app(
          FormidableMaterialSegmentedButton<String>(
            field: plan,
            segments: segments<String>(),
            allowDeselect: true,
          ),
        ),
      );

      await tester.tap(find.text('Pro'));
      await tester.pump();
      await tester.tap(find.text('Pro'));
      await tester.pump();

      expect(plan.isSet, isFalse);
      expect(plan.state.touched, isTrue);
    });
  });

  group('tristate checkboxes', () {
    Future<void> tapThroughToNull(WidgetTester tester, Finder box) async {
      // Unset shows unchecked: false -> true -> null is three taps from
      // Unset, but the first tap goes to true.
      await tester.tap(box); // -> true
      await tester.pump();
      await tester.tap(box); // -> null
      await tester.pump();
    }

    testWidgets('FormidableMaterialCheckbox: a nullable Field chooses null', (
      tester,
    ) async {
      final beta = FormidableField<bool?>();
      addTearDown(beta.dispose);
      await tester.pumpWidget(
        app(FormidableMaterialCheckbox<bool?>(field: beta, tristate: true)),
      );

      await tapThroughToNull(tester, find.byType(Checkbox));

      expect(beta.isSet, isTrue);
      expect(beta.value, isNull);
      expect(beta.state.dirty, isTrue);
      expect(beta.state.touched, isTrue);
    });

    testWidgets('FormidableMaterialCheckbox: a non-nullable Field is Unset', (
      tester,
    ) async {
      final beta = FormidableField<bool>();
      addTearDown(beta.dispose);
      await tester.pumpWidget(
        app(FormidableMaterialCheckbox<bool>(field: beta, tristate: true)),
      );

      await tapThroughToNull(tester, find.byType(Checkbox));

      expect(beta.isSet, isFalse);
      expect(beta.state.touched, isTrue);
    });

    testWidgets(
      'FormidableMaterialCheckboxListTile: a nullable Field chooses null',
      (tester) async {
        final beta = FormidableField<bool?>();
        addTearDown(beta.dispose);
        await tester.pumpWidget(
          app(
            FormidableMaterialCheckboxListTile<bool?>(
              field: beta,
              tristate: true,
              title: const Text('Beta'),
            ),
          ),
        );

        await tapThroughToNull(tester, find.byType(Checkbox));

        expect(beta.isSet, isTrue);
        expect(beta.value, isNull);
        expect(beta.state.dirty, isTrue);
        expect(beta.state.touched, isTrue);
      },
    );

    testWidgets(
      'FormidableMaterialCheckboxListTile: a non-nullable Field is Unset',
      (tester) async {
        final beta = FormidableField<bool>();
        addTearDown(beta.dispose);
        await tester.pumpWidget(
          app(
            FormidableMaterialCheckboxListTile<bool>(
              field: beta,
              tristate: true,
              title: const Text('Beta'),
            ),
          ),
        );

        await tapThroughToNull(tester, find.byType(Checkbox));

        expect(beta.isSet, isFalse);
        expect(beta.state.touched, isTrue);
      },
    );
  });
}
