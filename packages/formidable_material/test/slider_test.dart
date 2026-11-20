import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';
import 'support/preferences.dart';

/// Seam 2 for the slider.
void main() {
  late PreferencesForm form;

  Widget app(Widget Function(PreferencesForm form) field) =>
      preferencesApp(field, onCreated: (created) => form = created);

  double thumb(WidgetTester tester) =>
      tester.widget<Slider>(find.byType(Slider)).value;

  group('FormidableSlider', () {
    testWidgets('rests at min while the Field is Unset, and stays Unset', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableSlider(field: form.volume, min: 2, max: 8)),
      );

      expect(thumb(tester), 2);
      expect(form.volume.isSet, isFalse);
    });

    testWidgets('shows the value of the Field, kept within min and max', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableSlider(field: form.volume, max: 10)),
      );

      form.volume.setValue(4);
      await tester.pump();
      expect(thumb(tester), 4);

      form.volume.setValue(40);
      await tester.pump();
      expect(thumb(tester), 10);
    });

    testWidgets('sets the Field and marks it touched when the user moves it', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableSlider(field: form.volume, max: 10)),
      );
      expect(form.volume.state.touched, isFalse);

      await tester.tapAt(tester.getCenter(find.byType(Slider)));
      await tester.pump();

      expect(form.volume.isSet, isTrue);
      expect(form.volume.value, closeTo(5, 0.1));
      expect(form.volume.state.touched, isTrue);
    });

    testWidgets('writes a whole number to an int Field', (tester) async {
      await tester.pumpWidget(
        app((form) => FormidableSlider(field: form.rating, max: 5)),
      );

      tester.widget<Slider>(find.byType(Slider)).onChanged!(2.6);
      await tester.pump();

      expect(form.rating.value, 3);
      expect(form.rating.value, isA<int>());
    });

    testWidgets('shows the Validation Message of a touched, Unset Field', (
      tester,
    ) async {
      await tester.pumpWidget(
        app((form) => FormidableSlider(field: form.volume)),
      );
      expect(find.text('This field is required.'), findsNothing);

      form.volume.markAsTouched();
      await tester.pump();

      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('labels the thumb with labelBuilder', (tester) async {
      await tester.pumpWidget(
        app(
          (form) => FormidableSlider(
            field: form.rating,
            max: 5,
            divisions: 5,
            labelBuilder: (value) => '$value stars',
          ),
        ),
      );

      form.rating.setValue(4);
      await tester.pump();

      expect(tester.widget<Slider>(find.byType(Slider)).label, '4 stars');
    });
  });
}
